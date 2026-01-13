---
description: "Orchestrate CI/CD pipeline fixes through parallel specialist agent deployment"
argument-hint: "[issue] [--fix-all] [--strategic] [--research] [--docs] [--force-escalate] [--check-actions] [--quality-gates] [--performance] [--only-stage=<stage>] [--loop N] [--loop-delay S] [--fix-single-category]"
allowed-tools: ["Task", "TodoWrite", "Bash", "Grep", "Read", "LS", "Glob", "SlashCommand", "WebSearch", "WebFetch"]
---

## 🎯 TWO-MODE ORCHESTRATION

This command operates in two modes:

### Mode 1: TACTICAL (Default)
- Fix immediate CI failures fast
- Delegate to specialist fixers
- Parallel execution for speed

### Mode 2: STRATEGIC (Flag-triggered or Auto-escalated)
- Research best practices via web search
- Root cause analysis with Five Whys
- Create infrastructure improvements
- Generate documentation and runbooks
- Then proceed with tactical fixes

**Trigger Strategic Mode:**
- `--strategic` flag: Full research + infrastructure + docs
- `--research` flag: Research best practices only
- `--docs` flag: Generate runbook/strategy docs only
- `--force-escalate` flag: Force strategic mode regardless of history
- Auto-detect phrases: "comprehensive", "strategic", "root cause", "analyze", "review"
- Auto-escalate: After 3+ failures on same branch (checks git history)

### Mode 3: TARGETED STAGE EXECUTION (--only-stage)
When debugging a specific CI stage failure, skip earlier stages for faster iteration:

**Usage:**
- `--only-stage=<stage-name>` - Skip to a specific stage (e.g., `e2e`, `test`, `build`)
- Stage names are detected dynamically from the project's CI workflow

**How It Works:**
1. Detects CI platform (GitHub Actions, GitLab CI, etc.)
2. Reads workflow file to find available stages/jobs
3. Uses platform-specific mechanism to trigger targeted run:
   - GitHub Actions: `workflow_dispatch` with inputs
   - GitLab CI: Manual trigger with variables
   - Other: Fallback to manual guidance

**When to Use:**
- Late-stage tests failing but early stages pass → skip to failing stage
- Iterating on test fixes → target specific test job
- Once fixed, remove flag to run full pipeline

**Project Requirements:**
For GitHub Actions projects to support `--only-stage`, the CI workflow should have:
```yaml
on:
  workflow_dispatch:
    inputs:
      skip_to_stage:
        type: choice
        options: [all, validate, test, e2e]  # Your stage names
```

**⚠️ Important:** Skipped stages show as "skipped" (not failed) in the CI UI. The workflow maintains proper dependency graph.

---

## 🚨 CRITICAL ORCHESTRATION CONSTRAINTS 🚨

**YOU ARE A PURE ORCHESTRATOR - DELEGATION ONLY**
- ❌ NEVER fix code directly - you are a pure orchestrator
- ❌ NEVER use Edit, Write, or MultiEdit tools
- ❌ NEVER attempt to resolve issues yourself
- ✅ MUST delegate ALL fixes to specialist agents via Task tool
- ✅ Your role is ONLY to analyze, delegate, and verify
- ✅ Use bash commands for READ-ONLY ANALYSIS ONLY

**GUARD RAIL CHECK**: Before ANY action ask yourself:
- "Am I about to fix code directly?" → If YES: STOP and delegate instead
- "Am I using analysis tools (bash/grep/read) to understand the problem?" → OK to proceed
- "Am I using Task tool to delegate fixes?" → Correct approach

You must now execute the following CI/CD orchestration procedure for: "$ARGUMENTS"

## STEP 0: MODE DETECTION & AUTO-ESCALATION

**STEP 0.1: Parse Mode Flags**
Check "$ARGUMENTS" for strategic mode triggers:
```bash
# Check for explicit flags
STRATEGIC_MODE=false
RESEARCH_ONLY=false
DOCS_ONLY=false
TARGET_STAGE="all"  # Default: run all stages

if [[ "$ARGUMENTS" =~ "--strategic" ]] || [[ "$ARGUMENTS" =~ "--force-escalate" ]]; then
    STRATEGIC_MODE=true
fi
if [[ "$ARGUMENTS" =~ "--research" ]]; then
    RESEARCH_ONLY=true
    STRATEGIC_MODE=true
fi
if [[ "$ARGUMENTS" =~ "--docs" ]]; then
    DOCS_ONLY=true
fi

# Parse --only-stage flag for targeted execution
if [[ "$ARGUMENTS" =~ "--only-stage="([a-z]+) ]]; then
    TARGET_STAGE="${BASH_REMATCH[1]}"
    echo "🎯 Targeted execution mode: Skip to stage '$TARGET_STAGE'"
fi

# Check for strategic phrases (auto-detect intent)
if [[ "$ARGUMENTS" =~ (comprehensive|strategic|root.cause|analyze|review|recurring|systemic) ]]; then
    echo "🔍 Detected strategic intent in request. Enabling strategic mode..."
    STRATEGIC_MODE=true
fi
```

**STEP 0.1.5: Execute Targeted Stage (if --only-stage specified)**
If targeting a specific stage, detect CI platform and trigger appropriately:

