path = "D:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/DashboardServlet.java"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Check if conflict markers exist
if "<<<<<<" in content:
    print("Conflicts found, resolving...")
    # Extract OUR version (between <<<< HEAD and ====)
    import re
    # Take ours but add roleId check from theirs at the top of doGet
    # Remove all conflict markers and take ours
    # Strategy: take everything between HEAD and =====
    parts = content.split("<<<<<<< HEAD\n")
    result = parts[0]  # before first conflict
    for part in parts[1:]:
        ours_and_rest = part.split("=======\n", 1)
        ours = ours_and_rest[0]
        rest = ours_and_rest[1].split(">>>>>>> ", 1)[1]
        after_marker = rest.split("\n", 1)[1]  # skip the commit hash line
        result += ours + after_marker
    
    # Now add the roleId auth check from remote into our doGet, right after the method signature
    auth_check = """        // Contract Precondition: Verify caller is authenticated with a valid role
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Access Denied: Authentication required.");
            return;
        }

        """
    result = result.replace(
        "        try (Connection conn = DBConnectionManager.getConnection()) {",
        auth_check + "        try (Connection conn = DBConnectionManager.getConnection()) {"
    )
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(result)
    print("DashboardServlet resolved - kept our DB version + added auth check from remote")
else:
    print("No conflicts found")
