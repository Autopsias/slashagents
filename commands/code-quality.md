---
description: "Analyze and fix code quality issues - file sizes, function lengths, complexity"
argument-hint: "[--check] [--fix] [--dry-run] [--refresh-exceptions] [--focus=file-size|function-length|complexity] [--path=...] [--max-parallel=N] [--no-chain] [--continue] [--loop N] [--loop-delay S] [--fix-single-rule]"
allowed-tools: ["Task", "Bash", "Grep", "Read", "Glob", "TodoWrite", "SlashCommand", "AskUserQuestion"]
---

# Code Quality Orchestrator

Analyze and fix code quality violations for: "$ARGUMENTS"

## CRITICAL: ORCHESTRATION ONLY

**MANDATORY**: This command NEVER fixes code directly.
- Use Bash/Grep/Read for READ-ONLY analysis
- Delegate ALL fixes to specialist agents
- Guard: "Am I about to edit a file? STOP and delegate."

---

## STEP 1: Parse Arguments

Parse flags from "$ARGUMENTS":
- `--check`: Analysis only, no fixes (DEFAULT if no flags provided)
- `--fix`: Analyze and delegate fixes to agents with TEST-SAFE workflow
- `--dry-run`: Show refactoring plan without executing changes
- `--focus=file-size|function-length|complexity`: Filter to specific issue type
- `--path=apps/api|apps/web`: Limit scope to specific directory
- `--max-parallel=N`: Maximum parallel agents (default: 3, max: 4)
  ⚠️ WARNING: >4 parallel agents causes context degradation and hallucination risk
- `--no-chain`: Disable automatic chain invocation after fixes
- `--continue`: Resume from saved batch state (do NOT start fresh analysis)
- `--refresh-exceptions`: Regenerate exception baselines to remove stale entries (no fixes)
- `--ralph`: Force Ralph Loop for ALL files (skip single-shot attempt)
  Use when you want guaranteed reliability at the cost of speed
- `--no-ralph`: Disable auto-Ralph fallback on hallucination detection
  ⚠️ WARNING: Without Ralph fallback, hallucinated files will be marked as failed (no retry)
- `--loop N`: Enable fresh-context loop mode (spawns new Claude instances for unattended execution)
  Max N iterations with completely fresh 200K context per iteration
- `--loop-delay S`: Seconds to wait between loop iterations (default: 5)

If no arguments provided, default to `--check` (analysis only).

### Special: --refresh-exceptions

If `--refresh-exceptions` flag provided, ONLY refresh exception files and exit:

```bash
echo "=== REFRESHING EXCEPTION BASELINES ==="

# Count before
BEFORE_FUNC=$(cat .function-length-exceptions 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('exceptions',{})))" 2>/dev/null || echo "0")

# Regenerate function length exceptions
if [ -f ~/.claude/scripts/quality/check_function_lengths.py ]; then
    if command -v uv &> /dev/null; then
        uv run python ~/.claude/scripts/quality/check_function_lengths.py --project "$PWD" --generate-baseline
    else
        python3 ~/.claude/scripts/quality/check_function_lengths.py --project "$PWD" --generate-baseline
    fi
fi

# Count after
AFTER_FUNC=$(cat .function-length-exceptions 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('exceptions',{})))" 2>/dev/null || echo "0")

echo ""
echo "Function length exceptions: $BEFORE_FUNC -> $AFTER_FUNC ($(($BEFORE_FUNC - $AFTER_FUNC)) stale entries removed)"
echo ""
echo "Done. Exception files updated."
```

Exit after refresh (no other steps executed).

---

## STEP 1.25: Ralph Loop Mode Detection (Fresh Context)

**If `--loop` is present in arguments, execute fresh-context loop instead of normal flow.**

This is different from `--ralph` (which is within-context self-correction). The `--loop` flag spawns
completely NEW Claude instances per iteration for unattended/overnight execution.

```
IF "$ARGUMENTS" contains "--loop":

  # Extract loop parameters
  loop_max = extract_number_after("--loop", default=10)
  loop_delay = extract_number_after("--loop-delay", default=5)

  # Determine inner command flags (preserve all except --loop)
  inner_flags = "$ARGUMENTS" without "--loop" and "--loop-delay"
  IF NOT contains "--fix":
    inner_flags += " --fix"  # Loop mode implies --fix

  Output: "════════════════════════════════════════════════════════"
  Output: "🔄 RALPH LOOP MODE ACTIVATED (Code Quality)"
  Output: "════════════════════════════════════════════════════════"
  Output: "  Max iterations: {loop_max}"
  Output: "  Delay between iterations: {loop_delay}s"
  Output: "  Fresh context per iteration: YES"
  Output: "  Mode: Unattended (--fix implied)"
  Output: "  Inner flags: {inner_flags}"
  Output: "════════════════════════════════════════════════════════"
  Output: ""

  # Build inner command (without --loop to avoid infinite recursion)
  # --fix-single-rule flag enables rule-level granularity (one rule per iteration)
  inner_command = "/code_quality {inner_flags} --fix-single-rule"

  # Execute Ralph loop
  FOR iteration IN 1..loop_max:

    Output: ""
    Output: "═══════════════════════════════════════════════════════════"
    Output: "═══ RALPH ITERATION {iteration}/{loop_max} ═══"
    Output: "═══════════════════════════════════════════════════════════"
    Output: "Starting fresh Claude instance..."
    Output: ""

    # Spawn fresh Claude instance with clean context
    ```bash
    OUTPUT=$(claude -p "{inner_command}" --dangerously-skip-permissions 2>&1 | tee /dev/stderr)
    EXIT_CODE=$?
    ```

    # Check for completion signals
    IF OUTPUT matches regex "All.*violations.*fixed|0 violations remaining|Code Quality.*PASS|Status.*PASS":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "✅ RALPH LOOP SUCCESS"
      Output: "════════════════════════════════════════════════════════"
      Output: "  All code quality violations fixed at iteration {iteration}!"
      Output: "  Total iterations used: {iteration}/{loop_max}"
      Output: "════════════════════════════════════════════════════════"
      EXIT 0

    # Check for blocking signals that require human intervention
    IF OUTPUT matches regex "HALT|BLOCKED|Cannot proceed|Manual intervention|user chose.*abort":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "⚠️ RALPH LOOP BLOCKED"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Blocked at iteration {iteration}"
      Output: "  Reason: Manual intervention required"
      Output: "  Action: Review output above and resolve issue"
      Output: "  Resume: /code_quality --loop {remaining_iterations} {inner_flags}"
      Output: "════════════════════════════════════════════════════════"
      EXIT 1

    # Check for "Stop here" signal (user stopped but progress saved)
    IF OUTPUT matches regex "Stop here|state.*saved|--continue to resume":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "⏸️ RALPH LOOP PAUSED (State Saved)"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Progress saved at iteration {iteration}"
      Output: "  Continuing in next iteration with --continue flag..."
      Output: "════════════════════════════════════════════════════════"
      # Update inner_command to include --continue for subsequent iterations
      inner_command = "/code_quality --continue {inner_flags}"

    # Check for non-zero exit (crash or error)
    IF EXIT_CODE != 0:
      Output: "⚠️ Iteration {iteration} exited with code {EXIT_CODE}"
      Output: "   Continuing to next iteration (may be transient)..."

    # Delay before next iteration
    IF iteration < loop_max:
      Output: ""
      Output: "Sleeping {loop_delay}s before next iteration..."
      sleep {loop_delay}

  END FOR

  # Max iterations reached without completion
  Output: ""
  Output: "════════════════════════════════════════════════════════"
  Output: "⚠️ RALPH LOOP INCOMPLETE"
  Output: "════════════════════════════════════════════════════════"
  Output: "  Reached max iterations ({loop_max}) without completion"
  Output: "  Violations may remain"
  Output: "  Action: Check remaining violations with /code_quality --check"
  Output: "  Resume: /code_quality --loop {loop_max}"
  Output: "════════════════════════════════════════════════════════"
  EXIT 1

ELSE:
  # Normal execution - continue to STEP 1.5
  PROCEED TO STEP 1.5
END IF
```

