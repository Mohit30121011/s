/* ============================================================================
 * NLogistic — Global Dynamic Chart Theme  (Chart.js 4.x - Light & Dark Mode)
 * ----------------------------------------------------------------------------
 * Purely presentational. This file NEVER touches chart data, labels, scales
 * callbacks or any business logic — it dynamically restyles what each page
 * builds to match the active theme (light or dark mode): gradient area/bar
 * fills, rounded bars, soft-shadowed lines, surface-matched arc separators,
 * modern glass tooltips, and the project's Swiggy-orange palette.
 *
 * Load it AFTER chart.umd.min.js and BEFORE any `new Chart(...)` call.
 * ========================================================================== */
(function () {
    'use strict';
    if (typeof Chart === 'undefined' || Chart.__nlThemed) return;
    Chart.__nlThemed = true;

    var FONT = "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif";

    function isDarkMode() {
        return document.documentElement.getAttribute('data-theme') === 'dark';
    }

    function getThemeColors() {
        if (isDarkMode()) {
            return {
                ink: '#F8FAFC',
                secondary: '#94A3B8',
                muted: '#64748B',
                grid: 'rgba(255, 255, 255, 0.07)',
                tooltipBg: 'rgba(21, 31, 40, 0.96)',
                tooltipBorder: 'rgba(255, 255, 255, 0.12)',
                arcBorder: '#101820',
                shadowColor: 'rgba(0, 0, 0, 0.35)'
            };
        } else {
            return {
                ink: '#1F2937',
                secondary: '#4B5563',
                muted: '#64748B',
                grid: 'rgba(15, 23, 42, 0.055)',
                tooltipBg: 'rgba(17, 24, 39, 0.94)',
                tooltipBorder: 'rgba(255, 255, 255, 0.10)',
                arcBorder: '#FFFFFF',
                shadowColor: 'rgba(15, 23, 42, 0.12)'
            };
        }
    }

    /* ---------------------------------------------------------------- 1. Defaults */
    function applyThemeDefaults() {
        var colors = getThemeColors();

        Chart.defaults.font.family = FONT;
        Chart.defaults.font.size = 11.5;
        Chart.defaults.font.weight = 500;
        Chart.defaults.color = colors.secondary;
        Chart.defaults.animation.duration = 600;
        Chart.defaults.animation.easing = 'easeOutQuart';
        Chart.defaults.responsive = true;
        Chart.defaults.devicePixelRatio = Math.max(window.devicePixelRatio || 1, 2);

        Chart.defaults.plugins.legend.labels.usePointStyle = true;
        Chart.defaults.plugins.legend.labels.pointStyle = 'circle';
        Chart.defaults.plugins.legend.labels.boxWidth = 7;
        Chart.defaults.plugins.legend.labels.boxHeight = 7;
        Chart.defaults.plugins.legend.labels.padding = 16;
        Chart.defaults.plugins.legend.labels.color = colors.secondary;

        var T = Chart.defaults.plugins.tooltip;
        T.backgroundColor = colors.tooltipBg;
        T.titleColor = '#FFFFFF';
        T.titleFont = { family: FONT, size: 12, weight: '700' };
        T.bodyColor = '#E5E7EB';
        T.bodyFont = { family: FONT, size: 12, weight: '500' };
        T.padding = { top: 10, right: 14, bottom: 10, left: 12 };
        T.cornerRadius = 10;
        T.displayColors = true;
        T.usePointStyle = true;
        T.boxPadding = 6;
        T.borderColor = colors.tooltipBorder;
        T.borderWidth = 1;
        T.caretSize = 6;
    }

    applyThemeDefaults();

    // Listen for live theme changes to update active charts instantly
    window.addEventListener('themeChanged', function () {
        applyThemeDefaults();
        var colors = getThemeColors();
        var isDark = isDarkMode();
        var pointBg = isDark ? '#151F28' : '#FFFFFF';
        if (Chart.instances) {
            Object.values(Chart.instances).forEach(function (chart) {
                try {
                    (chart.data.datasets || []).forEach(function (ds) {
                        var type = ds.type || chart.config.type;
                        if (isArc(type)) {
                            ds.borderColor = colors.arcBorder;
                            ds.hoverBorderColor = colors.arcBorder;
                        }
                        if (type === 'line') {
                            ds.pointBackgroundColor = pointBg;
                            ds.pointHoverBackgroundColor = pointBg;
                            ds.pointBorderColor = ds.borderColor || '#FC8019';
                            ds.pointHoverBorderColor = ds.borderColor || '#FC8019';
                        }
                    });
                    chart.update();
                } catch (err) {}
            });
        }
    });

    /* ------------------------------------------------- 2. Colour / gradient utils */
    function toRgb(c) {
        if (typeof c !== 'string') return null;
        c = c.trim();
        var m = c.match(/^#([0-9a-f]{6})$/i);
        if (m) {
            var n = parseInt(m[1], 16);
            return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
        }
        m = c.match(/^#([0-9a-f]{3})$/i);
        if (m) {
            return [parseInt(m[1][0] + m[1][0], 16), parseInt(m[1][1] + m[1][1], 16), parseInt(m[1][2] + m[1][2], 16)];
        }
        m = c.match(/^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i);
        if (m) return [+m[1], +m[2], +m[3]];
        return null;
    }
    function rgba(c, a) {
        var r = toRgb(c);
        return r ? 'rgba(' + r[0] + ',' + r[1] + ',' + r[2] + ',' + a + ')' : c;
    }
    function lighten(c, amt) {
        var r = toRgb(c);
        if (!r) return c;
        return 'rgb(' + r.map(function (v) { return Math.round(v + (255 - v) * amt); }).join(',') + ')';
    }

    /** Vertical gradient across the plot area — used for area fills and bars. */
    function vGradient(ctx, area, color, topAlpha, bottomAlpha) {
        if (!area || area.bottom === area.top) return rgba(color, topAlpha);
        var g = ctx.createLinearGradient(0, area.top, 0, area.bottom);
        g.addColorStop(0, rgba(color, topAlpha));
        g.addColorStop(1, rgba(color, bottomAlpha));
        return g;
    }
    /** Solid top-to-bottom bar gradient (light head -> brand foot). */
    function barGradient(ctx, area, color) {
        if (!area || area.bottom === area.top) return color;
        var g = ctx.createLinearGradient(0, area.top, 0, area.bottom);
        g.addColorStop(0, lighten(color, 0.22));
        g.addColorStop(1, color);
        return g;
    }

    function isArc(type) { return type === 'doughnut' || type === 'pie' || type === 'polarArea'; }

    /* --------------------------------------------- 3. The modernisation plugin */
    Chart.register({
        id: 'nlModernTheme',

        /* Style datasets once, before the chart is built. */
        beforeInit: function (chart) {
            var base = chart.config.type;
            var colors = getThemeColors();

            (chart.data.datasets || []).forEach(function (ds) {
                var type = ds.type || base;

                if (type === 'line') {
                    if (ds.tension === undefined) ds.tension = 0.42;
                    if (ds.borderWidth === undefined || ds.borderWidth < 2.5) ds.borderWidth = 2.5;
                    ds.borderCapStyle = 'round';
                    ds.borderJoinStyle = 'round';
                    if (ds.pointRadius === undefined) ds.pointRadius = 4;
                    ds.pointHoverRadius = 6.5;
                    ds.pointHoverBorderWidth = 3;
                    var isDark = isDarkMode();
                    var pointBg = isDark ? '#151F28' : '#FFFFFF';
                    var pointBorder = ds.borderColor || '#FC8019';
                    ds.pointHoverBorderColor = pointBorder;
                    ds.pointHoverBackgroundColor = pointBg;
                    ds.pointBackgroundColor = pointBg;
                    ds.pointBorderColor = pointBorder;
                    ds.pointBorderWidth = 2.5;
                    ds.pointHitRadius = 14;
                    // Gradient area fill, applied later once chartArea exists.
                    if (ds.fill !== false && typeof ds.borderColor === 'string') {
                        ds.__nlFill = ds.borderColor;
                        if (ds.fill === undefined) ds.fill = true;
                    }

                } else if (type === 'bar') {
                    if (ds.borderRadius === undefined) ds.borderRadius = 8;
                    ds.borderSkipped = false;
                    if (ds.maxBarThickness === undefined) ds.maxBarThickness = 42;
                    ds.borderWidth = 0;
                    if (typeof ds.backgroundColor === 'string') {
                        ds.__nlBar = ds.backgroundColor;
                        ds.hoverBackgroundColor = ds.backgroundColor;
                    }

                } else if (isArc(type)) {
                    var isGauge = ds.circumference !== undefined && ds.circumference < 360;
                    if (!isGauge) {
                        ds.borderWidth = 3;
                        ds.borderColor = colors.arcBorder;
                        ds.borderAlign = 'inner';
                        ds.hoverOffset = 8;
                        ds.hoverBorderColor = colors.arcBorder;
                        if (type === 'doughnut' && ds.cutout === undefined && chart.config.options &&
                            chart.config.options.cutout === undefined) {
                            ds.cutout = '68%';
                        }
                    }
                    if (ds.borderRadius === undefined && !isGauge) ds.borderRadius = 6;
                }
            });
        },

        /* Resolve gradients + draw the soft depth shadow. */
        beforeDatasetsDraw: function (chart) {
            var ctx = chart.ctx, area = chart.chartArea;
            if (!area) return;
            var colors = getThemeColors();

            (chart.data.datasets || []).forEach(function (ds, i) {
                var meta = chart.getDatasetMeta(i);
                var dsType = ds.type || chart.config.type;
                if (isArc(dsType)) {
                    ds.borderColor = colors.arcBorder;
                    ds.hoverBorderColor = colors.arcBorder;
                }
                if (ds.__nlFill) {
                    var fill = vGradient(ctx, area, ds.__nlFill, 0.26, 0.0);
                    ds.backgroundColor = fill;
                    if (meta && meta.dataset) meta.dataset.options.backgroundColor = fill;
                }
                if (ds.__nlBar) {
                    var bg = barGradient(ctx, area, ds.__nlBar);
                    ds.backgroundColor = bg;
                    ds.hoverBackgroundColor = barGradient(ctx, area, lighten(ds.__nlBar, 0.12));
                    if (meta) {
                        (meta.data || []).forEach(function (el) { el.options.backgroundColor = bg; });
                    }
                }
            });

            // Depth: a soft drop shadow behind lines and arcs
            var t = chart.config.type;
            if (t === 'line' || isArc(t)) {
                var colors = getThemeColors();
                ctx.save();
                ctx.shadowColor = colors.shadowColor;
                ctx.shadowBlur = t === 'line' ? 10 : 14;
                ctx.shadowOffsetY = t === 'line' ? 5 : 4;
            }
        },
        afterDatasetsDraw: function (chart) {
            var t = chart.config.type;
            if (t === 'line' || isArc(t)) chart.ctx.restore();
        },

        /* Modern, theme-aware axes. */
        afterLayout: function (chart) {
            var colors = getThemeColors();
            var sc = chart.scales || {};
            Object.keys(sc).forEach(function (k) {
                var s = sc[k];
                if (!s || !s.options) return;
                var o = s.options;
                if (o.grid) {
                    if (o.grid.display !== false) o.grid.color = colors.grid;
                    o.grid.drawTicks = false;
                    o.grid.tickLength = 0;
                }
                if (o.border) o.border.display = false;
                if (o.ticks) {
                    o.ticks.padding = o.ticks.padding !== undefined ? o.ticks.padding : 8;
                    o.ticks.color = colors.secondary;
                }
                if (o.title && o.title.display) o.title.color = colors.ink;
            });
        }
    });

    /* --------------------------- 4. Shared palette for pages that want one ----- */
    Chart.NL_PALETTE = ['#FC8019', '#3B82F6', '#10B981', '#8B5CF6', '#F59E0B',
                        '#EF4444', '#06B6D4', '#EC4899', '#6366F1', '#14B8A6'];
    try {
        Chart.defaults.datasets.doughnut.backgroundColor = Chart.NL_PALETTE;
        Chart.defaults.datasets.pie.backgroundColor = Chart.NL_PALETTE;
    } catch (e) { }
})();