```bash
if [[ "$TARGET_STAGE" != "all" ]]; then
    echo "🚀 Targeted stage execution: $TARGET_STAGE"

    # Detect CI platform and workflow file
    CI_PLATFORM=""
    WORKFLOW_FILE=""

    if [ -d ".github/workflows" ]; then
        CI_PLATFORM="github"
        # Find main CI workflow (prefer ci.yml, then any workflow with 'ci' or 'test' in name)
        if [ -f ".github/workflows/ci.yml" ]; then
            WORKFLOW_FILE="ci.yml"
        elif [ -f ".github/workflows/ci.yaml" ]; then
            WORKFLOW_FILE="ci.yaml"
        else
            WORKFLOW_FILE=$(ls .github/workflows/*.{yml,yaml} 2>/dev/null | head -1 | xargs basename)
        fi
    elif [ -f ".gitlab-ci.yml" ]; then
        CI_PLATFORM="gitlab"
        WORKFLOW_FILE=".gitlab-ci.yml"
    elif [ -f "azure-pipelines.yml" ]; then
        CI_PLATFORM="azure"
    fi

    if [ -z "$CI_PLATFORM" ]; then
        echo "⚠️ Could not detect CI platform. Manual trigger required."
        echo "   Common CI files: .github/workflows/*.yml, .gitlab-ci.yml"
        exit 1
    fi

    echo "📋 Detected: $CI_PLATFORM CI (workflow: $WORKFLOW_FILE)"

    # Platform-specific trigger
    case "$CI_PLATFORM" in
        github)
            # Check if workflow supports skip_to_stage input
            if grep -q "skip_to_stage" ".github/workflows/$WORKFLOW_FILE" 2>/dev/null; then
                echo "✅ Workflow supports skip_to_stage input"

                gh workflow run "$WORKFLOW_FILE" \
                    --ref "$(git branch --show-current)" \
                    -f skip_to_stage="$TARGET_STAGE"

                echo "✅ Workflow triggered. View at:"
                sleep 3
                gh run list --workflow="$WORKFLOW_FILE" --limit=1 --json url,status | \
                    jq -r '.[0] | "   Status: \(.status) | URL: \(.url)"'
            else
                echo "⚠️ Workflow does not support skip_to_stage input."
                echo "   To enable, add to workflow file:"
                echo ""
                echo "   on:"
                echo "     workflow_dispatch:"
                echo "       inputs:"
                echo "         skip_to_stage:"
                echo "           type: choice"
                echo "           options: [all, $TARGET_STAGE]"
                exit 1
            fi
            ;;
        gitlab)
            echo "📌 GitLab CI: Use web UI or 'glab ci run' with variables"
            echo "   Example: glab ci run -v SKIP_TO_STAGE=$TARGET_STAGE"
            ;;
        *)
            echo "📌 $CI_PLATFORM: Check platform docs for targeted stage execution"
            ;;
    esac

    echo ""
    echo "💡 Tip: Once fixed, run without --only-stage to verify full pipeline"
    exit 0
fi
```

**STEP 0.1.6: Ralph Loop Mode Detection (Fresh Context)**

If `--loop` is present in arguments, execute fresh-context loop instead of normal flow.

This enables unattended/overnight CI fixing by spawning NEW Claude instances per iteration.

```
IF "$ARGUMENTS" contains "--loop":

  # Extract loop parameters
  loop_max = extract_number_after("--loop", default=10)
  loop_delay = extract_number_after("--loop-delay", default=5)

  # Determine inner command flags (preserve all except --loop)
  inner_flags = "$ARGUMENTS" without "--loop" and "--loop-delay"

  Output: "════════════════════════════════════════════════════════"
  Output: "🔄 RALPH LOOP MODE ACTIVATED (CI Orchestration)"
  Output: "════════════════════════════════════════════════════════"
  Output: "  Max iterations: {loop_max}"
  Output: "  Delay between iterations: {loop_delay}s"
  Output: "  Fresh context per iteration: YES"
  Output: "  Mode: Unattended CI fixing"
  Output: "  Inner flags: {inner_flags}"
  Output: "════════════════════════════════════════════════════════"
  Output: ""

  # Build inner command (without --loop to avoid infinite recursion)
  # --fix-single-category flag enables category-level granularity (one category per iteration)
  inner_command = "/ci_orchestrate {inner_flags} --fix-single-category"

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

    # Check for completion signals (all CI checks passing)
    IF OUTPUT matches regex "All CI checks passing|CI_STATUS.*passing|CI pipeline.*PASS|quality gates.*passing":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "✅ RALPH LOOP SUCCESS"
      Output: "════════════════════════════════════════════════════════"
      Output: "  All CI issues fixed at iteration {iteration}!"
      Output: "  Total iterations used: {iteration}/{loop_max}"
      Output: "════════════════════════════════════════════════════════"
      EXIT 0

    # Check for blocking signals that require human intervention
    IF OUTPUT matches regex "HALT|BLOCKED|Cannot proceed|Manual intervention|Maximum command chain depth":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "⚠️ RALPH LOOP BLOCKED"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Blocked at iteration {iteration}"
      Output: "  Reason: Manual intervention required"
      Output: "  Action: Review output above and resolve issue"
      Output: "  Resume: /ci_orchestrate --loop {remaining_iterations} {inner_flags}"
      Output: "════════════════════════════════════════════════════════"
      EXIT 1

    # Check for auto-escalation to strategic mode
    IF OUTPUT matches regex "AUTO-ESCALATING to strategic mode":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "🔬 RALPH LOOP: Detected Strategic Escalation"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Recurring CI failures detected"
      Output: "  Adding --strategic flag for next iteration..."
      Output: "════════════════════════════════════════════════════════"
      inner_command = "/ci_orchestrate --strategic {inner_flags}"

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
  Output: "  Reached max iterations ({loop_max}) without all CI passing"
  Output: "  Some CI failures may remain"
  Output: "  Action: Check CI status with gh run list"
  Output: "  Resume: /ci_orchestrate --loop {loop_max} --strategic"
  Output: "════════════════════════════════════════════════════════"
  EXIT 1

ELSE:
  # Normal execution - continue to STEP 0.2
  PROCEED TO STEP 0.2
END IF
```

