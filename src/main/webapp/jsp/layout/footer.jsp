        </div> <!-- Close content-area -->
    </main> <!-- Close main-wrapper -->

    <!-- Bootstrap 5 JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- TomSelect JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
    <script>
    // Global Edge & Viewport Collision Detection for all TomSelect dropdowns (Auto-Flip Upwards)
    if (typeof TomSelect !== 'undefined') {
        TomSelect.prototype.positionDropdown = function() {
            if (this.settings.dropdownParent !== 'body') {
                return;
            }

            var context = this.control;
            var rect = context.getBoundingClientRect();
            var dropdown = this.dropdown;

            // Measure actual height of the dropdown
            var dropdownHeight = dropdown.offsetHeight;
            if (!dropdownHeight || dropdownHeight <= 0) {
                dropdownHeight = dropdown.scrollHeight || 140;
            }

            var spaceBelow = window.innerHeight - rect.bottom;
            var spaceAbove = rect.top;
            var buffer = 12; // safety edge margin

            var top;
            var isDropup = false;

            // If not enough space below, and there is space above, FLIP UPWARDS!
            if ((spaceBelow < dropdownHeight + buffer) && (spaceAbove > dropdownHeight || spaceAbove > spaceBelow)) {
                top = rect.top + window.scrollY - dropdownHeight - 4;
                isDropup = true;
            } else {
                top = context.offsetHeight + rect.top + window.scrollY + 4;
                isDropup = false;
            }

            var left = rect.left + window.scrollX;
            var dropdownWidth = rect.width;
            // Guard: if the control hasn't been laid out yet (e.g. it just became visible
            // inside a modal, or the page hasn't finished its first layout pass), rect.width
            // can be 0/near-0, which squashes the whole dropdown panel to a hairline strip.
            // Fall back to the wrapper's width, then a sane minimum, so this never happens.
            if (!dropdownWidth || dropdownWidth < 60) {
                var wrapperWidth = this.wrapper ? this.wrapper.getBoundingClientRect().width : 0;
                dropdownWidth = (wrapperWidth >= 60) ? wrapperWidth : 220;
            }

            // For micro pagination dropdowns, keep minimum 74px width
            if (this.wrapper && this.wrapper.classList.contains('nl-page-size-ts')) {
                dropdownWidth = Math.max(dropdownWidth, 74);
            }

            // Prevent right-edge and left-edge overflow
            if (rect.left + dropdownWidth > window.innerWidth - 8) {
                left = window.innerWidth + window.scrollX - dropdownWidth - 8;
            }
            if (left < 4) left = 4;

            dropdown.style.width = dropdownWidth + 'px';
            dropdown.style.top = top + 'px';
            dropdown.style.left = left + 'px';

            if (isDropup) {
                dropdown.classList.add('ts-dropup');
                if (this.wrapper) this.wrapper.classList.add('dropdown-dropup');
            } else {
                dropdown.classList.remove('ts-dropup');
                if (this.wrapper) this.wrapper.classList.remove('dropdown-dropup');
            }
        };
    }

    document.addEventListener('DOMContentLoaded', function() {
        // Global Enterprise Custom Dropdown Initializer across the entire system
        function initCustomSelects(root) {
            const scope = root || document;

            // 1. Pagination Rows-Per-Page Micro Dropdowns (Global Custom Styling)
            scope.querySelectorAll('select.nl-page-size-select').forEach(function(el) {
                if (!el.tomselect && !el.classList.contains('tomselected')) {
                    try {
                        const ts = new TomSelect(el, {
                            create: false,
                            dropdownParent: 'body',
                            allowEmptyOption: false,
                            controlInput: null,
                            onInitialize: function() {
                                this.wrapper.classList.add('nl-page-size-ts');
                                this.on('dropdown_open', () => this.positionDropdown());
                            }
                        });
                        ts.on('change', function(val) {
                            if (typeof el.onchange === 'function') {
                                el.onchange();
                            } else {
                                el.dispatchEvent(new Event('change'));
                            }
                        });
                    } catch(err) {
                        console.warn("TomSelect page size init error:", err);
                    }
                }
            });

            // 2. Standard Form & Filter Dropdowns
            scope.querySelectorAll('select.form-select, select.form-select-custom, select:not(.no-custom-select):not(.nl-page-size-select)').forEach(function(el) {
                if (el.classList.contains('no-custom-select')) return;
                if (!el.tomselect && !el.classList.contains('tomselected')) {
                    const shouldSort = (el.dataset.sort === 'asc');
                    const firstOption = el.options[0];
                    const defaultPlaceholder = firstOption ? firstOption.text.trim() : 'Select...';
                    const forceSearch = (el.dataset.search === 'true' || el.classList.contains('enable-search') || el.classList.contains('has-search'));
                    const noSearch = !forceSearch && (el.dataset.noSearch === 'true' || el.options.length <= 4 || el.classList.contains('no-search'));
                    try {
                        const ts = new TomSelect(el, {
                            create: false,
                            sortField: shouldSort ? { field: "text", direction: "asc" } : null,
                            dropdownParent: 'body',
                            allowEmptyOption: true,
                            controlInput: noSearch ? null : undefined,
                            placeholder: defaultPlaceholder,
                            closeAfterSelect: true,
                            onInitialize: function() {
                                this.on('dropdown_open', () => {
                                    this.positionDropdown();
                                    if (this.control_input) {
                                        if (!this.control_input.dataset.origPlaceholder && this.control_input.placeholder) {
                                            this.control_input.dataset.origPlaceholder = this.control_input.placeholder;
                                        }
                                        this.control_input.placeholder = el.dataset.searchPlaceholder || '';
                                    }
                                });
                                this.on('dropdown_close', () => {
                                    if (this.control_input && this.control_input.dataset.origPlaceholder) {
                                        this.control_input.placeholder = this.control_input.dataset.origPlaceholder;
                                    }
                                });
                                this.on('focus', () => {
                                    if (this.control_input) {
                                        if (!this.control_input.dataset.origPlaceholder && this.control_input.placeholder) {
                                            this.control_input.dataset.origPlaceholder = this.control_input.placeholder;
                                        }
                                        this.control_input.placeholder = el.dataset.searchPlaceholder || '';
                                    }
                                });
                                this.on('blur', () => {
                                    if (this.control_input && this.control_input.dataset.origPlaceholder) {
                                        this.control_input.placeholder = this.control_input.dataset.origPlaceholder;
                                    }
                                });
                            }
                        });
                        if (el.value && !ts.getValue()) {
                            ts.setValue(el.value);
                        }
                        ts.on('item_add', function() {
                            this.close();
                            this.blur();
                        });
                        ts.on('change', function(val) {
                            this.close();
                            this.blur();
                            if (typeof el.onchange === 'function') {
                                try { el.onchange(); } catch(e) { console.error(e); }
                            }
                            el.dispatchEvent(new Event('change', { bubbles: true }));
                        });
                    } catch(err) {
                        console.warn("TomSelect init error:", err);
                    }
                }
            });
        }
        initCustomSelects();

        // Global: Auto-clear placeholder on click/focus for all inputs & textareas, restore on blur
        document.addEventListener('focusin', function(e) {
            if (e.target && (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA')) {
                if (e.target.placeholder) {
                    e.target.dataset.placeholderBackup = e.target.placeholder;
                    e.target.placeholder = '';
                }
            }
        });
        document.addEventListener('focusout', function(e) {
            if (e.target && (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA')) {
                if (e.target.dataset.placeholderBackup) {
                    e.target.placeholder = e.target.dataset.placeholderBackup;
                }
            }
        });

        // Auto-refresh and re-sync any TomSelect dropdowns inside Bootstrap modals
        document.addEventListener('shown.bs.modal', function(event) {
            initCustomSelects(event.target);
            event.target.querySelectorAll('select.tomselected').forEach(function(sel) {
                if (sel.tomselect) {
                    sel.tomselect.sync();
                }
            });
        });
    });
    </script>
</body>
</html>

<%-- Export + Fullscreen controls on every card (sitewide) --%>
<script src="${pageContext.request.contextPath}/assets/js/nl-card-tools.js"></script>
