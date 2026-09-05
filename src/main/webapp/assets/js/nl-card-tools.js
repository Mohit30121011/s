/* ============================================================================
 * NLogistic — Card Toolbar (Export + Fullscreen)
 * ----------------------------------------------------------------------------
 * Adds a working Export and Fullscreen control to every card/panel on the site.
 * Purely additive: it never changes card content, only appends two buttons to
 * each card header (or a floating strip when a card has no header).
 *
 *   Export     - a chart card exports the canvas as PNG; a card containing a
 *                table exports that table as CSV; anything else exports the
 *                card's visible text. Filenames come from the card title.
 *   Fullscreen - native Fullscreen API on the card element, with a fallback to
 *                a fixed-position "maximised" mode where the API is blocked.
 *                Charts are resized on enter/exit so they don't stay letterboxed.
 * ========================================================================== */
(function () {
    'use strict';
    if (window.__nlCardTools) return;
    window.__nlCardTools = true;

    var CARD_SELECTOR = [
        '.card', '.nl-card', '.card-panel', '.table-card', '.chart-card',
        '.nl-chart-card', '.certificate-container'
    ].join(',');

    var HEADER_SELECTOR = [
        '.card-header', '.nl-card-header', '.chart-header', '.panel-header'
    ].join(',');

    /* ---------------------------------------------------------------- utils */

    function titleOf(card) {
        var h = card.querySelector('.card-title, .chart-title, .panel-header, h1, h2, h3, h4, h5, h6');
        var t = h ? (h.textContent || '').trim() : '';
        t = t.replace(/\s+/g, ' ').slice(0, 60);
        return t || 'NLogistic-Export';
    }

    function slug(s) {
        return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'export';
    }

    function stamp() {
        var d = new Date();
        function p(n) { return (n < 10 ? '0' : '') + n; }
        return d.getFullYear() + p(d.getMonth() + 1) + p(d.getDate()) + '-' + p(d.getHours()) + p(d.getMinutes());
    }

    function saveBlob(blob, filename) {
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
    }

    function csvCell(text) {
        var v = (text || '').replace(/\s+/g, ' ').trim();
        return /[",\n]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v;
    }

    /** Skips rows the page has filtered/paginated away, so the export matches the view. */
    function visible(el) {
        return !!(el.offsetParent !== null || el.getClientRects().length);
    }

    function tableToCsv(table) {
        var rows = [];
        Array.prototype.forEach.call(table.querySelectorAll('tr'), function (tr) {
            if (!visible(tr)) return;
            var cells = tr.querySelectorAll('th,td');
            if (!cells.length) return;
            var line = [];
            Array.prototype.forEach.call(cells, function (c) {
                // Drop action-button columns: they export as noise.
                if (c.querySelector('button, .btn-icon-action, .actions-flex')) {
                    line.push('');
                } else {
                    line.push(csvCell(c.innerText || c.textContent));
                }
            });
            rows.push(line.join(','));
        });
        return rows.join('\n');
    }

    /* --------------------------------------------------------------- export */

    function doExport(card) {
        var name = slug(titleOf(card)) + '-' + stamp();

        var canvas = card.querySelector('canvas');
        if (canvas && canvas.width > 0) {
            try {
                // Charts render on a transparent canvas; paint a white ground so the
                // exported PNG is usable in documents and print.
                var out = document.createElement('canvas');
                out.width = canvas.width;
                out.height = canvas.height;
                var ctx = out.getContext('2d');
                ctx.fillStyle = '#FFFFFF';
                ctx.fillRect(0, 0, out.width, out.height);
                ctx.drawImage(canvas, 0, 0);
                out.toBlob(function (blob) {
                    if (blob) saveBlob(blob, name + '.png');
                });
                return;
            } catch (e) { /* fall through to text export */ }
        }

        var table = card.querySelector('table');
        if (table) {
            var csv = tableToCsv(table);
            if (csv) {
                saveBlob(new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' }), name + '.csv');
                return;
            }
        }

        var text = (card.innerText || '').split('\n')
            .map(function (l) { return l.trim(); })
            .filter(function (l) { return l && l !== 'Export' && l !== 'Fullscreen'; })
            .join('\n');
        saveBlob(new Blob([text], { type: 'text/plain;charset=utf-8;' }), name + '.txt');
    }

    /* ----------------------------------------------------------- fullscreen */

    function resizeCharts(card) {
        // Chart.js keeps its own sized backing store and writes inline width/height
        // onto the canvas. After leaving fullscreen those inline sizes are still the
        // fullscreen ones, which is what made the card come back the wrong size.
        // Clear them, then let Chart.js recompute from the restored layout.
        //
        // Chart.getChart(canvas) is the Chart.js v4 lookup; the old Chart.instances
        // registry this used at first does not exist in v4, so nothing was ever
        // resized and every exit left a stretched canvas behind.
        function apply() {
            var canvases = card.querySelectorAll('canvas');
            Array.prototype.forEach.call(canvases, function (cv) {
                var chart = null;
                try {
                    if (typeof Chart !== 'undefined' && typeof Chart.getChart === 'function') {
                        chart = Chart.getChart(cv);
                    }
                } catch (e) {}

                cv.style.width = '';
                cv.style.height = '';

                if (chart) {
                    try { chart.resize(); } catch (e) {}
                } 
            });
            window.dispatchEvent(new Event('resize'));
        }
        // Two passes: once the browser has restored layout, and once after the
        // fullscreen transition finishes.
        requestAnimationFrame(apply);
        setTimeout(apply, 250);
    }

    function exitManual(card) {
        card.classList.remove('nl-card-maximised');
        document.body.classList.remove('nl-card-maximised-open');
        resizeCharts(card);
    }

    function toggleFullscreen(card) {
        var fsEl = document.fullscreenElement || document.webkitFullscreenElement;

        if (fsEl === card) {
            (document.exitFullscreen || document.webkitExitFullscreen).call(document);
            return;
        }
        if (card.classList.contains('nl-card-maximised')) {
            exitManual(card);
            return;
        }

        var req = card.requestFullscreen || card.webkitRequestFullscreen;
        if (req) {
            req.call(card).then(function () {
                resizeCharts(card);
            }).catch(function () {
                // Fullscreen can be refused (permissions policy, embedded frame).
                card.classList.add('nl-card-maximised');
                document.body.classList.add('nl-card-maximised-open');
                resizeCharts(card);
            });
        } else {
            card.classList.add('nl-card-maximised');
            document.body.classList.add('nl-card-maximised-open');
            resizeCharts(card);
        }
    }

    document.addEventListener('fullscreenchange', function () {
        var card = document.fullscreenElement;
        if (card) resizeCharts(card);
        else document.querySelectorAll(CARD_SELECTOR).forEach(resizeCharts);
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            var open = document.querySelector('.nl-card-maximised');
            if (open) exitManual(open);
        }
    });

    /* ------------------------------------------------------------- wiring */

    function button(icon, label, onClick) {
        var b = document.createElement('button');
        b.type = 'button';
        b.className = 'nl-card-tool';
        b.title = label;
        b.setAttribute('aria-label', label);
        b.innerHTML = '<i class="ti ' + icon + '"></i>';
        b.addEventListener('click', function (ev) {
            ev.preventDefault();
            ev.stopPropagation();
            onClick();
        });
        return b;
    }

    function decorate(card) {
        if (card.dataset.nlTools === '1') return;

        // Skip shells that only wrap other cards, modals, filter bars, and stats/summary cards
        if (card.closest('.modal, .modal-content, .modal-overlay')) return;
        if (card.dataset.noTools === 'true' || card.classList.contains('no-card-tools')) return;
        if (card.classList.contains('filter-card') || card.querySelector('.stats-container, .stats-items, .alerts-kpi-grid')) return;
        if (card.querySelector(CARD_SELECTOR)) return;
        if (card.offsetHeight < 80) return;

        card.dataset.nlTools = '1';

        var tools = document.createElement('div');
        tools.className = 'nl-card-tools';
        tools.appendChild(button('ti-download', 'Export this card', function () { doExport(card); }));
        tools.appendChild(button('ti-arrows-maximize', 'Fullscreen', function () { toggleFullscreen(card); }));

        var header = card.querySelector(HEADER_SELECTOR);
        if (header && header.parentElement === card) {
            header.style.position = header.style.position || 'relative';
            header.appendChild(tools);
        } else {
            tools.classList.add('nl-card-tools-floating');
            if (getComputedStyle(card).position === 'static') {
                // Marker class instead of an inline style, so nothing we set here can
                // survive and alter the card's layout later.
                card.classList.add('nl-card-anchor');
            }
            card.appendChild(tools);
        }
    }

    function scan() {
        document.querySelectorAll(CARD_SELECTOR).forEach(decorate);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', scan);
    } else {
        scan();
    }
    // Cards that appear later (tab switches, AJAX panels) get the toolbar too.
    setTimeout(scan, 600);
    setTimeout(scan, 1800);
})();
