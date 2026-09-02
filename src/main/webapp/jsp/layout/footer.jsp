        </div> <!-- Close content-area -->
    </main> <!-- Close main-wrapper -->

    <!-- Bootstrap 5 JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.form-select-custom').forEach((el) => {
            // Prevent multiple initializations
            if (!el.tomselect) {
                new TomSelect(el, {
                    create: false,
                    sortField: { field: "text", direction: "asc" },
                    dropdownParent: 'body'
                });
            }
        });
    });
</script>
</body>
</html>

