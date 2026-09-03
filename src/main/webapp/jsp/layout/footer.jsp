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
                if (!el.tomselect && !el.classList.contains('tomselected')) {
                    const shouldSort = (el.dataset.sort === 'asc');
                    const firstOption = el.options[0];
                    const defaultPlaceholder = firstOption ? firstOption.text.trim() : 'Select...';
                    try {
                        const ts = new TomSelect(el, {
                            create: false,
                            sortField: shouldSort ? { field: "text", direction: "asc" } : null,
                            dropdownParent: 'body',
                            allowEmptyOption: true,
                            placeholder: defaultPlaceholder,
                            onInitialize: function() {
                                this.on('dropdown_open', () => this.positionDropdown());
                            }
                        });
                        if (el.value && !ts.getValue()) {
                            ts.setValue(el.value);
                        }
                    } catch(err) {
                        console.warn("TomSelect init error:", err);
                    }
                }
            });
        }
        initCustomSelects();

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