---

## STEP 1.26: Rule-Level Mode Detection (Phase Granularity)

**If `--fix-single-rule` is present, execute only ONE category of quality violations per iteration.**

This provides phase-level granularity for Ralph loops, resulting in:
- 20-35K tokens per iteration (vs 60-100K for all categories)
- Fresh context per rule category (prevents tunnel vision)
- Better recovery from failures

```
IF "--fix-single-rule" in "$ARGUMENTS":
  # RULE-LEVEL MODE: Execute ONLY the next category of violations

  Output: "📋 Rule-level mode active - fixing ONE quality category..."

  # Run quality checks and detect violation categories
  ```bash
  echo "=== Analyzing Quality Violations ==="

  # Check for file size violations
  FILE_SIZE_OUT=""
  if [ -f ~/.claude/scripts/quality/check_file_sizes.py ]; then
      if command -v uv &> /dev/null; then
          FILE_SIZE_OUT=$(uv run python ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD" 2>&1 || true)
      else
          FILE_SIZE_OUT=$(python3 ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD" 2>&1 || true)
      fi
  fi
  HAS_FILE_SIZE=$(echo "$FILE_SIZE_OUT" | grep -cE "BLOCKING|violation" || echo "0")

  # Check for function length violations
  FUNC_LEN_OUT=""
  if [ -f ~/.claude/scripts/quality/check_function_lengths.py ]; then
      FUNC_LEN_OUT=$(python3 ~/.claude/scripts/quality/check_function_lengths.py --project "$PWD" 2>&1 || true)
  fi
  HAS_FUNC_LEN=$(echo "$FUNC_LEN_OUT" | grep -cE "BLOCKING|violation|>100 lines" || echo "0")

  # Check for complexity violations (if available)
  HAS_COMPLEXITY=0
  if [ -f ~/.claude/scripts/quality/check_complexity.py ]; then
      COMPLEX_OUT=$(python3 ~/.claude/scripts/quality/check_complexity.py --project "$PWD" 2>&1 || true)
      HAS_COMPLEXITY=$(echo "$COMPLEX_OUT" | grep -cE "complexity|violation" || echo "0")
  fi
  ```

  # Execute ONLY the first detected category (priority order: complexity → function-length → file-size)
  IF HAS_COMPLEXITY > 0:
    Output: "=== [RULE: COMPLEXITY] Fixing high-complexity functions ==="

    Task(
      subagent_type="code-quality-analyzer",
      model="sonnet",
      description="Fix complexity violations",
      prompt="Fix high-complexity functions in the codebase.

Quality check output:
{COMPLEX_OUT | head -50}

Target: Cyclomatic complexity < 12 per function

Split complex functions, extract helper methods, simplify conditional logic.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'remaining_issues': N,
  'summary': 'Brief description'
}"
    )

    Output: "✅ RULE_COMPLETE: COMPLEXITY"
    Output: "   Next rule: function-length (if any)"
    Exit 0

  ELIF HAS_FUNC_LEN > 0:
    Output: "=== [RULE: FUNCTION-LENGTH] Fixing long functions ==="

    # Get list of files with function length violations
    VIOLATION_FILES=$(echo "$FUNC_LEN_OUT" | grep -E "BLOCKING|>100 lines" | grep -oE "[a-zA-Z0-9_/]+\.py" | sort -u | head -3)

    Task(
      subagent_type="safe-refactor",
      model="sonnet",
      description="Fix function length violations",
      prompt="Refactor long functions in these files:

Files with violations:
$VIOLATION_FILES

Quality check output:
{FUNC_LEN_OUT | head -50}

Target: Functions < 100 lines

Use TEST-SAFE workflow:
1. Run existing tests, establish GREEN baseline
2. Split long functions using facade pattern
3. Verify tests pass after each change

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'remaining_issues': N,
  'new_structure': {
    'longest_function_lines': N,
    'target_threshold': 100,
    'meets_threshold': true|false
  },
  'summary': 'Brief description'
}"
    )

    Output: "✅ RULE_COMPLETE: FUNCTION-LENGTH"
    Output: "   Next rule: file-size (if any)"
    Exit 0

  ELIF HAS_FILE_SIZE > 0:
    Output: "=== [RULE: FILE-SIZE] Fixing oversized files ==="

    # Get list of files with file size violations
    VIOLATION_FILES=$(echo "$FILE_SIZE_OUT" | grep -E "BLOCKING" | grep -oE "[a-zA-Z0-9_/]+\.py" | sort -u | head -3)

    Task(
      subagent_type="safe-refactor",
      model="sonnet",
      description="Fix file size violations",
      prompt="Refactor oversized files:

Files with violations:
$VIOLATION_FILES

Quality check output:
{FILE_SIZE_OUT | head -50}

Target: Production files < 500 LOC, Test files < 800 LOC

Use TEST-SAFE workflow:
1. Run existing tests, establish GREEN baseline
2. Extract modules using facade pattern
3. Verify tests pass after each change

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'remaining_issues': N,
  'new_structure': {
    'largest_file_loc': N,
    'target_threshold': 500,
    'meets_threshold': true|false
  },
  'summary': 'Brief description'
}"
    )

    Output: "✅ RULE_COMPLETE: FILE-SIZE"
    Exit 0

  ELSE:
    # No violations detected or all categories fixed
    Output: "════════════════════════════════════════════════════════"
    Output: "✅ ALL QUALITY CHECKS PASSING"
    Output: "════════════════════════════════════════════════════════"
    Output: "   All quality rule categories have been addressed."
    Output: "   Codebase meets quality thresholds."
    Exit 0
  END IF

ELSE:
  # ALL-RULES MODE: Original behavior (fix all categories with smart batching)
  Output: "📋 All-rules mode active - fixing all quality violations..."
  PROCEED TO STEP 1.5
END IF
```

---

## STEP 1.5: Load Batch State (if --continue)

If `--continue` flag provided:

### 1. Validate State File Exists and Has Correct Schema

```bash
if [ ! -f .claude/state/code-quality-batch.json ]; then
    echo "ERROR: No saved state found at .claude/state/code-quality-batch.json"
    echo "Run '/code_quality --fix' first to create a state file."
    # EXIT - cannot continue without state
fi

# Check schema version (v2.0 required)
SCHEMA=$(cat .claude/state/code-quality-batch.json | python3 -c "import json,sys; print(json.load(sys.stdin).get('schema_version','1.0'))" 2>/dev/null || echo "1.0")
if [ "$SCHEMA" != "2.0" ]; then
    echo "ERROR: State file uses incompatible schema version ($SCHEMA)"
    echo "State v2.0 required. Delete old state and run fresh analysis:"
    echo "  rm .claude/state/code-quality-batch.json"
    echo "  /code_quality --fix"
    # EXIT - cannot continue with old schema
fi

echo "✓ Valid v2.0 state file found"
cat .claude/state/code-quality-batch.json
```

### 2. Parse Execution Plan (DO NOT re-analyze)

Read the state file and extract:
- `execution_plan.batches` - The ordered batch sequence
- `execution_plan.current_batch` - Next batch number to process
- `clusters` - Full cluster definitions with mode and shared_tests
- `file_status.pending` - Files waiting to be processed

**CRITICAL: DO NOT rebuild dependency graph. Trust the saved execution plan.**

Find the resume point:
```python
# Pseudocode for finding resume point
batches = state["execution_plan"]["batches"]
for batch in batches:
    if batch["status"] != "completed":
        resume_batch = batch
        break
```

### 3. Skip PHASE 1-3 Entirely

When `--continue` is used with valid v2.0 state:
- ❌ DO NOT run quality analysis scripts (STEP 2)
- ❌ DO NOT generate quality report (STEP 3)
- ❌ DO NOT rebuild dependency graph (PHASE 1)
- ❌ DO NOT re-identify clusters (PHASE 2)
- ❌ DO NOT recalculate priorities (PHASE 3)
- ✅ Jump directly to PHASE 4 using saved execution plan

### 4. Display Resume Context

```
╔══════════════════════════════════════════════════════════════╗
║                  RESUMING FROM SAVED STATE                    ║
╠══════════════════════════════════════════════════════════════╣
║  State file:     .claude/state/code-quality-batch.json       ║
║  Schema version: 2.0                                          ║
║  Session ID:     {session_id}                                 ║
╠══════════════════════════════════════════════════════════════╣
║  Progress:                                                    ║
║    Completed batches: {N} of {M}                              ║
║    Files completed:   {X}                                     ║
║    Files remaining:   {Y}                                     ║
╠══════════════════════════════════════════════════════════════╣
║  Next batch: #{batch_number}                                  ║
║    Files: {file_list}                                         ║
║    Mode:  {serial|parallel}                                   ║
║    Reason: {reason if serial}                                 ║
╚══════════════════════════════════════════════════════════════╝
```

### 5. Prompt Before Continuing

```
AskUserQuestion(
  questions=[{
    "question": "Resume batch {N}/{M}? ({X} files: {file_list}) - {mode} mode",
    "header": "Resume Batch",
    "options": [
      {"label": "Yes, resume processing", "description": "Continue from saved state with batch {N}"},
      {"label": "No, abort", "description": "Exit without processing. State preserved for later."},
      {"label": "Start fresh", "description": "Delete state and run new analysis"}
    ],
    "multiSelect": false
  }]
)
```

**On "Yes, resume"**: Jump to PHASE 4 with loaded batch from execution_plan
**On "No, abort"**: Exit gracefully, state file remains intact
**On "Start fresh"**: Delete state file and continue to STEP 2 (full analysis)

---

## STEP 2: Run Quality Analysis

Execute quality check scripts (portable centralized tools with backward compatibility):

```bash
# File size checker - try centralized first, then project-local
# NOTE: Use uv run for Python 3.11+ (tomllib support)
if [ -f ~/.claude/scripts/quality/check_file_sizes.py ]; then
    echo "Running file size check (centralized)..."
    if command -v uv &> /dev/null; then
        uv run python ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD" 2>&1 || true
    else
        python3 ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD" 2>&1 || true
    fi
elif [ -f scripts/check_file_sizes.py ]; then
    echo "⚠️  Using project-local scripts (consider migrating to ~/.claude/scripts/quality/)"
    python3 scripts/check_file_sizes.py 2>&1 || true
elif [ -f scripts/check-file-size.py ]; then
    echo "⚠️  Using project-local scripts (consider migrating to ~/.claude/scripts/quality/)"
    python3 scripts/check-file-size.py 2>&1 || true
else
    echo "✗ File size checker not available"
    echo "  Install: Copy quality tools to ~/.claude/scripts/quality/"
fi
```

```bash
# Function length checker - try centralized first, then project-local
if [ -f ~/.claude/scripts/quality/check_function_lengths.py ]; then
    echo "Running function length check (centralized)..."
    python3 ~/.claude/scripts/quality/check_function_lengths.py --project "$PWD" 2>&1 || true
elif [ -f scripts/check_function_lengths.py ]; then
    echo "⚠️  Using project-local scripts (consider migrating to ~/.claude/scripts/quality/)"
    python3 scripts/check_function_lengths.py 2>&1 || true
elif [ -f scripts/check-function-length.py ]; then
    echo "⚠️  Using project-local scripts (consider migrating to ~/.claude/scripts/quality/)"
    python3 scripts/check-function-length.py 2>&1 || true
else
    echo "✗ Function length checker not available"
    echo "  Install: Copy quality tools to ~/.claude/scripts/quality/"
fi
```

Capture violations into categories:
- **FILE_SIZE_VIOLATIONS**: Files >500 LOC (production) or >800 LOC (tests)
- **FUNCTION_LENGTH_VIOLATIONS**: Functions >100 lines
- **COMPLEXITY_VIOLATIONS**: Functions with cyclomatic complexity >12

---

## STEP 3: Generate Quality Report

Create structured report in this format:

```
## Code Quality Report

### File Size Violations (X files)
| File | LOC | Limit | Status |
|------|-----|-------|--------|
| path/to/file.py | 612 | 500 | BLOCKING |
...

### Function Length Violations (X functions)
| File:Line | Function | Lines | Status |
|-----------|----------|-------|--------|
| path/to/file.py:125 | _process_job() | 125 | BLOCKING |
...

### Test File Warnings (X files)
| File | LOC | Limit | Status |
|------|-----|-------|--------|
| path/to/test.py | 850 | 800 | WARNING |
...

### Summary
- Total violations: X
- Critical (blocking): Y
- Warnings (non-blocking): Z
```

---

## STEP 4: Smart Parallel Refactoring (if --fix or --dry-run flag provided)

### For --dry-run: Show plan without executing

If `--dry-run` flag provided, show the dependency analysis and execution plan:

```
## Dry Run: Refactoring Plan

### PHASE 2: Dependency Analysis
Analyzing imports for 8 violation files...
Building dependency graph...
Mapping test file relationships...

### Identified Clusters

Cluster A (SERIAL - shared tests/test_user.py):
  - user_service.py (612 LOC)
  - user_utils.py (534 LOC)

Cluster B (PARALLEL - independent):
  - auth_handler.py (543 LOC)
  - payment_service.py (489 LOC)
  - notification.py (501 LOC)

### Proposed Schedule
  Batch 1: Cluster B (3 agents in parallel)
  Batch 2: Cluster A (2 agents serial)

### Estimated Time
  - Parallel batch (3 files): ~4 min
  - Serial batch (2 files): ~10 min
  - Total: ~14 min
```

Exit after showing plan (no changes made).

### For --fix: Execute with Dependency-Aware Smart Batching

#### PHASE 0: Warm-Up (Check Dependency Cache)

```bash
# Check if dependency cache exists and is fresh (< 15 min)
CACHE_FILE=".claude/cache/dependency-graph.json"
CACHE_AGE=900  # 15 minutes

if [ -f "$CACHE_FILE" ]; then
    MODIFIED=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null)
    NOW=$(date +%s)
    if [ $((NOW - MODIFIED)) -lt $CACHE_AGE ]; then
        echo "Using cached dependency graph (age: $((NOW - MODIFIED))s)"
    else
        echo "Cache stale, will rebuild"
    fi
else
    echo "No cache found, will build dependency graph"
fi
```

#### PHASE 1: Dependency Graph Construction

Before ANY refactoring agents are spawned:

```bash
echo "=== PHASE 2: Dependency Analysis ==="
echo "Analyzing imports for violation files..."

# For each violating file, find its test dependencies
for FILE in $VIOLATION_FILES; do
    MODULE_NAME=$(basename "$FILE" .py)

    # Find test files that import this module
    TEST_FILES=$(grep -rl "$MODULE_NAME" tests/ --include="test_*.py" 2>/dev/null | sort -u)

    echo "  $FILE -> tests: [$TEST_FILES]"
done

echo ""
echo "Building dependency graph..."
echo "Mapping test file relationships..."
```

#### PHASE 2: Cluster Identification

Group files by shared test files (CRITICAL for safe parallelization):

```bash
# Files sharing test files MUST be serialized
# Files with independent tests CAN be parallelized

# Example output:
echo "
Cluster A (SERIAL - shared tests/test_user.py):
  - user_service.py (612 LOC)
  - user_utils.py (534 LOC)

Cluster B (PARALLEL - independent):
  - auth_handler.py (543 LOC)
  - payment_service.py (489 LOC)
  - notification.py (501 LOC)

Cluster C (SERIAL - shared tests/test_api.py):
  - api_router.py (567 LOC)
  - api_middleware.py (512 LOC)
"
```

#### PHASE 3: Calculate Cluster Priority

Score each cluster for execution order (higher = execute first):

```bash
# +10 points per file with >600 LOC (worst violations)
# +5 points if cluster contains frequently-modified files
# +3 points if cluster is on critical path (imported by many)
# -5 points if cluster only affects test files
```

Sort clusters by priority score (highest first = fail fast on critical code).

#### PHASE 4: Execute Batched Refactoring

For each cluster, respecting parallelization rules:

**Parallel clusters (no shared tests):**
Launch up to `--max-parallel` (default 6) agents simultaneously:

```
Task(
    subagent_type="safe-refactor",
    description="Safe refactor: auth_handler.py",
    prompt="Refactor this file using TEST-SAFE workflow:
    File: auth_handler.py
    Current LOC: 543
    Target threshold: 500 LOC

    CLUSTER CONTEXT (NEW):
    - cluster_id: cluster_b
    - parallel_peers: [payment_service.py, notification.py]
    - test_scope: tests/test_auth.py
    - execution_mode: parallel

    MANDATORY WORKFLOW:
    1. PHASE 0: Run existing tests, establish GREEN baseline
    2. PHASE 1: Create facade structure (tests must stay green)
    3. PHASE 2: Migrate code incrementally (test after each change)
    4. PHASE 3: Update test imports only if necessary
    5. PHASE 4: Cleanup legacy, final test verification
    6. PHASE 5: CRITICAL - Verify largest file < 500 LOC threshold

    CRITICAL RULES:
    - If tests fail at ANY phase, REVERT with git stash pop
    - Use facade pattern to preserve public API
    - Never proceed with broken tests
    - DO NOT modify files outside your scope
    - PHASE 5: MUST check if largest new file < 500 LOC
    - If largest file >= 500 LOC: status MUST be \"partial\" NOT \"fixed\"

    MANDATORY OUTPUT FORMAT - Return ONLY JSON:
    {
      \"status\": \"fixed|partial|failed\",
      \"cluster_id\": \"cluster_b\",
      \"files_modified\": [\"...\"],
      \"test_files_touched\": [\"...\"],
      \"issues_fixed\": N,
      \"remaining_issues\": N,
      \"conflicts_detected\": [],
      \"new_structure\": {
        \"largest_file_loc\": N,
        \"target_threshold\": 500,
        \"meets_threshold\": true/false
      },
      \"tools_invoked\": [\"Edit\", \"MultiEdit\", \"Write\"],
      \"git_diff_files\": [\"list of files from git diff --name-only\"],
      \"verification\": {
        \"git_shows_changes\": true/false,
        \"actual_loc_after\": N
      },
      \"summary\": \"...\"
    }
    DO NOT include full file contents.

    CRITICAL EXECUTION REQUIREMENTS (ANTI-HALLUCINATION):
    1. You MUST actually use Edit/Write/MultiEdit tools - do NOT just produce JSON
    2. BEFORE returning JSON, run: git diff --name-only
    3. If git shows NO changes for target file, your status MUST be \"failed\"
    4. Include actual git diff file list in \"git_diff_files\" field
    5. Your work will be VERIFIED - false success reports will be detected and rejected
    6. If you cannot make changes (file not found, tests fail, etc.), report \"failed\" honestly

    WARNING: The orchestrator will verify your claims using git diff.
    If git shows no changes but you report success, your status will be overridden to \"failed\"."
)
```

**Serial clusters (shared tests):**
Execute ONE agent at a time, wait for completion:

```
# File 1/2: user_service.py
Task(safe-refactor, ...) → wait for completion

# Check result
if result.status == "failed":
    → Invoke FAILURE HANDLER (see below)

# File 2/2: user_utils.py
Task(safe-refactor, ...) → wait for completion
```

#### PHASE 4.5: BATCH GATE (MANDATORY - CRITICAL FOR CONTEXT MANAGEMENT)

**⚠️ HARD STOP: This section MUST be executed after spawning ANY batch of agents.**

After spawning up to 6 agents for the current batch:

**Step 1: Save State (v2.0 Schema)** - Write progress to `.claude/state/code-quality-batch.json`.

**CRITICAL: You MUST serialize ALL fields explicitly. Do NOT use placeholders.**

Create the state directory and write the JSON file:
```bash
mkdir -p .claude/state
```

Then write a JSON file with this EXACT structure (substitute actual values):

```json
{
  "schema_version": "2.0",
  "session_id": "{unix_timestamp}",
  "created_at": "{ISO8601_datetime}",
  "updated_at": "{ISO8601_datetime}",
  "project_path": "{absolute_project_path}",

  "analysis": {
    "total_violations": {count},
    "file_size_violations": {count},
    "function_length_violations": {count}
  },

  "execution_plan": {
    "total_batches": {N},
    "current_batch": {N},
    "batches": [
      {
        "batch_number": 1,
        "cluster_id": "{cluster_id}",
        "files": ["{file1.py}", "{file2.py}"],
        "mode": "parallel|serial",
        "status": "completed|in_progress|pending",
        "completed_at": "{ISO8601 or null}",
        "reason": "{why serial, if applicable}"
      }
    ]
  },

  "clusters": [
    {
      "id": "{cluster_id}",
      "files": ["{file1.py}", "{file2.py}"],
      "mode": "serial|parallel",
      "shared_tests": ["{test_file.py}"],
      "priority_score": {N}
    }
  ],

  "file_status": {
    "completed": [
      {"file": "{path}", "original_loc": {N}, "new_loc": {N}, "batch": {N}}
    ],
    "pending": ["{file1.py}", "{file2.py}"],
    "failed": [{"file": "{path}", "error": "{message}"}],
    "skipped": [{"file": "{path}", "reason": "{user_choice}"}]
  }
}
```

**MANDATORY SERIALIZATION CHECKLIST** (verify before writing):

| Field | Source | Required |
|-------|--------|----------|
| `schema_version` | Always "2.0" | ✅ |
| `execution_plan.batches` | From PHASE 2 cluster analysis | ✅ |
| `execution_plan.batches[].mode` | "serial" if shared_tests, else "parallel" | ✅ |
| `execution_plan.batches[].status` | Track as batches complete | ✅ |
| `clusters` | From PHASE 2 cluster identification | ✅ |
| `clusters[].shared_tests` | From dependency graph (can be empty array) | ✅ |
| `file_status.pending` | Files not yet processed | ✅ |

**If ANY field is missing, --continue WILL FAIL in the next session.**

**Step 2: Wait for Current Batch** - Use TaskOutput to block until ALL spawned agents complete:
```
# MANDATORY: Wait for each agent spawned in this batch
# The Task tool returns agent IDs that can be used with TaskOutput

for each agent_id in spawned_agents:
    TaskOutput(task_id=agent_id, block=true, timeout=300000)
    # Parse result and update state
```

### MANDATORY: Verify Agent Actually Made Changes (CRITICAL FIX)

**After EACH agent completes, IMMEDIATELY verify git state before recording to state file:**

```bash
# For each file the agent claimed to have modified:
TARGET_FILE="{file_from_agent_result}"

# Check if git shows actual modifications
if git diff --name-only | grep -q "$TARGET_FILE"; then
    echo "VERIFIED: $TARGET_FILE was actually modified by git diff"
    # Also verify file size actually changed
    ACTUAL_LOC=$(wc -l < "$TARGET_FILE" 2>/dev/null | tr -d ' ')
    echo "Actual LOC after refactor: $ACTUAL_LOC"

    if [ "$ACTUAL_LOC" -ge "{agent_claimed_original_loc}" ]; then
        echo "WARNING: LOC did not decrease as claimed"
        AGENT_STATUS="partial"
    fi
else
    echo "FAILURE: Agent reported success but NO GIT CHANGES detected for $TARGET_FILE"
    echo "Agent may have hallucinated the refactoring"
    # OVERRIDE agent status - this is CRITICAL
    AGENT_STATUS="failed"
    FAILURE_REASON="Agent reported success but git shows no modifications"
fi
```

**State File Recording Rules:**
1. If git shows NO changes for target file → **status = "failed"**, add to `file_status.failed`
2. If git shows changes but LOC didn't decrease → **status = "partial"**
3. If git shows changes AND LOC decreased → **status = "fixed"** (accept agent result)
4. **NEVER record "completed" status without git verification**

**MANDATORY: Run Verification Script (ANTI-HALLUCINATION GATE)**

⚠️ **NEVER skip this step. Without verification, agent hallucinations go undetected.**

```bash
# MANDATORY: Verify EVERY file claim before recording to state
for TARGET_FILE in {list_of_files_from_agent_batch}; do
    echo "Verifying: $TARGET_FILE"
    python ~/.claude/scripts/quality/verify_refactoring.py --git-check "$TARGET_FILE"

    if [ $? -ne 0 ]; then
        echo "HALLUCINATION DETECTED: $TARGET_FILE - overriding status to failed"
        # Override agent status for this file
        AGENT_STATUS="failed"
        FAILURE_REASON="Hallucination: git shows no changes despite agent claiming success"
    fi
done

# Also verify all completed entries in state file (run after batch completes)
python ~/.claude/scripts/quality/verify_refactoring.py --state-file .claude/state/code-quality-batch.json --json
```

**CRITICAL ENFORCEMENT:**
- If `verify_refactoring.py` returns exit code 1 → Agent hallucinated
- Override agent's claimed status to "failed"
- Add to `file_status.failed` array with reason "hallucination_detected"
- DO NOT record to `file_status.completed`

If verification fails, the entry is a hallucination and MUST be moved to `file_status.failed`.

### Step 2.4: AUTO-RALPH ON HALLUCINATION (Default Behavior)

**When hallucination is detected, automatically invoke Ralph Loop for self-correction:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  HYBRID APPROACH: Verify-First, Ralph-on-Failure                    │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                     │
│  PHASE 1: Single-shot agent attempts refactor                       │
│                      ↓                                              │
│  PHASE 2: MANDATORY git verification                                │
│                      ↓                                              │
│  ┌─────────────────┐    ┌───────────────────────────────────────┐  │
│  │ Git shows       │───▶│ YES: Record success, proceed          │  │
│  │ actual changes? │    │                                       │  │
│  │                 │───▶│ NO:  AUTO-INVOKE RALPH (up to 3x)     │  │
│  └─────────────────┘    └───────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

**Auto-Ralph Implementation:**

```bash
# After single-shot agent completes and hallucination is detected
HALLUCINATED_FILES=()

for TARGET_FILE in {list_of_files_from_agent_batch}; do
    python ~/.claude/scripts/quality/verify_refactoring.py --git-check "$TARGET_FILE"
    if [ $? -ne 0 ]; then
        echo "HALLUCINATION DETECTED: $TARGET_FILE"
        HALLUCINATED_FILES+=("$TARGET_FILE")
    fi
done

# AUTO-INVOKE RALPH for hallucinated files (unless --no-ralph flag set)
if [ ${#HALLUCINATED_FILES[@]} -gt 0 ] && [ "$NO_RALPH" != "true" ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  AUTO-RALPH ACTIVATED: ${#HALLUCINATED_FILES[@]} files need self-correction  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"

    for FILE in "${HALLUCINATED_FILES[@]}"; do
        echo "Starting Ralph Loop for: $FILE"
        # Invoke Ralph Loop (see STEP 4-RALPH for details)
        # Ralph will iterate until git verification succeeds or max-iterations reached
    done
fi
```

**Ralph Auto-Invocation Rules:**

| Condition | Action |
|-----------|--------|
| Hallucination detected + no `--no-ralph` | Auto-invoke Ralph Loop |
| Hallucination detected + `--no-ralph` set | Mark as failed, user must retry manually |
| Git shows changes | Record success, skip Ralph |
| Ralph exhausts max-iterations (3) | Mark as failed, require manual intervention |

**Why This Is Now Default:**

Research from the hallucination incident showed:
- Single-shot agents have ~75% hallucination rate without context pressure
- Ralph's iterative self-correction catches 100% of hallucinations
- Cost increase is only ~2-3x per hallucinated file (not all files)
- Hybrid approach balances speed (single-shot first) with reliability (Ralph fallback)

**To DISABLE auto-Ralph:** Use `--no-ralph` flag
```bash
/code_quality --fix --no-ralph  # Pure single-shot, fail on hallucination
```

### Step 2.5: Verify Git Stash State (CRITICAL - Prevents Orphaned Stashes)

**After EACH agent completes, verify no orphaned stashes remain:**

```bash
# Check for orphaned safe-refactor or mikado stashes
ORPHANED_STASHES=$(git stash list | grep -E "safe-refactor|mikado-" | head -5)

if [ -n "$ORPHANED_STASHES" ]; then
    echo "WARNING: Orphaned stash detected - agent did not cleanup properly"
    echo "Orphaned stashes:"
    echo "$ORPHANED_STASHES"

    # Check agent's stash_cleanup field
    AGENT_STASH_STATE="{from agent JSON: stash_cleanup field}"

    if [ "$AGENT_STASH_STATE" == "dropped" ] || [ "$AGENT_STASH_STATE" == "none" ]; then
        echo "ERROR: Agent claimed stash_cleanup='$AGENT_STASH_STATE' but orphaned stashes exist"
        echo "This indicates a workflow bug in the agent"
        # Flag this for review but don't fail - work may still be valid
    fi

    # AUTO-RECOVERY: Pop the stash if it contains the refactored work
    echo ""
    echo "Checking if stash contains the expected changes..."
    STASH_REF=$(git stash list | grep "safe-refactor-baseline" | head -1 | cut -d: -f1)
    if [ -n "$STASH_REF" ]; then
        # Show what's in the stash
        git stash show "$STASH_REF" 2>/dev/null || true

        # If working tree has NO changes but stash exists, the work is likely hidden
        if [ -z "$(git diff --name-only)" ]; then
            echo "ALERT: Working tree is clean but stash exists - work may be hidden in stash"
            echo "Attempting auto-recovery with git stash pop..."
            git stash pop "$STASH_REF"

            # Verify recovery worked
            if [ -n "$(git diff --name-only)" ]; then
                echo "SUCCESS: Recovered hidden work from stash"
                AGENT_STATUS="fixed"  # Upgrade status since work was recovered
            else
                echo "WARNING: Stash pop succeeded but still no changes detected"
            fi
        fi
    fi
else
    echo "✓ Git stash state is clean (no orphaned stashes)"
fi
```

**Stash State Recording Rules:**
1. If `stash_cleanup == "dropped"` and no orphaned stashes → Expected state, record as-is
2. If `stash_cleanup == "none"` and no orphaned stashes → Acceptable, but unusual
3. If `stash_cleanup == "warning_orphaned"` → Agent detected issue, investigate
4. If `stash_cleanup == "preserved_for_rollback"` → Failure case, stash intentionally kept
5. If orphaned stashes exist but agent claimed "dropped" → **Workflow bug, flag for review**

**Step 3: STOP AND PROMPT USER** - Do NOT proceed to next batch automatically:
```
AskUserQuestion(
  questions=[{
    "question": "Batch {N}/{M} complete. {X} files refactored, {Y} remaining, {Z} failed. Continue to next batch?",
    "header": "Batch Gate",
    "options": [
      {"label": "Continue next batch", "description": "Process next batch (up to 6 files)"},
      {"label": "Stop here", "description": "Save state and exit. Run /code_quality --continue to resume later."}
    ],
    "multiSelect": false
  }]
)
```

**Step 4: Handle User Decision**

**On "Stop here":**
- Update state file with final status
- Report progress summary
- Output: "Progress saved. Run `/code_quality --continue` to resume."
- EXIT the command (do NOT continue)

**On "Continue":**
- Increment current_batch counter
- Process ONLY the next batch (max 6 agents)
- Return to Step 1 (BATCH GATE repeats after each batch)

**WHY THIS IS MANDATORY:**
```
┌────────────────────────────────────────────────────────┐
│  PREVENTS CONTEXT WINDOW EXPLOSION                     │
│  ──────────────────────────────────────────────────── │
│  • Each batch uses ~10-20% of context window          │
│  • 3+ simultaneous batches = overflow                 │
│  • BATCH GATE ensures ONE batch per context window    │
│  • User controls when to continue                     │
│  • Recovery possible from any failure                 │
└────────────────────────────────────────────────────────┘
```

**ENFORCEMENT RULES:**
- ❌ NEVER spawn more than 6 agents in a single response
- ❌ NEVER continue to next batch without user confirmation
- ❌ NEVER skip state saving between batches
- ✅ ALWAYS wait for all agents with TaskOutput before prompting
- ✅ ALWAYS save state before prompting user
- ✅ ALWAYS respect user's "Stop here" decision

#### PHASE 5: Failure Handling (Interactive)

When a refactoring agent fails, use AskUserQuestion to prompt:

```
AskUserQuestion(
  questions=[{
    "question": "Refactoring of {file} failed: {error}. {N} files remain. What would you like to do?",
    "header": "Failure",
    "options": [
      {"label": "Continue with remaining files", "description": "Skip {file} and proceed with remaining {N} files"},
      {"label": "Abort refactoring", "description": "Stop now, preserve current state"},
      {"label": "Retry this file", "description": "Attempt to refactor {file} again"}
    ],
    "multiSelect": false
  }]
)
```

**On "Continue"**: Add file to skipped list, continue with next
**On "Abort"**: Clean up locks, report final status, exit
**On "Retry"**: Re-attempt (max 2 retries per file)

#### PHASE 6: Early Termination Check (After Each Batch)

After completing high-priority clusters, check if user wants to terminate early:

```bash
# Calculate completed vs remaining priority
COMPLETED_PRIORITY=$(sum of completed cluster priorities)
REMAINING_PRIORITY=$(sum of remaining cluster priorities)
TOTAL_PRIORITY=$((COMPLETED_PRIORITY + REMAINING_PRIORITY))

# If 80%+ of priority work complete, offer early exit
if [ $((COMPLETED_PRIORITY * 100 / TOTAL_PRIORITY)) -ge 80 ]; then
    # Prompt user
    AskUserQuestion(
      questions=[{
        "question": "80%+ of high-priority violations fixed. Complete remaining low-priority work?",
        "header": "Progress",
        "options": [
          {"label": "Complete all remaining", "description": "Fix remaining {N} files (est. {time})"},
          {"label": "Terminate early", "description": "Stop now, save ~{time}. Remaining files can be fixed later."}
        ],
        "multiSelect": false
      }]
    )
fi
```

---

## STEP 5: Parallel-Safe Operations (Linting, Type Errors)

These operations are ALWAYS safe to parallelize (no shared state):

**For linting issues -> delegate to existing `linting-fixer`:**
```
Task(
    subagent_type="linting-fixer",
    description="Fix linting errors",
    prompt="Fix all linting errors found by ruff check and eslint."
)
```

**For type errors -> delegate to existing `type-error-fixer`:**
```
Task(
    subagent_type="type-error-fixer",
    description="Fix type errors",
    prompt="Fix all type errors found by mypy and tsc."
)
```

These can run IN PARALLEL with each other and with safe-refactor agents (different file domains).

---

## STEP 6: Verify Results and Update Exceptions (after --fix)

After agents complete, re-run analysis to verify fixes AND update stale exceptions:

### 6.1: Re-run Quality Checks

```bash
# Re-run file size check
if [ -f ~/.claude/scripts/quality/check_file_sizes.py ]; then
    if command -v uv &> /dev/null; then
        uv run python ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD"
    else
        python3 ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD"
    fi
elif [ -f scripts/check_file_sizes.py ]; then
    python3 scripts/check_file_sizes.py
elif [ -f scripts/check-file-size.py ]; then
    python3 scripts/check-file-size.py
fi
```

```bash
# Re-run function length check
if [ -f ~/.claude/scripts/quality/check_function_lengths.py ]; then
    python3 ~/.claude/scripts/quality/check_function_lengths.py --project "$PWD"
elif [ -f scripts/check_function_lengths.py ]; then
    python3 scripts/check_function_lengths.py
elif [ -f scripts/check-function-length.py ]; then
    python3 scripts/check-function-length.py
fi
```

### 6.2: Refresh Stale Exceptions (MANDATORY after --fix)

**CRITICAL:** After successful refactoring, regenerate exception baselines to remove stale entries.
This prevents the exceptions file from becoming outdated with functions that have already been fixed.

```bash
echo "=== REFRESHING EXCEPTION BASELINES ==="

# Count exceptions BEFORE refresh
BEFORE_FILE=$(cat .file-size-exceptions 2>/dev/null | grep -c '"file":' || echo "0")
BEFORE_FUNC=$(cat .function-length-exceptions 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('exceptions',{})))" 2>/dev/null || echo "0")

# Regenerate file size exceptions (if script supports it)
if [ -f ~/.claude/scripts/quality/check_file_sizes.py ]; then
    if command -v uv &> /dev/null; then
        uv run python ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD" --generate-baseline 2>/dev/null || true
    else
        python3 ~/.claude/scripts/quality/check_file_sizes.py --project "$PWD" --generate-baseline 2>/dev/null || true
    fi
fi

# Regenerate function length exceptions
if [ -f ~/.claude/scripts/quality/check_function_lengths.py ]; then
    # Use uv if available (for Python 3.10+ syntax), otherwise python3
    if command -v uv &> /dev/null; then
        uv run python ~/.claude/scripts/quality/check_function_lengths.py --project "$PWD" --generate-baseline
    else
        python3 ~/.claude/scripts/quality/check_function_lengths.py --project "$PWD" --generate-baseline
    fi
fi

# Count exceptions AFTER refresh
AFTER_FILE=$(cat .file-size-exceptions 2>/dev/null | grep -c '"file":' || echo "0")
AFTER_FUNC=$(cat .function-length-exceptions 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('exceptions',{})))" 2>/dev/null || echo "0")

# Report changes
echo ""
echo "Exception file updates:"
echo "  File size:      $BEFORE_FILE -> $AFTER_FILE ($(($BEFORE_FILE - $AFTER_FILE)) stale entries removed)"
echo "  Function length: $BEFORE_FUNC -> $AFTER_FUNC ($(($BEFORE_FUNC - $AFTER_FUNC)) stale entries removed)"
```

**Why this is mandatory:**
- Exceptions files track "grandfathered" violations that existed before enforcement
- When functions are refactored below the threshold, their exceptions become stale
- Stale exceptions cause confusion: `/code_quality --fix` reports violations that don't exist
- Automatic refresh ensures the exceptions file always reflects current codebase state

---

## STEP 7: Report Summary

Output final status:

```
## Code Quality Summary

### Execution Mode
- Dependency-aware smart batching: YES
- Clusters identified: 3
- Parallel batches: 1
- Serial batches: 2

### Before
- File size violations: X
- Function length violations: Y
- Test file warnings: Z

### After (if --fix was used)
- File size violations: A
- Function length violations: B
- Test file warnings: C

### Refactoring Results
| Cluster | Files | Mode | Status |
|---------|-------|------|--------|
| Cluster B | 3 | parallel | COMPLETE |
| Cluster A | 2 | serial | 1 skipped |
| Cluster C | 3 | serial | COMPLETE |

### Skipped Files (user decision)
- user_utils.py: TestFailed (user chose continue)

### Status
[PASS/FAIL based on blocking violations]

### Time Breakdown
- Dependency analysis: ~30s
- Parallel batch (3 files): ~4 min
- Serial batches (5 files): ~15 min
- Total: ~20 min (saved ~8 min vs fully serial)

### Suggested Next Steps
- If violations remain: Run `/code_quality --fix` to auto-fix
- If all passing: Run `/pr --fast` to commit changes
- For skipped files: Run `/test_orchestrate` to investigate test failures
```

---

## STEP 8: Chain Invocation (unless --no-chain)

If all tests passing after refactoring:

```bash
# Check if chaining disabled
if [[ "$ARGUMENTS" != *"--no-chain"* ]]; then
    # Check depth to prevent infinite loops
    DEPTH=${SLASH_DEPTH:-0}
    if [ $DEPTH -lt 3 ]; then
        export SLASH_DEPTH=$((DEPTH + 1))
        SlashCommand(command="/commit_orchestrate --message 'refactor: reduce file sizes'")
    fi
fi
```

---

## Observability & Logging

Log all orchestration decisions to `.claude/logs/orchestration-{date}.jsonl`:

```json
{"event": "cluster_scheduled", "cluster_id": "cluster_b", "files": ["auth.py", "payment.py"], "mode": "parallel", "priority": 18}
{"event": "batch_started", "batch": 1, "agents": 3, "cluster_id": "cluster_b"}
{"event": "agent_completed", "file": "auth.py", "status": "fixed", "duration_s": 240}
{"event": "failure_handler_invoked", "file": "user_utils.py", "error": "TestFailed"}
{"event": "user_decision", "action": "continue", "remaining": 3}
{"event": "early_termination_offered", "completed_priority": 45, "remaining_priority": 10}
```

---

## Examples

```
# Check only (default)
/code_quality

# Check with specific focus
/code_quality --focus=file-size

# Preview refactoring plan (no changes made)
/code_quality --dry-run

# Auto-fix all violations with smart batching (default max 6 parallel)
/code_quality --fix

# Auto-fix with lower parallelism (e.g., resource-constrained)
/code_quality --fix --max-parallel=3

# Auto-fix only Python backend
/code_quality --fix --path=apps/api

# Auto-fix without chain invocation
/code_quality --fix --no-chain

# Preview plan for specific path
/code_quality --dry-run --path=apps/web

# Refresh stale exceptions (remove entries for already-fixed functions)
/code_quality --refresh-exceptions

# Resume from previous batch
/code_quality --continue

# Force Ralph Loop for ALL files (skip single-shot attempt)
/code_quality --fix --ralph

# Disable auto-Ralph fallback (fail on hallucination instead of retry)
/code_quality --fix --no-ralph
```

**Default behavior (recommended):**
```bash
/code_quality --fix  # Single-shot first → auto-Ralph on hallucination detection
```

---

## STEP 4-RALPH: Ralph Loop Mode (DEFAULT FALLBACK or --ralph flag)

**ACTIVATION:**
- **Automatic (DEFAULT):** When single-shot agent hallucination is detected (git shows no changes)
- **Forced:** When `--ralph` flag is provided (skip single-shot, go straight to Ralph)
- **Disabled:** When `--no-ralph` flag is provided (fail on hallucination, no retry)

Ralph Loop provides **iterative self-correction**. If an agent hallucinates:
1. Agent claims to have modified file
2. Stop hook intercepts exit
3. Same prompt fed again
4. Agent sees UNCHANGED file and realizes work wasn't done
5. Agent actually performs the work

### Ralph Mode Workflow

For each file in violation list, spawn a Ralph loop instead of single-shot agent:

```
SlashCommand(command="/ralph-loop \"
Refactor {file_path} to reduce function length violations.

Target: Functions should be <100 lines

MANDATORY STEPS:
1. Read the file: Read({file_path})
2. Identify functions >100 lines
3. Split each long function using Edit/MultiEdit tools
4. Run verification: git diff --name-only | grep {file_path}
5. Check result: wc -l {file_path}

OUTPUT PROMISE:
Only output <promise>REFACTOR VERIFIED</promise> when BOTH conditions are true:
- git diff shows {file_path} was modified
- Functions in {file_path} are now <100 lines

If verification fails, continue refactoring. Do NOT output the promise until verified.
\" --max-iterations 5 --completion-promise \"REFACTOR VERIFIED\"")
```

### Ralph Mode Benefits

| Aspect | Single-Shot Agent | Ralph Loop |
|--------|-------------------|------------|
| Hallucination risk | HIGH | LOW |
| Self-correction | NONE | AUTOMATIC |
| Verification | Optional | Built-in |
| Failure handling | Manual | Iterative |

### Ralph Mode Behavior Summary

| Scenario | Behavior |
|----------|----------|
| **Default (no flag)** | Single-shot first → Auto-Ralph on hallucination |
| **`--ralph` flag** | Skip single-shot → Ralph for ALL files |
| **`--no-ralph` flag** | Single-shot only → Fail on hallucination (no retry) |

**Force `--ralph` when:**
- You want maximum reliability regardless of cost
- Previous session had 50%+ hallucination rate
- Critical refactoring that MUST succeed first time

**Use `--no-ralph` when:**
- Debugging single-shot behavior
- Cost-sensitive batch processing
- You'll manually retry failed files

---

## Conflict Detection Quick Reference

| Operation Type | Parallelizable? | Reason |
|----------------|-----------------|--------|
| Linting fixes | YES | Independent, no test runs |
| Type error fixes | YES | Independent, no test runs |
| Import fixes | PARTIAL | May conflict on same files |
| **File refactoring** | **CONDITIONAL** | Depends on shared tests |

**Safe to parallelize (different clusters, no shared tests)**
**Must serialize (same cluster, shared test files)**

---

## Batch Progress Display

After each batch completes, show progress:

```
╔══════════════════════════════════════════════════════════╗
║                    BATCH PROGRESS                        ║
╠══════════════════════════════════════════════════════════╣
║  Batch:       2 of 4                                     ║
║  Completed:   6 files                                    ║
║  Pending:     9 files                                    ║
║  Failed:      1 file                                     ║
║  Skipped:     0 files                                    ║
╠══════════════════════════════════════════════════════════╣
║  Status:      Waiting for user confirmation              ║
║  Est. remaining batches: 2                               ║
╚══════════════════════════════════════════════════════════╝

To continue: Select "Continue next batch" when prompted
To stop: Select "Stop here" - state will be saved
To resume later: Run `/code_quality --continue`
```

---

## State File Format (v2.0)

**Location:** `.claude/state/code-quality-batch.json`

**Schema Version:** 2.0 (required for `--continue` to work)

```json
{
  "schema_version": "2.0",
  "session_id": "1704067200",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T01:30:00Z",
  "project_path": "/path/to/project",

  "analysis": {
    "total_violations": 15,
    "file_size_violations": 8,
    "function_length_violations": 7
  },

  "execution_plan": {
    "total_batches": 4,
    "current_batch": 2,
    "batches": [
      {
        "batch_number": 1,
        "cluster_id": "cluster_b",
        "files": ["auth_handler.py", "payment.py", "notification.py"],
        "mode": "parallel",
        "status": "completed",
        "completed_at": "2024-01-01T00:30:00Z",
        "reason": null
      },
      {
        "batch_number": 2,
        "cluster_id": "cluster_a",
        "files": ["user_service.py", "user_utils.py"],
        "mode": "serial",
        "status": "pending",
        "completed_at": null,
        "reason": "shared test: tests/test_user.py"
      }
    ]
  },

  "clusters": [
    {
      "id": "cluster_a",
      "files": ["user_service.py", "user_utils.py"],
      "mode": "serial",
      "shared_tests": ["tests/test_user.py"],
      "priority_score": 15
    },
    {
      "id": "cluster_b",
      "files": ["auth_handler.py", "payment.py", "notification.py"],
      "mode": "parallel",
      "shared_tests": [],
      "priority_score": 18
    }
  ],

  "file_status": {
    "completed": [
      {"file": "auth_handler.py", "original_loc": 543, "new_loc": 245, "batch": 1},
      {"file": "payment.py", "original_loc": 489, "new_loc": 210, "batch": 1},
      {"file": "notification.py", "original_loc": 501, "new_loc": 198, "batch": 1}
    ],
    "pending": ["user_service.py", "user_utils.py"],
    "failed": [],
    "skipped": []
  }
}
```

### Required Fields for --continue

| Field | Purpose | If Missing |
|-------|---------|------------|
| `schema_version` | Must be "2.0" | --continue fails |
| `execution_plan.batches` | Ordered batch sequence | Cannot determine resume point |
| `execution_plan.batches[].status` | Track completion | Cannot identify next batch |
| `clusters` | Dependency groupings | Cannot reconstruct batching logic |
| `clusters[].mode` | serial vs parallel | Cannot safely spawn agents |
| `clusters[].shared_tests` | Why serial | Missing context on resume |
| `file_status.pending` | What's left to do | Cannot show progress |

### Schema Migration

Old v1.0 state files (without `schema_version` or with flat arrays) are **NOT compatible**.

If you have an old state file, delete it and run fresh:
```bash
rm .claude/state/code-quality-batch.json
/code_quality --fix
```

---

## Context Window Protection Summary

| Protection | Mechanism |
|------------|-----------|
| Max agents per batch | 6 (hard limit) |
| Batch gate | AskUserQuestion after each batch |
| State persistence | JSON file between batches |
| User control | Confirmation before every batch |
| Recovery | `--continue` flag to resume |

**No bypass available** - Every batch requires explicit user confirmation.
