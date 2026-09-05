<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Print Labels &mdash; N Logistic</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/tabler-icons/tabler-icons.min.css">
<style>
    /* ------------------------------------------------------------------
       FR8.4 industrial labels.

       Sizes are declared in inches so the browser's print dialog maps them
       onto real label stock (Zebra / Brother / Honeywell) instead of scaling
       a screenshot. @page changes per layout, driven by a class on <body>.
       ------------------------------------------------------------------ */
    * { box-sizing: border-box; }
    body {
        margin: 0; background: #F1F5F9;
        font-family: "Inter", -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
        color: #0F172A;
    }

    .toolbar {
        position: sticky; top: 0; z-index: 10;
        display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        background: #FFFFFF; border-bottom: 1px solid #E2E8F0; padding: 14px 22px;
    }
    .toolbar h1 { margin: 0; font-size: 15px; font-weight: 700; }
    .toolbar .spacer { margin-left: auto; }
    .tb-btn {
        display: inline-flex; align-items: center; gap: 7px; height: 36px; padding: 0 16px;
        border-radius: 10px; border: 1.5px solid #E2E8F0; background: #FFFFFF; color: #475569;
        font-size: 12.5px; font-weight: 600; cursor: pointer; text-decoration: none;
    }
    .tb-btn:hover { border-color: #CBD5E1; color: #0F172A; }
    .tb-btn.primary { background: #FC8019; border-color: #FC8019; color: #FFFFFF; }
    .tb-btn.primary:hover { background: #E8730F; }
    .tb-hint { font-size: 12px; color: #94A3B8; }

    .sheet { padding: 26px; display: flex; flex-wrap: wrap; gap: 20px; align-items: flex-start; }

    /* ---- shared label chrome ---- */
    .label {
        background: #FFFFFF; border: 1.5px solid #0F172A; border-radius: 4px;
        padding: 0.18in; display: flex; flex-direction: column; page-break-inside: avoid;
        break-inside: avoid;
    }
    .label .lbl-brand {
        display: flex; justify-content: space-between; align-items: baseline;
        border-bottom: 1.5px solid #0F172A; padding-bottom: 0.06in; margin-bottom: 0.08in;
    }
    .label .lbl-brand strong { font-size: 8pt; letter-spacing: 0.08em; text-transform: uppercase; }
    .label .lbl-brand span { font-size: 7pt; color: #475569; text-transform: uppercase; letter-spacing: 0.06em; }
    .label .lbl-heading { font-weight: 800; line-height: 1.1; word-break: break-word; }
    .label .lbl-sub { color: #334155; margin-top: 0.03in; }
    .label .lbl-rows { margin-top: 0.09in; width: 100%; border-collapse: collapse; }
    .label .lbl-rows td { padding: 0.025in 0; vertical-align: top; }
    .label .lbl-rows td.k { color: #475569; text-transform: uppercase; letter-spacing: 0.04em; white-space: nowrap; padding-right: 0.1in; }
    .label .lbl-rows td.v { font-weight: 700; text-align: right; word-break: break-word; }
    .label .lbl-code { margin-top: auto; padding-top: 0.09in; text-align: center; }
    .label .lbl-code img { display: block; margin: 0 auto; max-width: 100%; }
    .label .lbl-value {
        font-family: "SFMono-Regular", Consolas, monospace; letter-spacing: 0.06em;
        margin-top: 0.04in; font-weight: 700;
    }
    .label .lbl-missing {
        border: 1px dashed #94A3B8; color: #94A3B8; padding: 0.12in; font-size: 7pt; border-radius: 3px;
    }

    /* ---- 4in x 6in container placard ---- */
    .label.placard { width: 4in; height: 6in; }
    .label.placard .lbl-heading { font-size: 26pt; }
    .label.placard .lbl-sub { font-size: 11pt; }
    .label.placard .lbl-rows { font-size: 9.5pt; }
    .label.placard .lbl-code img { max-height: 1.5in; }
    .label.placard .lbl-value { font-size: 10pt; }
    .label.placard .lbl-owner {
        margin-top: 0.06in; font-size: 8pt; color: #475569;
        text-transform: uppercase; letter-spacing: 0.05em;
    }

    /* ---- 4in x 6in generic record label ---- */
    .label.record { width: 4in; height: 6in; }
    .label.record .lbl-heading { font-size: 22pt; }
    .label.record .lbl-sub { font-size: 10.5pt; }
    .label.record .lbl-rows { font-size: 9.5pt; }
    .label.record .lbl-code img { max-height: 1.5in; }
    .label.record .lbl-value { font-size: 10pt; }

    /* ---- 3in x 2in warehouse shelf / bin tag ---- */
    .label.shelf { width: 3in; height: 2in; padding: 0.11in; }
    .label.shelf .lbl-brand { padding-bottom: 0.03in; margin-bottom: 0.04in; }
    .label.shelf .lbl-brand strong { font-size: 6pt; }
    .label.shelf .lbl-brand span { font-size: 5.5pt; }
    .label.shelf .lbl-heading { font-size: 11pt; }
    .label.shelf .lbl-sub { font-size: 6.5pt; }
    .label.shelf .lbl-rows { font-size: 6.5pt; margin-top: 0.04in; }
    .label.shelf .lbl-code { padding-top: 0.04in; }
    .label.shelf .lbl-code img { max-height: 0.5in; }
    .label.shelf .lbl-value { font-size: 6.5pt; margin-top: 0.02in; }

    .empty { padding: 60px 26px; text-align: center; color: #94A3B8; }
    .empty i { font-size: 34px; display: block; margin-bottom: 12px; }

    /* ------------------------------------------------------------------
       Print rules. Screen chrome disappears; the page box matches the stock.
       ------------------------------------------------------------------ */
    @media print {
        body { background: #FFFFFF; }
        .toolbar { display: none !important; }
        .sheet { padding: 0; gap: 0; display: block; }
        .label { border-radius: 0; margin: 0; }
        .label + .label { page-break-before: always; }
    }
    @page { margin: 0; }

    /* One label per page, sized to the stock it is printed on. */
    body.page-placard  { }
    body.page-shelf    { }
    @media print {
        body.page-placard { }
        body.page-shelf   { }
    }

    /* A4 batch sheet: tile the labels, no forced page break between them. */
    @media print {
        body.batch .sheet { display: flex; flex-wrap: wrap; gap: 0.1in; padding: 0.2in; }
        body.batch .label + .label { page-break-before: auto; }
    }
</style>
<script>
    // The @page size has to match the stock actually loaded in the printer, and
    // that differs per label type, so it is injected once the layout is known
    // rather than hard-coded to one size for every label on the site.
    (function () {
        var mode = "${batchMode ? 'batch' : ''}";
        var first = "${empty labels ? '' : labels[0].format}";
        var css = document.createElement('style');
        if (mode === 'batch') {
            css.textContent = '@page { size: A4 portrait; margin: 8mm; }';
            document.addEventListener('DOMContentLoaded', function () {
                document.body.classList.add('batch');
            });
        } else if (first === 'shelf') {
            css.textContent = '@page { size: 3in 2in; margin: 0; }';
        } else {
            css.textContent = '@page { size: 4in 6in; margin: 0; }';
        }
        document.head.appendChild(css);
    })();
</script>
</head>
<body>

<div class="toolbar">
    <h1><i class="ti ti-printer"></i>
        <c:choose>
            <c:when test="${batchMode}">Batch Label Sheet</c:when>
            <c:otherwise>Print Label</c:otherwise>
        </c:choose>
    </h1>
    <span class="tb-hint">
        <c:choose>
            <c:when test="${batchMode}">${labels.size()} labels &mdash; A4 sticker sheet</c:when>
            <c:when test="${not empty labels and labels[0].format eq 'shelf'}">3&quot; &times; 2&quot; shelf / bin tag</c:when>
            <c:otherwise>4&quot; &times; 6&quot; placard</c:otherwise>
        </c:choose>
    </span>
    <div class="spacer"></div>
    <a class="tb-btn" href="${pageContext.request.contextPath}/barcodes"><i class="ti ti-arrow-left"></i> Back to registry</a>
    <button type="button" class="tb-btn primary" onclick="window.print()"><i class="ti ti-printer"></i> Print</button>
</div>

<c:choose>
    <c:when test="${empty labels}">
        <div class="empty">
            <i class="ti ti-barcode-off"></i>
            <p>Nothing to print. The barcode was not found, or it belongs to another company.</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="sheet">
            <c:forEach var="lb" items="${labels}">
                <div class="label ${lb.format}">
                    <div class="lbl-brand">
                        <strong>N Logistic</strong>
                        <span>${lb.entityType} #${lb.entityId}</span>
                    </div>

                    <div class="lbl-heading">${lb.heading}</div>
                    <div class="lbl-sub">${lb.subheading}</div>
                    <c:if test="${not empty lb.owner}">
                        <div class="lbl-owner">${lb.owner}</div>
                    </c:if>

                    <table class="lbl-rows">
                        <c:forEach var="r" items="${lb.rows}">
                            <tr><td class="k">${r.key}</td><td class="v">${r.value}</td></tr>
                        </c:forEach>
                    </table>

                    <div class="lbl-code">
                        <c:choose>
                            <c:when test="${not empty lb.imagePath}">
                                <%-- image_path is stored with a leading slash on some rows and
                                     without on others, so normalise it rather than emitting //uploads. --%>
                                <img src="${pageContext.request.contextPath}/${fn:startsWith(lb.imagePath, '/') ? fn:substring(lb.imagePath, 1, -1) : lb.imagePath}"
                                     alt="${lb.barcodeValue}">
                            </c:when>
                            <c:otherwise>
                                <div class="lbl-missing">Barcode image not on disk &mdash; regenerate from the registry.</div>
                            </c:otherwise>
                        </c:choose>
                        <div class="lbl-value">${lb.barcodeValue}</div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

</body>
</html>
