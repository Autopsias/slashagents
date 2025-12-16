---
description: "Orchestrates test failure analysis"
prerequisites: "—"
argument-hint: "[test_scope] [--run-first] [--coverage] [--fast] [--api-only] [--database-only] [--vitest-only] [--pytest-only] [--playwright-only]"
allowed-tools: ["Task", "TodoWrite", "Bash", "Grep", "Read", "LS", "Glob", "SlashCommand"]
---

# Test Orchestration Command

Execute this test orchestration procedure for: "$ARGUMENTS"

## STEP 1: Parse Arguments

Check "$ARGUMENTS" for these flags:
- `--run-first` = Ignore cached results, run fresh tests
- `--pytest-only` = Focus on pytest (backend) only
- `--vitest-only` = Focus on Vitest (frontend) only
- `--playwright-only` = Focus on Playwright (E2E) only
- `--coverage` = Include coverage analysis
- `--fast` = Skip slow tests

## STEP 2: Discover Cached Test Results

Run these commands ONE AT A TIME (do NOT combine them):

**2a. Project info:**
```bash
echo "Project: $(basename $PWD) | Root: $PWD"
```

**2b. Check if pytest results exist:**
```bash
test -f "test-results/pytest/junit.xml" && echo "PYTEST_EXISTS=yes" || echo "PYTEST_EXISTS=no"
```

**2c. If pytest results exist, get stats (run each separately):**
```bash
echo "PYTEST_AGE=$(($(date +%s) - $(stat -f %m test-results/pytest/junit.xml)))s"
```
```bash
echo "PYTEST_TESTS=$(grep -o 'tests="[0-9]*"' test-results/pytest/junit.xml | head -1 | grep -o '[0-9]*')"
```
```bash
echo "PYTEST_FAILURES=$(grep -o 'failures="[0-9]*"' test-results/pytest/junit.xml | head -1 | grep -o '[0-9]*')"
```

**2d. Check Vitest results:**
```bash
test -f "test-results/vitest/results.json" && echo "VITEST_EXISTS=yes" || echo "VITEST_EXISTS=no"
```

**2e. Check Playwright results:**
```bash
test -f "test-results/playwright/results.json" && echo "PLAYWRIGHT_EXISTS=yes" || echo "PLAYWRIGHT_EXISTS=no"
```

## STEP 3: Decision Logic

Based on discovery, decide:

| Condition | Action |
|-----------|--------|
| `--run-first` flag present | Go to STEP 4 (run fresh tests) |
| PYTEST_EXISTS=yes AND AGE < 900s AND FAILURES > 0 | Go to STEP 5 (read results, dispatch fixers) |
| PYTEST_EXISTS=yes AND AGE < 900s AND FAILURES = 0 | Report "All tests passing" and STOP |
| PYTEST_EXISTS=no OR AGE >= 900s | Go to STEP 4 (run fresh tests) |

## STEP 4: Run Fresh Tests (if needed)

**4a. Run pytest:**
```bash
mkdir -p test-results/pytest && uv run pytest -v --tb=short --junitxml=test-results/pytest/junit.xml 2>&1 | tail -30
```

**4b. Run Vitest (if config exists):**
```bash
test -f "vitest.config.ts" && mkdir -p test-results/vitest && npx vitest run --reporter=json --outputFile=test-results/vitest/results.json 2>&1 | tail -20
```

**4c. Run Playwright (if config exists):**
```bash
test -f "playwright.config.ts" && mkdir -p test-results/playwright && npx playwright test --reporter=json 2>&1 | tee test-results/playwright/results.json | tail -20
```

## STEP 5: Read Test Result Files

Use the Read tool:

**For pytest:** `Read(file_path="test-results/pytest/junit.xml")`
- Look for `<testcase>` with `<failure>` or `<error>` children
- Extract: test name, classname (file path), failure message

**For Vitest:** `Read(file_path="test-results/vitest/results.json")`
- Look for `"status": "failed"` entries
- Extract: test name, file path, failure messages

**For Playwright:** `Read(file_path="test-results/playwright/results.json")`
- Look for specs where `"ok": false`
- Extract: test title, browser, error message

## STEP 6: Map Failures to Specialist Agents

| Failure Type | Agent |
|--------------|-------|
| Business logic assertions | unit-test-fixer |
| Mock configuration issues | unit-test-fixer |
| FastAPI endpoint failures | api-test-fixer |
| HTTP status mismatches | api-test-fixer |
| Database connection issues | database-test-fixer |
| Fixture problems | database-test-fixer |
| Type errors (mypy/TS) | type-error-fixer |
| Import/module errors | import-error-fixer |
| E2E selector failures | e2e-test-fixer |
| Timeout issues | e2e-test-fixer |

## STEP 7: Dispatch Agents in Parallel

CRITICAL: Launch ALL agents in ONE response with multiple Task calls.

Example:
```
Task(subagent_type="unit-test-fixer", description="Fix unit test failures",
     prompt="Fix these failures:\n[FAILURE LIST]\nFiles:\n[FILE PATHS]\nMessages:\n[ERROR MESSAGES]")
```

## STEP 8: Validate Fixes

After agents complete:
```bash
uv run pytest -v --tb=short --junitxml=test-results/pytest/junit.xml 2>&1 | tail -30
```

## STEP 9: Report Summary

Report:
- Initial failure count
- Agents dispatched
- Current pass/fail status
- Remaining issues (if any)

---

## Quick Reference

| Command | Effect |
|---------|--------|
| `/test_orchestrate` | Use cached results if fresh (<15 min) |
| `/test_orchestrate --run-first` | Run tests fresh, ignore cache |
| `/test_orchestrate --pytest-only` | Only pytest failures |

## VS Code Integration

pytest.ini must have: `addopts = --junitxml=test-results/pytest/junit.xml`

Then: Run tests in VS Code -> `/test_orchestrate` reads cached results -> Fixes applied

---

EXECUTE NOW. Start with Step 2a.
