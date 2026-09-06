# AGENT_OPERATING_METHOD.md

> **Purpose:** Drop this into a new agent conversation as the first message. It defines how to work — the loop, the verification discipline, and the speed rules — not what to build.

---

## 1. Core Principle

**Never trust static reading. Verify against the running system.**

Reading code tells you what someone intended. Running it tells you what is. Most real bugs live in the gap between the two — a silently swallowed exception, a fallback that fires only on empty data, a `<select readonly>` that does nothing.

Every claim you make must be backed by something you actually observed: an HTTP status, a DB row, a compile exit code, a rendered string.

---

## 2. The Working Loop

1. **LOCATE**   → grep for the exact symptom, not the general area
2. **READ**     → only the lines you need (`sed -n 'X,Yp'`), never whole files
3. **PROVE**    → reproduce the bug live before fixing it
4. **PATCH**    → surgical edit via script, with an anchor assertion
5. **COMPILE**  → must exit 0
6. **DEPLOY**   → to the actually-served directory
7. **VERIFY**   → drive the real endpoint, check the real DB
8. **CLEAN**    → delete every row your test created

> **Crucial Rule:** Skipping step 3 is the single biggest time sink. If you can't reproduce it, you don't understand it, and your fix is a guess.

---

## 3. Speed Rules (This is where most agents lose time)

### Parallelize independent work
Two commands that don't depend on each other go in one message, as two tool calls. Sequential round-trips are the main latency cost.

```bash
# GOOD: one message, two calls
call 1: grep for the servlet's guards
call 2: grep for the DAO's methods

# BAD: two messages
```

### Read surgically
```bash
grep -n "pattern" file.java | head -20      # find it
sed -n '180,210p' file.java                 # read only that
```
Never cat a 2,000-line file. Never re-read a file you just edited — if the edit tool didn't error, it applied.

### One command, many facts
Batch related checks into a single shell invocation:
```bash
echo "=== A ==="; grep -n "x" a.java
echo "=== B ==="; grep -n "y" b.java
echo "=== C ==="; ls dir/
```

### Don't narrate, don't re-derive
No "Let me now check…" preambles. No re-establishing facts already known in the conversation. Act, then report the finding.

---

## 4. Patching: Script > Manual Editing

For anything beyond a one-line change, write a Python patch script to a scratchpad file, then run it. Do not paste large edits into shell heredocs — quoting will bite you (`'''`, `${...}`, backticks all break).

### Template:
```python
# -*- coding: utf-8 -*-
"""One line: what this fixes and why."""
import io

p = r'ABSOLUTE\PATH\File.java'
s = io.open(p, encoding='utf-8').read()

old = '''<exact text copied from the file>'''
new = '''<replacement>'''

assert old in s, 'anchor not found'   # ← fail loudly, never silently
s = s.replace(old, new, 1)            # ← count=1, never blanket replace

io.open(p, 'w', encoding='utf-8').write(s)
print('patched: <what changed>')
```

### Non-negotiables:
- `assert old in s` on every replacement. A silent no-op patch that you then "verify" is how you report a fix that never happened.
- `count=1` unless you genuinely mean every occurrence.
- Copy the anchor text exactly from a `sed -n` read — trailing spaces and tabs are real. If an assert fails, `cat -A` the region to see invisible whitespace; don't guess.
- To append a method to a class: `i = s.rstrip().rfind('}')` then `s[:i] + method + '}\n'`.
- For balanced markup (JSP/HTML/XML): if you open a conditional tag, verify the close in the same run:
  ```python
  print("opens=%d closes=%d" % (s.count('<c:if'), s.count('</c:if>')))
  ```
  An unbalanced tag will render a blank page and cost you a debugging cycle.

---

## 5. Verification Patterns

### The matrix sweep
When behaviour varies by role/state/tenant, test the whole grid, not one cell:
```bash
for user in admin staff finance customer; do
  login "$user"
  for route in $ROUTES; do
    code=$(curl -s -b jar -o body.html -w "%{http_code}" "$BASE$route")
    printf "  %-12s %-24s %s\n" "$user" "$route" "$code"
  done
done
```
This finds asymmetries a single test never will — and it's one command, not twenty.

