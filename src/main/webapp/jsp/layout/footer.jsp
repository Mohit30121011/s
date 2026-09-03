        </div> <!-- Close content-area -->
    </main> <!-- Close main-wrapper -->

    <!-- Bootstrap 5 JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- TomSelect JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // Global Enterprise Custom Dropdown Initializer across the entire system
        function initCustomSelects() {
            document.querySelectorAll('select.form-select, select.form-select-custom, select:not(.no-custom-select)').forEach(function(el) {
                if (!el.tomselect && !el.classList.contains('tomselected')) {
                    const shouldSort = (el.dataset.sort === 'asc');
                    try {
                        new TomSelect(el, {
                            create: false,
                            sortField: shouldSort ? { field: "text", direction: "asc" } : null,
                            dropdownParent: 'body',
                            controlInput: el.options.length > 8 ? '<input>' : null
                        });
                    } catch(err) {
                        console.warn("TomSelect init error:", err);
                    }
                }
            });
        }
        initCustomSelects();
    });
    </script>
</body>
</html>
