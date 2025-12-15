---
description: "Orchestrate CI/CD pipeline fixes through parallel specialist agent deployment"
argument-hint: "[issue_description] [--check-actions] [--fix-all] [--quality-gates] [--performance]"
allowed-tools: ["Task", "TodoWrite", "Bash", "Grep", "Read", "LS", "Glob", "SlashCommand"]
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

**STEP 3: Failure Type Detection & Agent Mapping**

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

**STEP 4: Create Specialized CI Work Packages**
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

Critical CI Requirements:
- Fix must pass CI quality gates
- All changes must maintain backward compatibility
- Security fixes cannot introduce new vulnerabilities
- Performance fixes must not regress other metrics

CI Verification Steps:
1. Fix identified issues in your domain
2. Run domain-specific verification commands
3. Ensure CI quality gates will pass
4. Document what was fixed for CI tracking

Output Format: 
- Summary of CI fixes completed in your domain
- Specific issues resolved (with error codes/messages)
- Verification steps taken
- CI pipeline components affected
- Expected CI status after fix

Execute your CI domain fixes autonomously and report verification results.
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

## PARALLEL EXECUTION GUARANTEE

🔒 ABSOLUTE REQUIREMENT: This command MUST maintain parallel execution in ALL modes.

- ✅ All CI fixes run in parallel across specialist domains
- ❌ FAILURE: Sequential CI fixes (one domain after another)
- ❌ FAILURE: Waiting for one CI fix before starting another

**CI SPECIALIZATION ADVANTAGE:**
- Domain-specific CI expertise for faster resolution
- Parallel processing of independent CI failures
- Specialized tooling for each CI quality gate
- Higher success rates for domain-specific CI issues

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