### Compare against ground truth
Never eyeball a number. Put the rendered value next to the DB value:
```bash
echo "DB says:";      mysql -N -e "SELECT COUNT(*) FROM shipment WHERE customer_id=12;"
echo "Page shows:";   curl -s -b jar "$BASE/shipments" | grep -c 'status-badge'
```

### Prove the bug before and after
```bash
# BEFORE the fix — capture the evidence
md5sum page_a.html page_b.html   # different = leak exists

# AFTER — same command
md5sum page_a.html page_b.html   # identical = leak closed
```

### Write operations: snapshot → act → diff → revert
```bash
BEFORE=$(mysql -N -e "SELECT COUNT(*) FROM t;")
curl -X POST ... 
AFTER=$(mysql -N -e "SELECT COUNT(*) FROM t;")
# ...verify the row is correct...
mysql -e "DELETE FROM t WHERE marker='MYTEST'; UPDATE parent SET status='Original' WHERE id=X;"
```
Always mark your test data with a unique string (`ZZTEST_`, `RBAC_QUOTE_TEST`) so cleanup is exact. Clean up child rows first (FK constraints), and restore any parent state you flipped.

---

## 6. Traps That Cost Real Time

| Trap | What happens | Guard |
| :--- | :--- | :--- |
| **Testing against a stale deploy** | You "fix" it, test, nothing changes | Find the actually served directory from the running process, not the source tree |
| **Deploy not reloaded yet** | Verification shows old behaviour | `sleep 10` after copying classes; if a result looks impossible, re-test before re-coding |
| **Regex misses a newline** | grep returns 0, you assume broken | Use a multiline check before concluding a patch failed |
| **grep -c on a CSS class** | Counts style rules, not rows | Count a marker unique to rows (a per-row link/id) |
| **Shell variable collision** | Silently wrong test input | Never use `UID`, `PATH`, `HOME` as variable names |
| **Combining -w '%{http_code}' with a grep count** | Output runs together (`2002`) | Print them on separate lines |
| **Stale IDE diagnostics** | Phantom compile errors | The compiler's exit code is the only truth |

---

## 7. Reporting

State what you observed, not what you expect:

- ❌ *"Fixed the tenant leak."*
- ✅ *"Leak confirmed first: `?companyId=2` returned 152,582 bytes vs 151,707 for `companyId=1`. After the fix all three values return identical md5 — param ignored. Super Admin still gets distinct pages."*

- **Lead with the root cause** in one sentence, then the evidence.
- **Use a table** when comparing across roles/states.
- **Flag what you did NOT do.** If a gap remains, say so explicitly rather than letting a summary imply completeness.
- **Own your own bugs.** If you introduced a regression, say *"I introduced this"* — it changes how the user reads the rest.
- Don't re-litigate settled decisions or list options you won't pursue.

---

## 8. When You Find Something Beyond Scope

Fix the thing asked. If you find an adjacent real problem:
- **Security/data-corruption** → fix it now, flag it clearly in the report.
- **Large refactor** → do NOT start it; describe it and ask.

Never silently expand scope. Never silently shrink it either — if part of the task is blocked, finish everything else and say precisely what you left and why.

---

## 9. Quick Reference

```bash
# find, don't browse
grep -rn "symptom" src/ | head -20

# read narrowly
sed -n '180,210p' File.java

# invisible whitespace
sed -n '30,45p' File.java | cat -A

# compile is the truth
javac -nowarn -encoding UTF-8 -cp "$CP" -d /tmp/out @sources.txt; echo "EXIT=$?"

# syntax-check JS without a browser
node --check file.js

# authenticated session
curl -s -c jar -o /dev/null "$BASE/login"
curl -s -b jar -c jar -o /dev/null -X POST -d "user=x&pass=y" "$BASE/login"

# a 302 is not success — check where it went
curl -s -b jar -o /dev/null -w "%{http_code} -> %{redirect_url}\n" "$BASE/route"
```

---

## 10. The One-Line Version

> **Reproduce it, patch it with an asserted anchor, compile it, deploy it to where it's actually served, prove it against the database, clean up after yourself — and report only what you saw.**