**STEP 0.2: Check for Auto-Escalation**
Analyze git history for recurring CI fix attempts:
```bash
# Count recent "fix CI" commits on current branch
BRANCH=$(git branch --show-current)
CI_FIX_COUNT=$(git log --oneline -20 | grep -iE "fix.*(ci|test|lint|type)" | wc -l | tr -d ' ')

echo "📊 CI fix commits in last 20: $CI_FIX_COUNT"

# Auto-escalate if 3+ CI fix attempts detected
if [[ $CI_FIX_COUNT -ge 3 ]]; then
    echo "⚠️ Detected $CI_FIX_COUNT CI fix attempts. AUTO-ESCALATING to strategic mode..."
    echo "   Breaking the fix-push-fail cycle requires root cause analysis."
    STRATEGIC_MODE=true
fi
```

**STEP 0.3: Execute Strategic Mode (if triggered)**

IF STRATEGIC_MODE is true:

### STRATEGIC PHASE 1: Research & Analysis (PARALLEL)
Launch research agents simultaneously:

```
### NEXT_ACTIONS (PARALLEL) ###
Execute these simultaneously:
1. Task(subagent_type="ci-strategy-analyst", description="Research CI best practices", prompt="...")
2. Task(subagent_type="digdeep", description="Root cause analysis", prompt="...")

After ALL complete: Synthesize findings before proceeding
###
```

**Agent Prompts:**

For ci-strategy-analyst (model="opus"):
```
Task(subagent_type="ci-strategy-analyst",
     model="opus",
     description="Research CI best practices",
     prompt="Analyze CI/CD patterns for this project. The user is experiencing recurring CI failures.

Context: \"$ARGUMENTS\"

Your tasks:
1. Research best practices for: Python/FastAPI + React/TypeScript + GitHub Actions + pytest-xdist
2. Analyze git history for recurring \"fix CI\" patterns
3. Apply Five Whys to top 3 failure patterns
4. Produce prioritized, actionable recommendations

Focus on SYSTEMIC issues, not symptoms. Think hard about root causes.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  \"root_causes\": [{\"issue\": \"...\", \"five_whys\": [...], \"fix\": \"...\"}],
  \"best_practices\": [\"...\"],
  \"infrastructure_recommendations\": [\"...\"],
  \"priority\": \"P0|P1|P2\",
  \"summary\": \"Brief strategic overview\"
}
DO NOT include verbose analysis.")
```

For digdeep (model="opus"):
```
Task(subagent_type="digdeep",
     model="opus",
     description="Root cause analysis",
     prompt="Perform Five Whys root cause analysis on the CI failures.

Context: \"$ARGUMENTS\"

Analyze:
1. What are the recurring CI failure patterns?
2. Why do these failures keep happening despite fixes?
3. What systemic issues allow these failures to recur?
4. What structural changes would prevent them?

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  \"failure_patterns\": [\"...\"],
  \"five_whys_analysis\": [{\"why1\": \"...\", \"why2\": \"...\", \"root_cause\": \"...\"}],
  \"structural_fixes\": [\"...\"],
  \"prevention_strategy\": \"...\",
  \"summary\": \"Brief root cause overview\"
}
DO NOT include verbose analysis or full file contents.")
```

### STRATEGIC PHASE 2: Infrastructure (if --strategic, not --research)
After research completes, launch infrastructure builder:

```
Task(subagent_type="ci-infrastructure-builder",
     model="sonnet",
     description="Create CI infrastructure",
     prompt="Based on the strategic analysis findings, create necessary CI infrastructure:

1. Create reusable GitHub Actions if cleanup/isolation needed
2. Update pytest.ini/pyproject.toml for reliability (timeouts, reruns)
3. Update CI workflow files if needed
4. Add any beneficial plugins/dependencies

Only create infrastructure that addresses identified root causes.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  \"files_created\": [\"...\"],
  \"files_modified\": [\"...\"],
  \"dependencies_added\": [\"...\"],
  \"summary\": \"Brief infrastructure changes\"
}
DO NOT include full file contents.")
```

### STRATEGIC PHASE 3: Documentation (if --strategic or --docs)
Generate documentation for team reference:

```
Task(subagent_type="ci-documentation-generator",
     model="haiku",
     description="Generate CI docs",
     prompt="Create/update CI documentation based on analysis and infrastructure changes:

1. Update docs/ci-failure-runbook.md with new failure patterns
2. Update docs/ci-strategy.md with strategic improvements
3. Store learnings in docs/ci-knowledge/ for future reference

Document what was found, what was fixed, and how to prevent recurrence.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  \"files_created\": [\"...\"],
  \"files_updated\": [\"...\"],
  \"patterns_documented\": 3,
  \"summary\": \"Brief documentation changes\"
}
DO NOT include file contents.")
```

