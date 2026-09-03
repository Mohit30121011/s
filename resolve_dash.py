path = "D:/NLogistic/NLogistic/src/main/webapp/jsp/dashboard.jsp"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

if "<<<<<<" in content:
    print("Conflicts found, resolving dashboard.jsp...")
    import re
    # Take ours entirely - our version is the complete new dashboard
    parts = content.split("<<<<<<< HEAD\n")
    result = parts[0]
    for part in parts[1:]:
        ours_and_rest = part.split("=======\n", 1)
        ours = ours_and_rest[0]
        rest = ours_and_rest[1].split(">>>>>>> ", 1)[1]
        after_marker = rest.split("\n", 1)[1]
        result += ours + after_marker
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(result)
    print("dashboard.jsp resolved - kept our new revamped version")
    print("Lines:", len(result.splitlines()))
else:
    print("No conflicts found")
