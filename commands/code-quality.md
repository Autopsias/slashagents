---
description: "Analyze and fix code quality issues - file sizes, function lengths, complexity"
argument-hint: "[--check] [--fix] [--focus=file-size|function-length|complexity] [--path=apps/api|apps/web]"
allowed-tools: ["Task", "Bash", "Grep", "Read", "Glob", "TodoWrite", "SlashCommand"]
---

# Code Quality Orchestrator

Analyze and fix code quality violations for: "$ARGUMENTS"

## CRITICAL: ORCHESTRATION ONLY

🚨 **MANDATORY**: This command NEVER fixes code directly.
- Use Bash/Grep/Read for READ-ONLY analysis
- Delegate ALL fixes to specialist agents
- Guard: "Am I about to edit a file? STOP and delegate."

## STEP 1: Parse Arguments

Parse flags from "$ARGUMENTS":
- `--check`: Analysis only, no fixes (DEFAULT if no flags provided)
- `--fix`: Analyze and delegate fixes to agents
- `--focus=file-size|function-length|complexity`: Filter to specific issue type
- `--path=apps/api|apps/web`: Limit scope to specific directory

If no arguments provided, default to `--check` (analysis only).

## STEP 2: Run Quality Analysis

Execute quality check scripts from the repository root:

```bash
python3 scripts/check-file-size.py 2>&1 || true
```

```bash
python3 scripts/check-function-length.py 2>&1 || true
```

Capture violations into categories:
- **FILE_SIZE_VIOLATIONS**: Files >500 LOC (production) or >800 LOC (tests)
- **FUNCTION_LENGTH_VIOLATIONS**: Functions >100 lines
- **COMPLEXITY_VIOLATIONS**: Functions with cyclomatic complexity >12

## STEP 3: Generate Quality Report

Create structured report in this format:

```
## Code Quality Report

### File Size Violations (X files)
| File | LOC | Limit | Status |
|------|-----|-------|--------|
| path/to/file.py | 612 | 500 | ❌ BLOCKING |
...

### Function Length Violations (X functions)
| File:Line | Function | Lines | Status |
|-----------|----------|-------|--------|
| path/to/file.py:125 | _process_job() | 125 | ❌ BLOCKING |
...

### Test File Warnings (X files)
| File | LOC | Limit | Status |
|------|-----|-------|--------|
| path/to/test.py | 850 | 800 | ⚠️ WARNING |
...

### Summary
- Total violations: X
- Critical (blocking): Y
- Warnings (non-blocking): Z
```

## STEP 4: Delegate Fixes (if --fix flag provided)

If `--fix` flag is provided, dispatch specialist agents IN PARALLEL (multiple Task calls in single message):

**For file size violations → delegate to `code-quality-analyzer`:**
```
Task(
    subagent_type="code-quality-analyzer",
    description="Refactor oversized file: {filename}",
    prompt="Refactor this file to reduce size below 500 LOC:
    File: {file_path}
    Current LOC: {loc}

    Strategy: Split into logical modules following existing patterns in the codebase.
    Constraints:
    - Maintain all public APIs
    - Update all imports across the codebase
    - Run tests after refactoring to verify no regressions
    - Follow the patterns documented in .claude/rules/file-size-guidelines.md"
)
```

**For linting issues → delegate to existing `linting-fixer`:**
```
Task(
    subagent_type="linting-fixer",
    description="Fix linting errors",
    prompt="Fix all linting errors found by ruff check and eslint."
)
```

**For type errors → delegate to existing `type-error-fixer`:**
```
Task(
    subagent_type="type-error-fixer",
    description="Fix type errors",
    prompt="Fix all type errors found by mypy and tsc."
)
```

## STEP 5: Verify Results (after --fix)

After agents complete, re-run analysis to verify fixes:

```bash
python3 scripts/check-file-size.py
```

```bash
python3 scripts/check-function-length.py
```

## STEP 6: Report Summary

Output final status:

```
## Code Quality Summary

### Before
- File size violations: X
- Function length violations: Y
- Test file warnings: Z

### After (if --fix was used)
- File size violations: A
- Function length violations: B
- Test file warnings: C

### Status
[PASS/FAIL based on blocking violations]

### Suggested Next Steps
- If violations remain: Run `/code_quality --fix` to auto-fix
- If all passing: Run `/pr --fast` to commit changes
- For manual review: See .claude/rules/file-size-guidelines.md
```

## Examples

```
# Check only (default)
/code_quality

# Check with specific focus
/code_quality --focus=file-size

# Auto-fix all violations
/code_quality --fix

# Auto-fix only Python backend
/code_quality --fix --path=apps/api
```