IF RESEARCH_ONLY is true: Stop after Phase 1 (research only, no fixes)
IF DOCS_ONLY is true: Skip to documentation generation only
OTHERWISE: Continue to TACTICAL STEPS below

---

## STEP 0.4: Category-Level Mode Detection (Phase Granularity)

**If `--fix-single-category` is present, execute only ONE category of CI failures per iteration.**

This provides phase-level granularity for Ralph loops, resulting in:
- 30-50K tokens per iteration (vs 80-120K for all categories)
- Fresh context per category (prevents tunnel vision)
- Better recovery from failures

```
IF "--fix-single-category" in "$ARGUMENTS":
  # CATEGORY-LEVEL MODE: Execute ONLY the next category of failures

  Output: "📋 Category-level mode active - fixing ONE failure category..."

  # Analyze CI failures and group by category
  ```bash
  # Get CI failure output
  CI_LOG=$(gh run view --log 2>&1 || echo "")

  # Detect failure categories (in priority order)
  HAS_LINTING=$(echo "$CI_LOG" | grep -cE "(ruff|mypy|lint|format|E[0-9]+|F[0-9]+)" || echo "0")
  HAS_TYPES=$(echo "$CI_LOG" | grep -cE "(type.*error|mypy.*error|TypeScript.*error)" || echo "0")
  HAS_TESTS=$(echo "$CI_LOG" | grep -cE "(FAILED.*test_|pytest.*failed|jest.*failed|vitest.*failed)" || echo "0")
  HAS_SECURITY=$(echo "$CI_LOG" | grep -cE "(security|vulnerability|bandit|safety)" || echo "0")
  HAS_IMPORT=$(echo "$CI_LOG" | grep -cE "(ImportError|ModuleNotFoundError|cannot find module)" || echo "0")
  ```

  # Execute ONLY the first detected category (priority order)
  IF HAS_LINTING > 0:
    Output: "=== [CATEGORY: LINTING] Fixing linting/formatting failures ==="

    Task(
      subagent_type="linting-fixer",
      model="haiku",
      description="Fix CI linting failures",
      prompt="Fix linting and formatting failures detected in CI.

CI log excerpt (linting errors):
{CI_LOG | grep -E '(ruff|mypy|lint|format|E[0-9]+|F[0-9]+)' | head -50}

Fix all linting issues. Run verification after.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'verification_passed': true|false,
  'summary': 'Brief description'
}"
    )

    Output: "✅ CATEGORY_COMPLETE: LINTING"
    Output: "   Next category: types (if any)"
    Exit 0

  ELIF HAS_IMPORT > 0:
    Output: "=== [CATEGORY: IMPORTS] Fixing import/module failures ==="

    Task(
      subagent_type="import-error-fixer",
      model="haiku",
      description="Fix CI import failures",
      prompt="Fix import and module resolution failures detected in CI.

CI log excerpt (import errors):
{CI_LOG | grep -E '(ImportError|ModuleNotFoundError|cannot find module)' | head -50}

Fix all import issues. Run verification after.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'verification_passed': true|false,
  'summary': 'Brief description'
}"
    )

    Output: "✅ CATEGORY_COMPLETE: IMPORTS"
    Output: "   Next category: types (if any)"
    Exit 0

  ELIF HAS_TYPES > 0:
    Output: "=== [CATEGORY: TYPES] Fixing type checking failures ==="

    Task(
      subagent_type="type-error-fixer",
      model="sonnet",
      description="Fix CI type failures",
      prompt="Fix type checking failures detected in CI.

CI log excerpt (type errors):
{CI_LOG | grep -E '(type.*error|mypy.*error|TypeScript.*error)' | head -50}

Fix all type errors. Run verification after.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'verification_passed': true|false,
  'summary': 'Brief description'
}"
    )

    Output: "✅ CATEGORY_COMPLETE: TYPES"
    Output: "   Next category: tests (if any)"
    Exit 0

  ELIF HAS_TESTS > 0:
    Output: "=== [CATEGORY: TESTS] Fixing test failures ==="

    # Detect test type for appropriate fixer
    HAS_API_TESTS=$(echo "$CI_LOG" | grep -cE "(test_api|test_endpoint|FastAPI)" || echo "0")
    HAS_DB_TESTS=$(echo "$CI_LOG" | grep -cE "(test_db|database|fixture)" || echo "0")
    HAS_E2E_TESTS=$(echo "$CI_LOG" | grep -cE "(e2e|playwright|cypress)" || echo "0")

    IF HAS_API_TESTS > 0:
      test_fixer = "api-test-fixer"
    ELIF HAS_DB_TESTS > 0:
      test_fixer = "database-test-fixer"
    ELIF HAS_E2E_TESTS > 0:
      test_fixer = "e2e-test-fixer"
    ELSE:
      test_fixer = "unit-test-fixer"
    END IF

    Task(
      subagent_type="{test_fixer}",
      model="sonnet",
      description="Fix CI test failures",
      prompt="Fix test failures detected in CI.

CI log excerpt (test failures):
{CI_LOG | grep -E '(FAILED.*test_|pytest.*failed|jest.*failed)' | head -50}

Fix all test failures. Run verification after.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'verification_passed': true|false,
  'summary': 'Brief description'
}"
    )

    Output: "✅ CATEGORY_COMPLETE: TESTS"
    Output: "   Next category: security (if any)"
    Exit 0

  ELIF HAS_SECURITY > 0:
    Output: "=== [CATEGORY: SECURITY] Fixing security failures ==="

    Task(
      subagent_type="security-scanner",
      model="sonnet",
      description="Fix CI security failures",
      prompt="Fix security vulnerabilities detected in CI.

CI log excerpt (security issues):
{CI_LOG | grep -E '(security|vulnerability|bandit|safety)' | head -50}

Fix all security issues. Run verification after.

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  'status': 'fixed|partial|failed',
  'issues_fixed': N,
  'files_modified': ['...'],
  'verification_passed': true|false,
  'summary': 'Brief description'
}"
    )

    Output: "✅ CATEGORY_COMPLETE: SECURITY"
    Exit 0

  ELSE:
    # No failures detected or all categories fixed
    Output: "════════════════════════════════════════════════════════"
    Output: "✅ ALL CI CHECKS PASSING"
    Output: "════════════════════════════════════════════════════════"
    Output: "   All failure categories have been addressed."
    Output: "   CI pipeline should be green."
    Exit 0
  END IF

ELSE:
  # ALL-CATEGORIES MODE: Original behavior (fix all categories in parallel)
  Output: "📋 All-categories mode active - fixing all failures in parallel..."
  PROCEED TO "DELEGATE IMMEDIATELY" section
END IF
```

---

## DELEGATE IMMEDIATELY: CI Pipeline Analysis & Specialist Dispatch

**STEP 1: Parse Arguments**
Parse "$ARGUMENTS" to extract:
- CI issue description or "auto-detect"
- --check-actions flag (examine GitHub Actions logs)
- --fix-all flag (comprehensive pipeline fix)
- --quality-gates flag (focus on quality gate failures)
- --performance flag (address performance regressions)

**STEP 2: CI Failure Analysis**
Use diagnostic tools to analyze CI/CD pipeline state:
- Check GitHub Actions workflow status
- Examine recent commit CI results
- Identify failing quality gates
- Categorize failure types for specialist assignment

**STEP 3: Discover Project Context (SHARED CACHE - Token Efficient)**

**Token Savings**: Using shared discovery cache saves ~8K tokens (2K per agent).

```bash
# 📊 SHARED DISCOVERY - Use cached context, refresh if stale (>15 min)
echo "=== Loading Shared Project Context ==="

# Source shared discovery helper (creates/uses cache)
if [[ -f "$HOME/.claude/scripts/shared-discovery.sh" ]]; then
    source "$HOME/.claude/scripts/shared-discovery.sh"
    discover_project_context

    # SHARED_CONTEXT now contains pre-built context for agents
    # Variables available: PROJECT_TYPE, VALIDATION_CMD, TEST_FRAMEWORK, RULES_SUMMARY
else
    # Fallback: inline discovery
    echo "⚠️ Shared discovery not found, using inline discovery"

    PROJECT_CONTEXT=""
    [ -f "CLAUDE.md" ] && PROJECT_CONTEXT="Read CLAUDE.md for project conventions. "
    [ -d ".claude/rules" ] && PROJECT_CONTEXT+="Check .claude/rules/ for patterns. "

    PROJECT_TYPE=""
    [ -f "pyproject.toml" ] && PROJECT_TYPE="python"
    [ -f "package.json" ] && PROJECT_TYPE="${PROJECT_TYPE:+$PROJECT_TYPE+}node"

    # Detect validation command
    if grep -q '"prepush"' package.json 2>/dev/null; then
        VALIDATION_CMD="pnpm prepush"
    elif [ -f "pyproject.toml" ]; then
        VALIDATION_CMD="pytest"
    fi

    SHARED_CONTEXT="$PROJECT_CONTEXT"
fi

echo "📋 PROJECT_TYPE=$PROJECT_TYPE"
echo "📋 VALIDATION_CMD=${VALIDATION_CMD:-pnpm prepush}"
```

**CRITICAL**: Pass `$SHARED_CONTEXT` to ALL agent prompts instead of each agent discovering.

**STEP 4: Failure Type Detection & Agent Mapping**

**CODE QUALITY FAILURES:**
- Linting errors (ruff, mypy violations) → linting-fixer
- Formatting inconsistencies → linting-fixer
- Import organization issues → import-error-fixer
- Type checking failures → type-error-fixer

**TEST FAILURES:**
- Unit test failures → unit-test-fixer
- API endpoint test failures → api-test-fixer
- Database integration test failures → database-test-fixer
- End-to-end workflow failures → e2e-test-fixer

**SECURITY & PERFORMANCE FAILURES:**
- Security vulnerability detection → security-scanner
- Performance regression detection → performance-test-fixer
- Dependency vulnerabilities → security-scanner
- Load testing failures → performance-test-fixer

**INFRASTRUCTURE FAILURES:**
- GitHub Actions workflow syntax → general-purpose (workflow config)
- Docker/deployment issues → general-purpose (infrastructure)
- Environment setup failures → general-purpose (environment)

**STEP 5: Create Specialized CI Work Packages**
Based on detected failures, create targeted work packages:

**For LINTING_FAILURES (READ-ONLY ANALYSIS):**
```bash
# 📊 ANALYSIS ONLY - Do NOT fix issues, only gather info for delegation
gh run list --limit 5 --json conclusion,name,url
gh run view --log | grep -E "(ruff|mypy|E[0-9]+|F[0-9]+)"
```

**For TEST_FAILURES (READ-ONLY ANALYSIS):**
```bash
# 📊 ANALYSIS ONLY - Do NOT fix tests, only gather info for delegation
gh run view --log | grep -A 5 -B 5 "FAILED.*test_"
# Categorize by test file patterns
```

**For SECURITY_FAILURES (READ-ONLY ANALYSIS):**
```bash
# 📊 ANALYSIS ONLY - Do NOT fix security issues, only gather info for delegation
gh run view --log | grep -i "security\|vulnerability\|bandit\|safety"
```

**For PERFORMANCE_FAILURES (READ-ONLY ANALYSIS):**
```bash
# 📊 ANALYSIS ONLY - Do NOT fix performance issues, only gather info for delegation
gh run view --log | grep -i "performance\|benchmark\|response.*time"
```

**STEP 5: EXECUTE PARALLEL SPECIALIST AGENTS**
🚨 CRITICAL: ALWAYS USE BATCH DISPATCH FOR PARALLEL EXECUTION 🚨

MANDATORY REQUIREMENT: Launch multiple Task agents simultaneously using batch dispatch in a SINGLE response.

EXECUTION METHOD - Use multiple Task tool calls in ONE message:
- Task(subagent_type="linting-fixer", description="Fix CI linting failures", prompt="Detailed linting fix instructions")
- Task(subagent_type="api-test-fixer", description="Fix API test failures", prompt="Detailed API test fix instructions") 
- Task(subagent_type="security-scanner", description="Resolve security vulnerabilities", prompt="Detailed security fix instructions")
- Task(subagent_type="performance-test-fixer", description="Fix performance regressions", prompt="Detailed performance fix instructions")
- [Additional specialized agents as needed]

⚠️ CRITICAL: NEVER execute Task calls sequentially - they MUST all be in a single message batch

Each CI specialist agent prompt must include:
```
CI Specialist Task: [Agent Type] - CI Pipeline Fix

Context: You are part of parallel CI orchestration for: $ARGUMENTS

Your CI Domain: [linting/testing/security/performance]
Your Scope: [Specific CI failures/files to fix]
Your Task: Fix CI pipeline failures in your domain expertise
Constraints: Focus only on your CI domain to avoid conflicts with other agents

**CRITICAL - Project Context Discovery (Do This First):**
Before making any fixes, you MUST:
1. Read CLAUDE.md at project root (if exists) for project conventions
2. Check .claude/rules/ directory for domain-specific rule files:
   - If editing Python files → read python*.md rules
   - If editing TypeScript → read typescript*.md rules
   - If editing test files → read testing-related rules
3. Detect project structure from config files (pyproject.toml, package.json)
4. Apply discovered patterns to ALL your fixes

This ensures fixes follow project conventions, not generic patterns.

Critical CI Requirements:
- Fix must pass CI quality gates
- All changes must maintain backward compatibility
- Security fixes cannot introduce new vulnerabilities
- Performance fixes must not regress other metrics

CI Verification Steps:
1. Discover project patterns (CLAUDE.md, .claude/rules/)
2. Fix identified issues in your domain following project patterns
3. Run domain-specific verification commands
4. Ensure CI quality gates will pass
5. Document what was fixed for CI tracking

MANDATORY OUTPUT FORMAT - Return ONLY JSON:
{
  "status": "fixed|partial|failed",
  "issues_fixed": N,
  "files_modified": ["path/to/file.py"],
  "patterns_applied": ["from CLAUDE.md"],
  "verification_passed": true|false,
  "remaining_issues": N,
  "summary": "Brief description of fixes"
}

DO NOT include:
- Full file contents
- Verbose execution logs
- Step-by-step descriptions

Execute your CI domain fixes autonomously and report JSON summary only.
```

**CI SPECIALIST MAPPING:**
- linting-fixer: Code style, ruff/mypy/formatting CI failures
- api-test-fixer: FastAPI endpoint testing, HTTP status CI failures
- database-test-fixer: Database connection, fixture, Supabase CI failures
- type-error-fixer: MyPy type checking CI failures
- import-error-fixer: Module import, dependency CI failures
- unit-test-fixer: Business logic test, pytest CI failures
- security-scanner: Vulnerability scans, secrets detection CI failures
- performance-test-fixer: Performance benchmarks, load testing CI failures
- e2e-test-fixer: End-to-end workflow, integration CI failures
- general-purpose: Infrastructure, workflow config CI issues

**STEP 6: CI Pipeline Verification (READ-ONLY ANALYSIS)**
After specialist agents complete their fixes:
```bash
# 📊 ANALYSIS ONLY - Verify CI pipeline status (READ-ONLY)
gh run list --limit 3 --json conclusion,name,url
# NOTE: Do NOT run "gh workflow run" - let specialists handle CI triggering

# Check quality gates status (READ-ONLY)
echo "Quality Gates Status:"
gh run view --log | grep -E "(coverage|performance|security|lint)" | tail -10
```

⚠️ **CRITICAL**: Do NOT trigger CI runs yourself - delegate this to specialists if needed

**STEP 7: CI Result Collection & Validation**
- Validate each specialist's CI fixes
- Identify any remaining CI failures requiring additional work
- Ensure all quality gates are passing
- Provide CI pipeline health summary
- Recommend follow-up CI improvements

## PARALLEL EXECUTION WITH CONFLICT AVOIDANCE

🔒 ABSOLUTE REQUIREMENT: This command MUST maximize parallelization while avoiding file conflicts.

### Parallel Execution Rules

**SAFE TO PARALLELIZE (different file domains):**
- linting-fixer + api-test-fixer → ✅ Different files
- security-scanner + unit-test-fixer → ✅ Different concerns
- type-error-fixer + e2e-test-fixer → ✅ Different files

**MUST SERIALIZE (overlapping file domains):**
- linting-fixer + import-error-fixer → ⚠️ Both modify Python imports → RUN SEQUENTIALLY
- api-test-fixer + database-test-fixer → ⚠️ May share fixtures → RUN SEQUENTIALLY

### Conflict Detection Algorithm

Before launching agents, analyze which files each will modify:

```bash
# Detect potential conflicts by file pattern overlap
# If two agents modify *.py files with imports, serialize them
# If two agents modify tests/conftest.py, serialize them

# Example conflict detection:
LINTING_FILES="*.py"  # Modifies all Python
IMPORT_FILES="*.py"   # Also modifies all Python
# CONFLICT → Run linting-fixer FIRST, then import-error-fixer

TEST_FIXER_FILES="tests/unit/**"
API_FIXER_FILES="tests/integration/api/**"
# NO CONFLICT → Run in parallel
```

### Execution Phases

When conflicts exist, use phased execution:

```
PHASE 1 (Parallel): Non-conflicting agents
├── security-scanner
├── unit-test-fixer
└── e2e-test-fixer

PHASE 2 (Sequential): Import/lint chain
├── import-error-fixer (run first - fixes missing imports)
└── linting-fixer (run second - cleans up unused imports)

PHASE 3 (Validation): Run project validation command
```

### Refactoring Safety Gate (NEW)

**CRITICAL**: When dispatching to `safe-refactor` agents for file size violations or code restructuring, you MUST use dependency-aware batching.

#### Before Spawning Refactoring Agents

1. **Call dependency-analyzer library** (see `.claude/commands/lib/dependency-analyzer.md`):
   ```bash
   # For each file needing refactoring, find test dependencies
   for FILE in $REFACTOR_FILES; do
       MODULE_NAME=$(basename "$FILE" .py)
       TEST_FILES=$(grep -rl "$MODULE_NAME" tests/ --include="test_*.py" 2>/dev/null)
       echo "  $FILE -> tests: [$TEST_FILES]"
   done
   ```

2. **Group files by independent clusters**:
   - Files sharing test files = SAME cluster (must serialize)
   - Files with independent tests = SEPARATE clusters (can parallelize)

3. **Apply execution rules**:
   - **Within shared-test clusters**: Execute files SERIALLY
   - **Across independent clusters**: Execute in PARALLEL (max 6 total)
   - **Max concurrent safe-refactor agents**: 6

4. **Use failure-handler on any error** (see `.claude/commands/lib/failure-handler.md`):
   ```
   AskUserQuestion(
     questions=[{
       "question": "Refactoring of {file} failed. {N} files remain. Continue, abort, or retry?",
       "header": "Failure",
       "options": [
         {"label": "Continue", "description": "Skip failed file"},
         {"label": "Abort", "description": "Stop all refactoring"},
         {"label": "Retry", "description": "Try again"}
       ],
       "multiSelect": false
     }]
   )
   ```

#### Refactoring Agent Dispatch Template

When dispatching safe-refactor agents, include cluster context:

```
Task(
    subagent_type="safe-refactor",
    description="Safe refactor: {filename}",
    prompt="Refactor this file using TEST-SAFE workflow:
    File: {file_path}
    Current LOC: {loc}

    CLUSTER CONTEXT:
    - cluster_id: {cluster_id}
    - parallel_peers: {peer_files_in_same_batch}
    - test_scope: {test_files_for_this_module}
    - execution_mode: {parallel|serial}

    MANDATORY WORKFLOW: [standard phases]

    MANDATORY OUTPUT FORMAT - Return ONLY JSON:
    {
      \"status\": \"fixed|partial|failed|conflict\",
      \"cluster_id\": \"{cluster_id}\",
      \"files_modified\": [...],
      \"test_files_touched\": [...],
      \"issues_fixed\": N,
      \"remaining_issues\": N,
      \"conflicts_detected\": [],
      \"summary\": \"...\"
    }"
)
```

#### Prohibited Patterns for Refactoring

**NEVER do this:**
```
Task(safe-refactor, file1)  # Spawns agent
Task(safe-refactor, file2)  # Spawns agent - MAY CONFLICT!
Task(safe-refactor, file3)  # Spawns agent - MAY CONFLICT!
```

**ALWAYS do this:**
```
# First: Analyze dependencies
clusters = analyze_dependencies([file1, file2, file3])

# Then: Schedule based on clusters
for cluster in clusters:
    if cluster.has_shared_tests:
        # Serial execution within cluster
        for file in cluster:
            result = Task(safe-refactor, file)
            await result  # WAIT before next
    else:
        # Parallel execution (up to 6)
        Task(safe-refactor, cluster.files)  # All in one batch
```

**CI SPECIALIZATION ADVANTAGE:**
- Domain-specific CI expertise for faster resolution
- Parallel processing of INDEPENDENT CI failures
- Serialized processing of CONFLICTING CI failures
- Higher success rates due to correct ordering

## DELEGATION REQUIREMENT

🔄 IMMEDIATE DELEGATION MANDATORY

You MUST analyze and delegate CI issues immediately upon command invocation.

**DELEGATION-ONLY WORKFLOW:**
1. Analyze CI pipeline state using READ-ONLY commands (GitHub Actions logs)
2. Detect CI failure types and map to appropriate specialist agents
3. Launch specialist agents using Task tool in BATCH DISPATCH MODE
4. ⚠️ NEVER fix issues directly - DELEGATE ONLY
5. ⚠️ NEVER launch agents sequentially - parallel CI delegation is essential

**ANALYSIS COMMANDS (READ-ONLY):**
- Use bash commands ONLY for gathering information about failures
- Use grep, read, ls ONLY to understand what needs to be delegated
- NEVER use these tools to make changes

## 🛡️ GUARD RAILS - PROHIBITED ACTIONS

**NEVER DO THESE ACTIONS (Examples of Direct Fixes):**
```bash
❌ ruff format apps/api/src/  # WRONG: Direct linting fix
❌ pytest tests/api/test_*.py --fix  # WRONG: Direct test fix
❌ git add . && git commit  # WRONG: Direct file changes
❌ docker build -t app .  # WRONG: Direct infrastructure actions
❌ pip install missing-package  # WRONG: Direct dependency fixes
```

**ALWAYS DO THIS INSTEAD (Delegation Examples):**
```
✅ Task(subagent_type="linting-fixer", description="Fix ruff formatting", ...)
✅ Task(subagent_type="api-test-fixer", description="Fix API tests", ...)
✅ Task(subagent_type="import-error-fixer", description="Fix dependencies", ...)
```

**FAILURE MODE DETECTION:**
If you find yourself about to:
- Run commands that change files → STOP, delegate instead
- Install packages or fix imports → STOP, delegate instead
- Format code or fix linting → STOP, delegate instead
- Modify any configuration files → STOP, delegate instead

**CI ORCHESTRATION EXAMPLES:**
- "/ci_orchestrate" → Auto-detect and fix all CI failures in parallel
- "/ci_orchestrate --check-actions" → Focus on GitHub Actions workflow fixes
- "/ci_orchestrate linting and test failures" → Target specific CI failure types
- "/ci_orchestrate --quality-gates" → Fix all quality gate violations in parallel

## INTELLIGENT CHAIN INVOCATION

**STEP 8: Automated Workflow Continuation**
After specialist agents complete their CI fixes, intelligently invoke related commands:

```bash
# Check if test failures were a major component of CI issues
echo "Analyzing CI resolution for workflow continuation..."

# Check if user disabled chaining
if [[ "$ARGUMENTS" == *"--no-chain"* ]]; then
    echo "Auto-chaining disabled by user flag"
    exit 0
fi

# Prevent infinite loops
INVOCATION_DEPTH=${SLASH_DEPTH:-0}
if [[ $INVOCATION_DEPTH -ge 3 ]]; then
    echo "⚠️ Maximum command chain depth reached. Stopping auto-invocation."
    exit 0
fi

# Set depth for next invocation
export SLASH_DEPTH=$((INVOCATION_DEPTH + 1))

# If test failures were detected and fixed, run comprehensive test validation
if [[ "$CI_ISSUES" =~ "test" ]] || [[ "$CI_ISSUES" =~ "pytest" ]]; then
    echo "Test-related CI issues were addressed. Running test orchestration for validation..."
    SlashCommand(command="/test_orchestrate --run-first --fast")
fi

# If all CI issues resolved, check PR status
if [[ "$CI_STATUS" == "passing" ]]; then
    echo "✅ All CI checks passing. Checking PR status..."
    SlashCommand(command="/pr status")
fi
```

---

## Agent Quick Reference

| Failure Type | Agent | Model | JSON Output |
|--------------|-------|-------|-------------|
| Strategic research | ci-strategy-analyst | opus | Required |
| Root cause analysis | digdeep | opus | Required |
| Infrastructure | ci-infrastructure-builder | sonnet | Required |
| Documentation | ci-documentation-generator | haiku | Required |
| Linting/formatting | linting-fixer | haiku | Required |
| Type errors | type-error-fixer | sonnet | Required |
| Import errors | import-error-fixer | haiku | Required |
| Unit tests | unit-test-fixer | sonnet | Required |
| API tests | api-test-fixer | sonnet | Required |
| Database tests | database-test-fixer | sonnet | Required |
| E2E tests | e2e-test-fixer | sonnet | Required |
| Security | security-scanner | sonnet | Required |

---

## Token Efficiency: JSON Output Format

**ALL agents MUST return distilled JSON summaries only.**

```json
{
  "status": "fixed|partial|failed",
  "issues_fixed": 3,
  "files_modified": ["path/to/file.py"],
  "remaining_issues": 0,
  "summary": "Brief description of fixes"
}
```

**DO NOT return:**
- Full file contents
- Verbose explanations
- Step-by-step execution logs

This reduces token usage by 80-90% per agent response.

---

## Model Strategy

| Agent Type | Model | Rationale |
|------------|-------|-----------|
| ci-strategy-analyst, digdeep | opus | Complex research + Five Whys |
| ci-infrastructure-builder | sonnet | Implementation complexity |
| All tactical fixers | sonnet | Balanced speed + quality |
| linting-fixer, import-error-fixer | haiku | Simple pattern matching |
| ci-documentation-generator | haiku | Template-based docs |

---

EXECUTE NOW. Start with STEP 0 (mode detection).