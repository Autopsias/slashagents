---
description: "Full TDD/ATDD-driven BMAD development cycle with comprehensive test phases and quality gates"
argument-hint: "<epic-number> [--yolo] [--resume] [--loop N] [--loop-delay S]"
allowed-tools: ["Task", "SlashCommand", "Read", "Write", "Edit", "Bash", "Grep", "Glob", "TodoWrite", "AskUserQuestion"]
---

# BMAD Epic Development - Full TDD/ATDD Workflow

Execute the complete TDD/ATDD-driven BMAD development cycle for epic: "$ARGUMENTS"

## 🚨 CRITICAL ORCHESTRATION CONSTRAINTS 🚨

**YOU ARE A PURE ORCHESTRATOR - DELEGATION ONLY**
- ❌ NEVER execute workflows directly - you are a pure orchestrator
- ❌ NEVER implement story tasks or fix code yourself
- ❌ NEVER run SlashCommand directly - delegate to subagents
- ✅ MUST delegate ALL implementation work to subagents via Task tool
- ✅ Your role is ONLY to: read state, delegate tasks, verify completion
- ✅ **EXCEPTION: You MUST use Edit tool DIRECTLY for status file updates**
     (sprint-status.yaml story/epic status AND story file Status field)
     This is NOT delegated because subagents don't have orchestration context.

**GUARD RAIL CHECK**: Before ANY action ask yourself:
- "Am I about to do work directly?" → If YES: STOP and delegate via Task instead
- "Am I using Read/Bash to check state?" → OK to proceed
- "Am I using Task tool to spawn a subagent?" → Correct approach
- "Am I using Edit for sprint-status.yaml or story Status field?" → OK (exception for status updates)

**SUBAGENT EXECUTION PATTERN**: Each Task call spawns an independent subagent that:
- Has its own context window (preserves main agent context)
- Executes autonomously until completion
- Returns results to the orchestrator

---

## CRITICAL EXECUTION CONSTRAINTS

**SEQUENTIAL EXECUTION ONLY** - Each phase MUST complete before the next starts:
- Never invoke multiple BMAD workflows in parallel
- Wait for each Task to complete before proceeding
- This ensures proper context flow through the 8-phase workflow

**MODEL STRATEGY** - Different models for different phases:

| # | Phase | Model | Rationale |
|---|-------|-------|-----------|
| 1 | create-story | `opus` | Deep understanding for quality story creation |
| 2 | validate-create-story | `sonnet` | Fast feedback loop for validation iterations |
| 3 | testarch-atdd | `opus` | Quality test generation requires deep understanding |
| 4 | dev-story | `sonnet` | Balanced speed/quality for implementation |
| 5 | code-review | `opus` | Thorough adversarial review |
| 6 | testarch-automate | `sonnet` | Iterative test expansion |
| 7 | testarch-test-review | `haiku` | Rule-based quality validation (fast) |
| 8 | testarch-trace | `opus` | Quality gate decision requires careful analysis |

**PURE ORCHESTRATION** - This command:
- Invokes existing BMAD workflows via Task tool with model specifications
- Reads/writes sprint-status.yaml for state management
- Never directly modifies story implementation files (workflows do that)

---

## STEP 1: Parse Arguments

Parse "$ARGUMENTS" to extract:
- **epic_number** (required): First positional argument (e.g., "2" for Epic 2)
- **--interactive**: Run in current session with real-time visibility (can respond to prompts)
- **--resume**: Continue from last incomplete story/phase
- **--yolo**: Skip user confirmation pauses between stories
- **--force-model**: Skip model selection confirmation prompts (enables unattended automation)

**Validation:**
- epic_number must be a positive integer
- If no epic_number provided, error with: "Usage: /epic-dev-full <epic-number> [--yolo] [--resume] [--loop N] [--loop-delay S] [--interactive] [--force-model]"

---

## STEP 1.5: Ralph Loop Mode Detection

**If `--loop` is present in arguments, execute fresh-context loop instead of normal flow.**

```
IF "$ARGUMENTS" contains "--loop":

  # Extract loop parameters
  loop_max = extract_number_after("--loop", default=10)
  loop_delay = extract_number_after("--loop-delay", default=5)

  # ═══════════════════════════════════════════════════════════
  # BACKGROUND MODE (Fresh Context Per Iteration)
  # ═══════════════════════════════════════════════════════════
  # NOTE: Interactive mode was removed due to architectural mismatch
  # with the ralph-loop plugin. See analysis in plans/vivid-noodling-wadler.md

  Output: "════════════════════════════════════════════════════════"
  Output: "🔄 RALPH LOOP MODE ACTIVATED (Full TDD/ATDD Workflow)"
  Output: "════════════════════════════════════════════════════════"
  Output: "  Epic: {epic_num}"
  Output: "  Max iterations: {loop_max}"
  Output: "  Delay between iterations: {loop_delay}s"
  Output: "  Fresh context per iteration: YES"
  Output: "  Mode: Unattended (--yolo implied)"
  Output: "  Workflow: Full 8-phase TDD/ATDD cycle"
  Output: "════════════════════════════════════════════════════════"
  Output: ""

  # Build inner command (without --loop to avoid infinite recursion)
  # --phase-single flag enables phase-level granularity (one phase per iteration)
  # --force-model flag bypasses model confirmation prompts (inherited from parent)
  inner_command = "/epic-dev-full {epic_num} --yolo --phase-single --force-model"

  # ═══════════════════════════════════════════════════════════
  # PRE-CHECK: Is epic already complete?
  # ═══════════════════════════════════════════════════════════
  # Check sprint-status.yaml to avoid wasting iterations on completed epic
  Read {sprint_artifacts}/sprint-status.yaml
  all_stories_done = true
  FOR each story matching "{epic_num}-*" in sprint-status.yaml:
    IF story.status != "done":
      all_stories_done = false
      BREAK
  END FOR

  IF all_stories_done == true:
    Output: ""
    Output: "════════════════════════════════════════════════════════"
    Output: "✅ EPIC {epic_num} ALREADY COMPLETE"
    Output: "════════════════════════════════════════════════════════"
    Output: "  All stories for this epic are already marked done."
    Output: "  No iterations needed."
    Output: "════════════════════════════════════════════════════════"
    Output: ""
    Output: "<promise>EPIC COMPLETE</promise>"
    EXIT 0
  END IF

  # Execute Ralph loop
  FOR iteration IN 1..loop_max:

    Output: ""
    Output: "═══════════════════════════════════════════════════════════"
    Output: "═══ RALPH ITERATION {iteration}/{loop_max} ═══"
    Output: "═══════════════════════════════════════════════════════════"
    Output: "Starting fresh Claude instance..."
    Output: ""

    # Spawn fresh Claude instance with clean context
    # Timeout protection: 5 min overall + 60s stuck detection (heartbeat)
    ```bash
    ITERATION_START=$SECONDS
    TIMEOUT_MINUTES=5
    TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))
    LOG_DIR="/tmp/ralph-loop-epic-${epic_num}"
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/iter-${iteration}.log"

    # Start Claude in background
    claude -p "{inner_command}" --dangerously-skip-permissions > "$LOG_FILE" 2>&1 &
    CLAUDE_PID=$!

    # Monitor with timeout AND heartbeat detection
    LAST_SIZE=0
    STUCK_COUNT=0
    EXIT_CODE=0

    while kill -0 $CLAUDE_PID 2>/dev/null; do
      ELAPSED=$((SECONDS - ITERATION_START))

      # Check overall timeout (5 minutes)
      if [ $ELAPSED -gt $TIMEOUT_SECONDS ]; then
        echo "⚠️ TIMEOUT: Iteration exceeded ${TIMEOUT_MINUTES} minutes - killing stuck process"
        kill -9 $CLAUDE_PID 2>/dev/null
        EXIT_CODE=124
        break
      fi

      # Check heartbeat (log file growth every 5 seconds)
      CURRENT_SIZE=$(wc -c < "$LOG_FILE" 2>/dev/null || echo 0)
      if [ "$CURRENT_SIZE" -eq "$LAST_SIZE" ]; then
        STUCK_COUNT=$((STUCK_COUNT + 1))
        if [ "$STUCK_COUNT" -ge 12 ]; then  # 60 seconds of no output
          echo "⚠️ STUCK: No output for 60 seconds - killing process"
          kill -9 $CLAUDE_PID 2>/dev/null
          EXIT_CODE=125
          break
        fi
      else
        STUCK_COUNT=0  # Reset if progress detected
      fi
      LAST_SIZE=$CURRENT_SIZE

      sleep 5
    done

    # Collect output if not timeout/stuck
    if [ $EXIT_CODE -eq 0 ]; then
      wait $CLAUDE_PID
      EXIT_CODE=$?
    fi

    OUTPUT=$(cat "$LOG_FILE" 2>/dev/null || echo "")
    echo "$OUTPUT" | tee /dev/stderr

    # Keep logs for debugging (preserved in $LOG_DIR)
    echo "Log preserved at: $LOG_FILE"
    ```

    # Check for epic completion signals
    IF OUTPUT matches regex "✅ EPIC.*COMPLETE|All stories in Epic.*complete|Epic.*finished":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "✅ RALPH LOOP SUCCESS"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Epic {epic_num} completed at iteration {iteration}!"
      Output: "  Total iterations used: {iteration}/{loop_max}"
      Output: "  Workflow: Full 8-phase TDD/ATDD cycle"
      Output: "════════════════════════════════════════════════════════"
      EXIT 0

    # Check for blocking signals that require human intervention
    IF OUTPUT matches regex "HALT|BLOCKED|Cannot proceed|Manual intervention|STATUS UPDATE FAILED":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "⚠️ RALPH LOOP BLOCKED"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Blocked at iteration {iteration}"
      Output: "  Reason: Manual intervention required"
      Output: "  Action: Review output above and resolve issue"
      Output: "  Resume: /epic-dev-full {epic_num} --loop {remaining_iterations}"
      Output: "════════════════════════════════════════════════════════"
      EXIT 1

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
  Output: "  Epic {epic_num} may have remaining stories"
  Output: "  Action: Check sprint-status.yaml for progress"
  Output: "  Resume: /epic-dev-full {epic_num} --loop {loop_max}"
  Output: "════════════════════════════════════════════════════════"
  EXIT 1

ELSE:
  # Normal execution (no --loop flag) - continue to STEP 2
  PROCEED TO STEP 2
END IF  # End --loop check
```

---

## STEP 2: Detect BMAD Project

```bash
PROJECT_ROOT=$(pwd)
while [[ ! -d "$PROJECT_ROOT/_bmad" ]] && [[ "$PROJECT_ROOT" != "/" ]]; do
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

if [[ ! -d "$PROJECT_ROOT/_bmad" ]]; then
  echo "ERROR: Not a BMAD project. Run /bmad:bmm:workflows:workflow-init first."
  exit 1
fi
```

Load sprint artifacts path from `_bmad/bmm/config.yaml` (default: `docs/sprint-artifacts`)

---

## STEP 3: Load Sprint Status and Discover Stories

Read `{sprint_artifacts}/sprint-status.yaml`

If not found:
- Output: "Sprint status file not found. Running sprint-planning workflow first..."
- Run: `SlashCommand(command="/bmad:bmm:workflows:sprint-planning")`

Find stories for epic {epic_number}:
- Pattern: `{epic_num}-{story_num}-{story_title}`
- Filter: status NOT "done"
- Order by story number

If no pending stories:
- Output: ""
- Output: "<promise>EPIC COMPLETE</promise>"
- Output: ""
- Output: "✅ All stories in Epic {epic_num} complete!"
- HALT

---

## STEP 4: Session Management

**Extended Session Schema for 8-Phase Workflow:**

```yaml
epic_dev_session:
  epic: {epic_num}
  current_story: "{story_key}"
  phase: "starting"  # See PHASE VALUES below

  # Validation tracking (Phase 2)
  validation_iteration: 0
  validation_issues_count: 0
  validation_last_pass_rate: 100

  # TDD tracking (Phases 3-4)
  tdd_phase: "red"  # red | green | complete
  atdd_checklist_file: null
  atdd_tests_count: 0

  # Code review tracking (Phase 5)
  review_iteration: 0

  # Quality gate tracking (Phase 8)
  gate_decision: null  # PASS | CONCERNS | FAIL | WAIVED
  gate_iteration: 0
  p0_coverage: 0
  p1_coverage: 0
  overall_coverage: 0

  # Timestamps
  started: "{timestamp}"
  last_updated: "{timestamp}"
```

**PHASE VALUES:**
- `starting` - Initial state
- `create_story` - Phase 1: Creating story file
- `create_complete` - Phase 1 complete, proceed to validation
- `validation` - Phase 2: Validating story completeness
- `validation_complete` - Phase 2 complete, proceed to ATDD
- `testarch_atdd` - Phase 3: Generating acceptance tests (RED)
- `atdd_complete` - Phase 3 complete, proceed to dev
- `dev_story` - Phase 4: Implementing story (GREEN)
- `dev_complete` - Phase 4 complete, proceed to review
- `code_review` - Phase 5: Adversarial review
- `review_complete` - Phase 5 complete, proceed to test automation
- `testarch_automate` - Phase 6: Expanding test coverage
- `automate_complete` - Phase 6 complete, proceed to test review
- `testarch_test_review` - Phase 7: Reviewing test quality
- `test_review_complete` - Phase 7 complete, proceed to trace
- `testarch_trace` - Phase 8: Quality gate decision
- `gate_decision` - Awaiting user decision on gate result
- `complete` - Story complete
- `error` - Error state

**If --resume AND session exists for this epic:**
- Resume from recorded phase
- Output: "Resuming Epic {epic_num} from story {current_story} at phase: {phase}"

**If NOT --resume (fresh start):**
- Clear any existing session
- Create new session with `phase: "starting"`

---

## STEP 5: Story Processing Loop

**CRITICAL: Process stories SERIALLY (one at a time)**

**Phase-Level Mode Detection:**

```
IF "--phase-single" in "$ARGUMENTS":
  # PHASE-LEVEL MODE: Execute ONLY the next incomplete phase

  Output: "📋 Phase-level mode active (Full TDD/ATDD) - executing next incomplete phase..."

  # Load session state from sprint-status.yaml
  content = Read("{sprint_artifacts}/sprint-status.yaml")

  # Extract session info (epic_dev_session)
  session = Extract epic_dev_session from content
  current_phase = session.phase
  current_story = session.current_story

  # If no session or phase is "starting" or "complete", find next story
  IF current_phase == "starting" OR current_phase == "complete" OR current_story is null:
    # Find next incomplete story
    FOR each story in epic {epic_number}:
      IF story.status == "backlog":
        current_story = story_key
        current_phase = "create_story"
        BREAK
      ELIF story.status == "created":
        current_story = story_key
        current_phase = "validation"
        BREAK
      # ... continue for other statuses
    END FOR

    IF current_story is null:
      Output: "✅ ALL STORIES COMPLETE - Epic {epic_num} done!"
      Exit 0
  END IF

  # Execute the current phase for current_story
  Output: "=== Executing phase '{current_phase}' for story: {current_story} ==="

  # Phase 1: Create Story
  IF current_phase == "create_story":
    Output: "=== [Phase 1/8] Creating story: {current_story} (opus) ==="

    # DEFENSIVE: Update session BEFORE Task call (protects against hangs)
    Update session:
      - phase: "create_story"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Task(
      subagent_type="epic-story-creator",
      model="opus",
      description="Create story {current_story}",
      prompt="Create story for {current_story}.

Context:
- Epic file: {sprint_artifacts}/epic-{epic_num}.md
- Story key: {current_story}
- Sprint artifacts: {sprint_artifacts}

Execute the BMAD create-story workflow.
Return ONLY JSON: {story_path, ac_count, task_count, status}"
    )

    # Update session to next phase (after successful completion)
    Update session:
      - phase: "create_complete"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Output: "✅ PHASE_COMPLETE: CREATE_STORY {current_story}"
    Output: "   Next phase: validation"
    Exit 0

  # Phase 2: Validate Story
  ELIF current_phase == "create_complete" OR current_phase == "validation":
    Output: "=== [Phase 2/8] Validating story: {current_story} (sonnet) ==="

    Task(
      subagent_type="epic-story-validator",
      model="sonnet",
      description="Validate story {current_story}",
      prompt="Validate story {current_story}.

Context:
- Story file: {sprint_artifacts}/stories/{current_story}.md
- Epic: {epic_num}

Check: story header, BDD acceptance criteria, task links.
Return ONLY JSON: {pass_rate, total_issues, critical_issues}"
    )

    # If validation passes (pass_rate == 100), move to next phase
    # If not, user can re-run to continue validation iterations
    Update session:
      - phase: "validation_complete"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Output: "✅ PHASE_COMPLETE: VALIDATION {current_story}"
    Output: "   Next phase: testarch_atdd"
    Exit 0

  # Phase 3: ATDD - Generate Acceptance Tests
  ELIF current_phase == "validation_complete" OR current_phase == "testarch_atdd":
    Output: "=== [Phase 3/8] TDD RED Phase - Generating acceptance tests: {current_story} (opus) ==="

    # DEFENSIVE: Update session BEFORE Task call
    Update session:
      - phase: "testarch_atdd"
      - current_story: {current_story}
      - tdd_phase: "red"
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Task(
      subagent_type="epic-atdd-writer",
      model="opus",
      description="Generate ATDD tests for {current_story}",
      prompt="Generate ATDD tests for story {current_story} (TDD RED phase).

Context:
- Story file: {sprint_artifacts}/stories/{current_story}.md
- Phase: 3 (ATDD)

Execute /bmad:bmm:workflows:testarch-atdd workflow.
All tests MUST fail initially (RED state).
Return ONLY JSON: {checklist_file, tests_created, test_files, acs_covered}"
    )

    # Update session after successful completion
    Update session:
      - phase: "atdd_complete"
      - current_story: {current_story}
      - tdd_phase: "red"
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Output: "✅ PHASE_COMPLETE: ATDD {current_story}"
    Output: "   Tests in RED state (all failing as expected)"
    Output: "   Next phase: dev_story"
    Exit 0

  # Phase 4: Dev Story - Implementation
  ELIF current_phase == "atdd_complete" OR current_phase == "dev_story":
    Output: "=== [Phase 4/8] TDD GREEN Phase - Implementing story: {current_story} (sonnet) ==="

    Task(
      subagent_type="epic-implementer",
      model="sonnet",
      description="Implement story {current_story}",
      prompt="Implement story {current_story} (TDD GREEN phase).

Context:
- Story file: {sprint_artifacts}/stories/{current_story}.md

Execute /bmad:bmm:workflows:dev-story workflow.
Make all tests pass. Run pnpm prepush before completing.
Return ONLY JSON: {tests_passing, prepush_status, files_modified}"
    )

    # Run verification gate 4.5
    Output: "=== [Gate 4.5] Verifying test state ==="
    verification_iteration = 0
    max_verification_iterations = 3

    WHILE verification_iteration < max_verification_iterations:
      ```bash
      cd {project_root}
      TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
      ```

      IF TEST_OUTPUT contains "FAILED" OR "failed":
        verification_iteration += 1
        Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}"

        IF verification_iteration < max_verification_iterations:
          Task(
            subagent_type="epic-implementer",
            model="sonnet",
            description="Fix failing tests",
            prompt="Fix failing tests for story {current_story}.
Test failures: {TEST_OUTPUT tail -50}
Return JSON: {fixes_applied, tests_passing}"
          )
        ELSE:
          Output: "ERROR: Max verification iterations reached"
          Exit 1
      ELSE:
        Output: "GATE 4.5 PASSED"
        BREAK
    END WHILE

    Update session:
      - phase: "dev_complete"
      - current_story: {current_story}
      - tdd_phase: "complete"
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Output: "✅ PHASE_COMPLETE: DEV_STORY {current_story}"
    Output: "   Implementation complete, all tests passing (GREEN)"
    Output: "   Next phase: code_review"
    Exit 0

  # Phase 5: Code Review
  ELIF current_phase == "dev_complete" OR current_phase == "code_review":
    Output: "=== [Phase 5/8] Code Review: {current_story} (opus) ==="

    # DEFENSIVE: Update session BEFORE Task call
    Update session:
      - phase: "code_review"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Task(
      subagent_type="epic-code-reviewer",
      model="opus",
      description="Review story {current_story}",
      prompt="Review implementation for {current_story}.

Context:
- Story file: {sprint_artifacts}/stories/{current_story}.md

Execute /bmad:bmm:workflows:code-review workflow.
MUST find 3-10 specific issues.
Return ONLY JSON: {total_issues, high_issues, medium_issues, low_issues}"
    )

    # Run verification gate 5.5
    Output: "=== [Gate 5.5] Verifying test state after review ==="
    verification_iteration = 0
    max_verification_iterations = 3

    WHILE verification_iteration < max_verification_iterations:
      ```bash
      cd {project_root}
      TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
      ```

      IF TEST_OUTPUT contains "FAILED" OR "failed":
        verification_iteration += 1
        Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}"

        IF verification_iteration < max_verification_iterations:
          Task(
            subagent_type="epic-implementer",
            model="sonnet",
            description="Fix post-review test failures",
            prompt="Fix test failures after code review for {current_story}.
Test failures: {TEST_OUTPUT tail -50}
Return JSON: {fixes_applied, tests_passing}"
          )
        ELSE:
          Output: "ERROR: Max verification iterations reached"
          Exit 1
      ELSE:
        Output: "GATE 5.5 PASSED"
        BREAK
    END WHILE

    Update session:
      - phase: "review_complete"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Output: "✅ PHASE_COMPLETE: CODE_REVIEW {current_story}"
    Output: "   Code review complete, tests still passing"
    Output: "   Next phase: testarch_automate"
    Exit 0

  # Phase 6: Test Automation Expansion
  ELIF current_phase == "review_complete" OR current_phase == "testarch_automate":
    Output: "=== [Phase 6/8] Expanding test coverage: {current_story} (sonnet) ==="

    Task(
      subagent_type="epic-test-expander",
      model="sonnet",
      description="Expand test coverage for {current_story}",
      prompt="Expand test coverage for story {current_story}.

Context:
- Story file: {sprint_artifacts}/stories/{current_story}.md

Execute /bmad:bmm:workflows:testarch-automate workflow.
Add edge cases, error paths, integration tests.
Return ONLY JSON: {tests_added, coverage_before, coverage_after}"
    )

    # Run verification gate 6.5
    Output: "=== [Gate 6.5] Verifying test state after expansion ==="
    verification_iteration = 0
    max_verification_iterations = 3

    WHILE verification_iteration < max_verification_iterations:
      ```bash
      cd {project_root}
      TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
      ```

      IF TEST_OUTPUT contains "FAILED" OR "failed":
        verification_iteration += 1
        Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}"

        IF verification_iteration < max_verification_iterations:
          Task(
            subagent_type="epic-implementer",
            model="sonnet",
            description="Fix post-expansion test failures",
            prompt="Fix test failures after test expansion for {current_story}.
Test failures: {TEST_OUTPUT tail -50}
Return JSON: {fixes_applied, tests_passing}"
          )
        ELSE:
          Output: "ERROR: Max verification iterations reached"
          Exit 1
      ELSE:
        Output: "GATE 6.5 PASSED"
        BREAK
    END WHILE

    Update session:
      - phase: "automate_complete"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Output: "✅ PHASE_COMPLETE: TESTARCH_AUTOMATE {current_story}"
    Output: "   Test coverage expanded"
    Output: "   Next phase: testarch_test_review"
    Exit 0

  # Phase 7: Test Quality Review
  ELIF current_phase == "automate_complete" OR current_phase == "testarch_test_review":
    Output: "=== [Phase 7/8] Reviewing test quality: {current_story} (haiku) ==="

    Task(
      subagent_type="epic-test-reviewer",
      model="haiku",
      description="Review test quality for {current_story}",
      prompt="Review test quality for story {current_story}.

Context:
- Story file: {sprint_artifacts}/stories/{current_story}.md

Execute /bmad:bmm:workflows:testarch-test-review workflow.
Check BDD format, test IDs, priority markers.
Return ONLY JSON: {quality_score, grade, tests_reviewed, issues_found}"
    )

    # Run verification gate 7.5
    Output: "=== [Gate 7.5] Verifying test state after quality review ==="
    verification_iteration = 0
    max_verification_iterations = 3

    WHILE verification_iteration < max_verification_iterations:
      ```bash
      cd {project_root}
      TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
      ```

      IF TEST_OUTPUT contains "FAILED" OR "failed":
        verification_iteration += 1
        Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}"

        IF verification_iteration < max_verification_iterations:
          Task(
            subagent_type="epic-implementer",
            model="sonnet",
            description="Fix post-quality-review test failures",
            prompt="Fix test failures after quality review for {current_story}.
Test failures: {TEST_OUTPUT tail -50}
Return JSON: {fixes_applied, tests_passing}"
          )
        ELSE:
          Output: "ERROR: Max verification iterations reached"
          Exit 1
      ELSE:
        Output: "GATE 7.5 PASSED"
        BREAK
    END WHILE

    Update session:
      - phase: "test_review_complete"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Output: "✅ PHASE_COMPLETE: TESTARCH_TEST_REVIEW {current_story}"
    Output: "   Test quality validated"
    Output: "   Next phase: testarch_trace (quality gate)"
    Exit 0

  # Phase 8: Requirements Traceability & Quality Gate
  ELIF current_phase == "test_review_complete" OR current_phase == "testarch_trace":
    Output: "=== [Phase 8/8] Quality Gate Decision: {current_story} (opus) ==="

    # DEFENSIVE: Update session BEFORE Task call
    Update session:
      - phase: "testarch_trace"
      - current_story: {current_story}
      - last_updated: {timestamp}
    Write sprint-status.yaml

    Task(
      subagent_type="epic-story-validator",
      model="opus",
      description="Quality gate decision for {current_story}",
      prompt="Make quality gate decision for story {current_story}.

Context:
- Story file: {sprint_artifacts}/stories/{current_story}.md

Execute /bmad:bmm:workflows:testarch-trace workflow.
Generate traceability matrix and make gate decision (PASS/CONCERNS/FAIL).
Return ONLY JSON: {decision, p0_coverage, p1_coverage, overall_coverage}"
    )

    # If gate passes (PASS or WAIVED), mark story as done
    IF decision == "PASS" OR decision == "WAIVED":
      # CRITICAL: Update sprint-status.yaml story status to "done"
      max_retries = 3
      retry_count = 0

      WHILE retry_count < max_retries:
        content = Read("{sprint_artifacts}/sprint-status.yaml")
        SEARCH for line matching "  {current_story}: " and extract current_status

        IF current_status == "done":
          Output: "✅ sprint-status.yaml already shows 'done'"
          BREAK

        Edit(
          file_path="{sprint_artifacts}/sprint-status.yaml",
          old_string="  {current_story}: {current_status}",
          new_string="  {current_story}: done"
        )

        updated = Read("{sprint_artifacts}/sprint-status.yaml")
        IF updated contains "  {current_story}: done":
          Output: "✅ sprint-status.yaml updated successfully"
          BREAK
        ELSE:
          retry_count += 1
      END WHILE

      # CRITICAL: Update story file Status field to "done"
      retry_count = 0
      WHILE retry_count < max_retries:
        content = Read("{sprint_artifacts}/stories/{current_story}.md")
        SEARCH for line starting with "Status: " and extract current_status

        IF current_status == "done":
          Output: "✅ Story file already shows 'done'"
          BREAK

        Edit(
          file_path="{sprint_artifacts}/stories/{current_story}.md",
          old_string="Status: {current_status}",
          new_string="Status: done"
        )

        updated = Read("{sprint_artifacts}/stories/{current_story}.md")
        IF updated contains "Status: done":
          Output: "✅ Story file status updated successfully"
          BREAK
        ELSE:
          retry_count += 1
      END WHILE

      # Update session to mark story complete
      Update session:
        - phase: "complete"
        - current_story: {current_story}
        - gate_decision: {decision}
        - last_updated: {timestamp}
      Write sprint-status.yaml

      Output: "✅ PHASE_COMPLETE: TESTARCH_TRACE {current_story}"
      Output: "   Quality Gate: {decision}"
      Output: "   Story marked DONE"
      Output: "   Next iteration will start next story Phase 1"
      Exit 0
    ELSE:
      # FAIL or CONCERNS - needs user decision
      Output: "⚠️ QUALITY GATE: {decision}"
      Output: "   Manual intervention required"
      Exit 1
    END IF

  ELSE:
    Output: "ERROR: Unknown phase '{current_phase}'"
    Exit 1
  END IF

  # Check if all stories complete
  all_done = true
  FOR each story in epic {epic_number}:
    IF story_status != "done":
      all_done = false
      BREAK
  END FOR

  IF all_done:
    # Update epic status to done
    max_retries = 3
    retry_count = 0

    WHILE retry_count < max_retries:
      content = Read("{sprint_artifacts}/sprint-status.yaml")
      SEARCH for line matching "  epic-{epic_num}: " and extract current_status

      IF current_status == "done":
        Output: "✅ Epic status already shows 'done'"
        BREAK

      Edit(
        file_path="{sprint_artifacts}/sprint-status.yaml",
        old_string="  epic-{epic_num}: {current_status}",
        new_string="  epic-{epic_num}: done"
      )

      updated = Read("{sprint_artifacts}/sprint-status.yaml")
      IF updated contains "  epic-{epic_num}: done":
        Output: "✅ Epic status updated successfully"
        BREAK
      ELSE:
        retry_count += 1
    END WHILE

    Output: "════════════════════════════════════════════════════════"
    Output: "✅ EPIC {epic_num} COMPLETE!"
    Output: "════════════════════════════════════════════════════════"
    Exit 0
  END IF

ELSE:
  # STORY-LEVEL MODE: Original behavior (complete entire story with all 8 phases)
  Output: "📋 Story-level mode active - executing complete 8-phase TDD/ATDD workflow per story..."
END IF
```

For each pending story:

---

### PHASE 1: Create Story (opus)

**Execute when:** `story.status == "backlog"`

```
Output: "=== [Phase 1/8] Creating story: {story_key} (opus) ==="

Update session:
  - phase: "create_story"
  - last_updated: {timestamp}

Write sprint-status.yaml

Task(
  subagent_type="epic-story-creator",
  model="opus",
  description="Create story {story_key}",
  prompt="Create story for {story_key}.

Context:
- Epic file: {sprint_artifacts}/epic-{epic_num}.md
- Story key: {story_key}
- Sprint artifacts: {sprint_artifacts}

Execute the BMAD create-story workflow.
Return ONLY JSON: {story_path, ac_count, task_count, status}"
)

Verify:
- Story file exists at {sprint_artifacts}/stories/{story_key}.md
- Story status updated in sprint-status.yaml

Update session:
  - phase: "create_complete"

PROCEED TO PHASE 2
```

---

### PHASE 2: Validate Create Story (sonnet, max 3 iterations)

**Execute when:** `phase == "create_complete"` OR `phase == "validation"`

This phase validates the story file for completeness using tier-based issue classification.

```
INITIALIZE:
  validation_iteration = session.validation_iteration or 0
  max_validations = 3

WHILE validation_iteration < max_validations:

  Output: "=== [Phase 2/8] Validation iteration {validation_iteration + 1} for: {story_key} (sonnet) ==="

  Update session:
    - phase: "validation"
    - validation_iteration: {validation_iteration}
    - last_updated: {timestamp}

  Write sprint-status.yaml

  Task(
    subagent_type="epic-story-validator",
    model="sonnet",
    description="Validate story {story_key}",
    prompt="Validate story {story_key} (iteration {validation_iteration + 1}).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md
- Epic: {epic_num}

Check: story header, BDD acceptance criteria, task links, dev notes, testing requirements.
Return ONLY JSON: {pass_rate, total_issues, critical_issues, enhancement_issues, optimization_issues}"
  )

  Parse validation JSON output

  IF pass_rate == 100 OR total_issues == 0:
    Output: "Story validation PASSED (100%)"
    Update session:
      - phase: "validation_complete"
      - validation_last_pass_rate: 100
    Write sprint-status.yaml
    BREAK from loop
    PROCEED TO PHASE 3

  ELSE:
    # Display issues by tier
    Output:
    ───────────────────────────────────────────────────────────
    VALIDATION ISSUES FOUND
    ───────────────────────────────────────────────────────────
    Pass Rate: {pass_rate}% | Total Issues: {total_issues}

    CRITICAL ({critical_count}): {list critical issues}
    ENHANCEMENT ({enhancement_count}): {list enhancement issues}
    OPTIMIZATION ({optimization_count}): {list optimization issues}
    ───────────────────────────────────────────────────────────

    user_decision = AskUserQuestion(
      question: "How to proceed with validation issues?",
      header: "Validation",
      options: [
        {label: "Fix all", description: "Apply all {total_issues} fixes (recommended)"},
        {label: "Fix critical only", description: "Apply only critical fixes"},
        {label: "Skip validation", description: "Proceed to ATDD with current issues"},
        {label: "Manual review", description: "Pause for manual inspection"}
      ]
    )

    IF user_decision == "Fix all" OR user_decision == "Fix critical only":
      # Apply fixes - use epic-story-creator since it handles story file creation/modification
      Task(
        subagent_type="epic-story-creator",
        model="sonnet",
        description="Fix validation issues for {story_key}",
        prompt="Fix validation issues in story {story_key}.

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md
- Fix mode: {IF user_decision == 'Fix all': 'ALL ISSUES' ELSE: 'CRITICAL ONLY'}

Issues to Fix:
{IF user_decision == 'Fix all': all_issues ELSE: critical_issues}

Apply fixes using Edit tool. Preserve existing content.
Return ONLY JSON: {fixes_applied, sections_modified}"
      )
      validation_iteration += 1
      CONTINUE loop (re-validate)

    ELSE IF user_decision == "Skip validation":
      Output: "Skipping remaining validation. Proceeding to ATDD phase..."
      Update session:
        - phase: "validation_complete"
      Write sprint-status.yaml
      BREAK from loop
      PROCEED TO PHASE 3

    ELSE IF user_decision == "Manual review":
      Output: "Pausing for manual review."
      Output: "Story file: {sprint_artifacts}/stories/{story_key}.md"
      Output: "Resume with: /epic-dev-full {epic_num} --resume"
      HALT

END WHILE

IF validation_iteration >= max_validations AND pass_rate < 100:
  Output: "Maximum validation iterations ({max_validations}) reached."
  Output: "Current pass rate: {pass_rate}%"

  escalation = AskUserQuestion(
    question: "Validation limit reached. How to proceed?",
    header: "Escalate",
    options: [
      {label: "Continue anyway", description: "Proceed to ATDD with remaining issues"},
      {label: "Manual fix", description: "Pause for manual intervention"},
      {label: "Skip story", description: "Skip this story, continue to next"}
    ]
  )

  Handle escalation choice accordingly
```

---

### PHASE 3: ATDD - Generate Acceptance Tests (opus)

**Execute when:** `phase == "validation_complete"` OR `phase == "testarch_atdd"`

This phase generates FAILING acceptance tests before implementation (TDD RED phase).

```
Output: "=== [Phase 3/8] TDD RED Phase - Generating acceptance tests: {story_key} (opus) ==="

Update session:
  - phase: "testarch_atdd"
  - tdd_phase: "red"
  - last_updated: {timestamp}

Write sprint-status.yaml

Task(
  subagent_type="epic-atdd-writer",  # ISOLATED: No implementation knowledge
  model="opus",
  description="Generate ATDD tests for {story_key}",
  prompt="Generate ATDD tests for story {story_key} (TDD RED phase).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md
- Phase: 3 (ATDD)

CRITICAL: You are isolated from implementation details. Focus ONLY on acceptance criteria.
Execute /bmad:bmm:workflows:testarch-atdd workflow.
All tests MUST fail initially (RED state).
Return ONLY JSON: {checklist_file, tests_created, test_files, acs_covered, status}"
)

Parse ATDD output

Verify tests are FAILING (optional quick validation):
```bash
# Run tests to confirm RED state
cd {project_root}
pnpm test --run 2>&1 | tail -20  # Should show failures
```

Update session:
  - phase: "atdd_complete"
  - atdd_checklist_file: {checklist_file}
  - atdd_tests_count: {tests_created}
  - tdd_phase: "red"

Write sprint-status.yaml

Output: "ATDD tests generated: {tests_created} tests (RED - all failing as expected)"
Output: "Checklist: {checklist_file}"

PROCEED TO PHASE 4
```

---

### PHASE 4: Dev Story - Implementation (sonnet)

**Execute when:** `phase == "atdd_complete"` OR `phase == "dev_story"`

This phase implements the story to make acceptance tests pass (TDD GREEN phase).

```
Output: "=== [Phase 4/8] TDD GREEN Phase - Implementing story: {story_key} (sonnet) ==="

Update session:
  - phase: "dev_story"
  - tdd_phase: "green"
  - last_updated: {timestamp}

Write sprint-status.yaml

Task(
  subagent_type="epic-implementer",
  model="sonnet",
  description="Implement story {story_key}",
  prompt="Implement story {story_key} (TDD GREEN phase).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md
- ATDD checklist: {session.atdd_checklist_file}
- Tests to pass: {session.atdd_tests_count}

Execute /bmad:bmm:workflows:dev-story workflow.
Make all tests pass. Run pnpm prepush before completing.
Return ONLY JSON: {tests_passing, tests_total, prepush_status, files_modified, status}"
)

Verify implementation:
- All ATDD tests passing
- pnpm prepush passes (or equivalent validation)
- Story status updated to "review"

Update session:
  - phase: "dev_complete"
  - tdd_phase: "complete"

Write sprint-status.yaml

Output: "Implementation complete. All ATDD tests passing (GREEN)."

PROCEED TO VERIFICATION GATE 4.5
```

---

### VERIFICATION GATE 4.5: Post-Implementation Test Verification

**Purpose**: Verify all tests still pass after dev-story phase. This prevents regressions from being hidden by JSON-only output.

```
Output: "=== [Gate 4.5] Verifying test state after implementation ==="

INITIALIZE:
  verification_iteration = 0
  max_verification_iterations = 3

WHILE verification_iteration < max_verification_iterations:

  # Orchestrator directly runs tests (not delegated)
  ```bash
  cd {project_root}
  TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
  ```

  # Check for failures
  IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
    verification_iteration += 1
    Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing"

    IF verification_iteration < max_verification_iterations:
      # Ralph-style: Feed failures back to implementer
      Task(
        subagent_type="epic-implementer",
        model="sonnet",
        description="Fix failing tests (iteration {verification_iteration})",
        prompt="Fix failing tests for story {story_key} (verification iteration {verification_iteration}).

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

Fix the failing tests. Do NOT modify test files unless absolutely necessary.
Run tests after fixing. Return JSON: {fixes_applied, tests_passing, status}"
      )
    ELSE:
      # Max iterations reached
      Output: "ERROR: Max verification iterations ({max_verification_iterations}) reached"
      Output: "Tests still failing after {max_verification_iterations} fix attempts."

      gate_escalation = AskUserQuestion(
        question: "Verification gate 4.5 failed after 3 iterations. How to proceed?",
        header: "Gate 4.5 Failed",
        options: [
          {label: "Continue anyway", description: "Proceed to code review with failing tests (risky)"},
          {label: "Manual fix", description: "Pause for manual intervention"},
          {label: "Skip story", description: "Mark story as blocked and continue"},
          {label: "Stop", description: "Save state and exit"}
        ]
      )

      Handle gate_escalation accordingly
      IF gate_escalation == "Continue anyway":
        BREAK from loop
      ELSE IF gate_escalation == "Manual fix":
        Output: "Pausing for manual test fix."
        Output: "Resume with: /epic-dev-full {epic_num} --resume"
        HALT
      ELSE IF gate_escalation == "Skip story":
        Update session: phase: "error", last_error: "Gate 4.5 failed"
        CONTINUE to next story
      ELSE:
        HALT
      END IF
  ELSE:
    Output: "VERIFICATION GATE 4.5 PASSED: All tests green"
    BREAK from loop
  END IF

END WHILE

PROCEED TO PHASE 5
```

---

### PHASE 5: Code Review (opus, max 3 iterations)

**Execute when:** `phase == "dev_complete"` OR `phase == "code_review"`

This phase performs adversarial code review finding 3-10 specific issues.

```
INITIALIZE:
  review_iteration = session.review_iteration or 0
  max_reviews = 3

WHILE review_iteration < max_reviews:

  Output: "=== [Phase 5/8] Code Review iteration {review_iteration + 1}: {story_key} (opus) ==="

  Update session:
    - phase: "code_review"
    - review_iteration: {review_iteration}
    - last_updated: {timestamp}

  Write sprint-status.yaml

  Task(
    subagent_type="epic-code-reviewer",
    model="opus",
    description="Code review for {story_key}",
    prompt="Review implementation for {story_key} (iteration {review_iteration + 1}).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md

Execute /bmad:bmm:workflows:code-review workflow.
MUST find 3-10 specific issues. NEVER report zero issues.
Return ONLY JSON: {total_issues, high_issues, medium_issues, low_issues, auto_fixable}"
  )

  Parse review JSON output

  IF total_issues == 0 OR (high_count == 0 AND medium_count == 0):
    # Only LOW issues or no issues
    IF low_count > 0:
      Output: "Review found {low_count} LOW priority issues only."

      low_decision = AskUserQuestion(
        question: "How to handle LOW priority issues?",
        header: "Low Issues",
        options: [
          {label: "Fix all", description: "Fix all {low_count} low priority issues"},
          {label: "Skip", description: "Accept low issues and proceed"}
        ]
      )

      IF low_decision == "Fix all":
        # Apply low fixes
        Task(
          subagent_type="epic-implementer",
          model="sonnet",
          description="Fix low priority review issues for {story_key}",
          prompt="Fix LOW priority code review issues for {story_key}.

Issues to Fix:
{low_issues}

Apply fixes using Edit tool. Run pnpm prepush after.
Return ONLY JSON: {fixes_applied, prepush_status, tests_passing}"
        )
        review_iteration += 1
        CONTINUE loop
      ELSE:
        BREAK from loop
    ELSE:
      Output: "Code review PASSED - No blocking issues found."
      BREAK from loop

  ELSE:
    # HIGH or MEDIUM issues found
    Output:
    ───────────────────────────────────────────────────────────
    CODE REVIEW FINDINGS
    ───────────────────────────────────────────────────────────
    Total Issues: {total_issues}

    HIGH ({high_count}): {list high issues}
    MEDIUM ({medium_count}): {list medium issues}
    LOW ({low_count}): {list low issues}
    ───────────────────────────────────────────────────────────

    # Auto-fix HIGH and MEDIUM issues
    Output: "Auto-fixing {high_count + medium_count} HIGH/MEDIUM issues..."

    Task(
      subagent_type="epic-implementer",
      model="sonnet",
      description="Fix review issues for {story_key}",
      prompt="Fix HIGH and MEDIUM priority code review issues for {story_key}.

HIGH PRIORITY (must fix):
{high_issues}

MEDIUM PRIORITY (should fix):
{medium_issues}

Apply all fixes. Run pnpm prepush after.
Return ONLY JSON: {fixes_applied, prepush_status, tests_passing}"
    )

    review_iteration += 1
    CONTINUE loop

END WHILE

IF review_iteration >= max_reviews:
  Output: "Maximum review iterations ({max_reviews}) reached."
  escalation = AskUserQuestion(
    question: "Review limit reached. How to proceed?",
    options: [
      {label: "Continue", description: "Accept current state and proceed"},
      {label: "Manual fix", description: "Pause for manual intervention"}
    ]
  )
  Handle escalation

Update session:
  - phase: "review_complete"

Write sprint-status.yaml

PROCEED TO VERIFICATION GATE 5.5
```

---

### VERIFICATION GATE 5.5: Post-Code-Review Test Verification

**Purpose**: Verify all tests still pass after code review fixes. Code review may apply fixes that break tests.

```
Output: "=== [Gate 5.5] Verifying test state after code review fixes ==="

INITIALIZE:
  verification_iteration = 0
  max_verification_iterations = 3

WHILE verification_iteration < max_verification_iterations:

  # Orchestrator directly runs tests (not delegated)
  ```bash
  cd {project_root}
  TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
  ```

  # Check for failures
  IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
    verification_iteration += 1
    Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing after code review"

    IF verification_iteration < max_verification_iterations:
      # Ralph-style: Feed failures back to implementer
      Task(
        subagent_type="epic-implementer",
        model="sonnet",
        description="Fix post-review test failures (iteration {verification_iteration})",
        prompt="Fix test failures caused by code review changes for story {story_key} (iteration {verification_iteration}).

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

The code review phase applied fixes that may have broken tests.
Fix the failing tests without reverting the review improvements.
Run tests after fixing. Return JSON: {fixes_applied, tests_passing, status}"
      )
    ELSE:
      # Max iterations reached
      Output: "ERROR: Gate 5.5 - Max verification iterations ({max_verification_iterations}) reached"

      gate_escalation = AskUserQuestion(
        question: "Verification gate 5.5 failed after 3 iterations. How to proceed?",
        header: "Gate 5.5 Failed",
        options: [
          {label: "Continue anyway", description: "Proceed to test expansion with failing tests (risky)"},
          {label: "Revert review changes", description: "Revert code review fixes and proceed"},
          {label: "Manual fix", description: "Pause for manual intervention"},
          {label: "Stop", description: "Save state and exit"}
        ]
      )

      Handle gate_escalation accordingly
  ELSE:
    Output: "VERIFICATION GATE 5.5 PASSED: All tests green after code review"
    BREAK from loop
  END IF

END WHILE

PROCEED TO PHASE 6
```

---

### PHASE 6: Test Automation Expansion (sonnet)

**Execute when:** `phase == "review_complete"` OR `phase == "testarch_automate"`

This phase expands test coverage beyond the initial ATDD tests.

```
Output: "=== [Phase 6/8] Expanding test coverage: {story_key} (sonnet) ==="

Update session:
  - phase: "testarch_automate"
  - last_updated: {timestamp}

Write sprint-status.yaml

Task(
  subagent_type="epic-test-expander",  # ISOLATED: Fresh perspective on coverage gaps
  model="sonnet",
  description="Expand test coverage for {story_key}",
  prompt="Expand test coverage for story {story_key} (Phase 6).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md
- ATDD checklist: {session.atdd_checklist_file}

CRITICAL: You did NOT write the original tests. Analyze the IMPLEMENTATION for gaps.
Execute /bmad:bmm:workflows:testarch-automate workflow.
Add edge cases, error paths, integration tests with priority tagging.
Return ONLY JSON: {tests_added, coverage_before, coverage_after, test_files, by_priority, gaps_found, status}"
)

Parse automation output

Update session:
  - phase: "automate_complete"

Write sprint-status.yaml

Output: "Test automation complete. Added {tests_added} tests."
Output: "Coverage: {coverage_before}% -> {coverage_after}%"

PROCEED TO VERIFICATION GATE 6.5
```

---

### VERIFICATION GATE 6.5: Post-Test-Expansion Verification

**Purpose**: Verify all tests (original + new) pass after test expansion. New tests may conflict with existing implementation.

```
Output: "=== [Gate 6.5] Verifying test state after test expansion ==="

INITIALIZE:
  verification_iteration = 0
  max_verification_iterations = 3

WHILE verification_iteration < max_verification_iterations:

  # Orchestrator directly runs tests (not delegated)
  ```bash
  cd {project_root}
  TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
  ```

  # Check for failures
  IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
    verification_iteration += 1
    Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing after expansion"

    IF verification_iteration < max_verification_iterations:
      # Determine if failure is in NEW tests or EXISTING tests
      # If new tests fail, they may need adjustment
      # If existing tests fail, implementation needs fixing
      Task(
        subagent_type="epic-implementer",
        model="sonnet",
        description="Fix post-expansion test failures (iteration {verification_iteration})",
        prompt="Fix test failures after test expansion for story {story_key} (iteration {verification_iteration}).

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

Determine if failures are in:
1. NEW tests (from expansion): May need to adjust test expectations
2. EXISTING tests (original ATDD): Implementation needs fixing

Fix accordingly. Return JSON: {fixes_applied, new_tests_adjusted, implementation_fixed, tests_passing, status}"
      )
    ELSE:
      # Max iterations reached
      Output: "ERROR: Gate 6.5 - Max verification iterations ({max_verification_iterations}) reached"

      gate_escalation = AskUserQuestion(
        question: "Verification gate 6.5 failed after 3 iterations. How to proceed?",
        header: "Gate 6.5 Failed",
        options: [
          {label: "Remove failing new tests", description: "Delete new tests that are blocking progress"},
          {label: "Continue anyway", description: "Proceed to test review with failing tests"},
          {label: "Manual fix", description: "Pause for manual intervention"},
          {label: "Stop", description: "Save state and exit"}
        ]
      )

      Handle gate_escalation accordingly
  ELSE:
    Output: "VERIFICATION GATE 6.5 PASSED: All tests green after expansion"
    BREAK from loop
  END IF

END WHILE

PROCEED TO PHASE 7
```

---

### PHASE 7: Test Quality Review (sonnet)

**Execute when:** `phase == "automate_complete"` OR `phase == "testarch_test_review"`

This phase reviews test quality against best practices.

```
Output: "=== [Phase 7/8] Reviewing test quality: {story_key} (haiku) ==="

Update session:
  - phase: "testarch_test_review"
  - last_updated: {timestamp}

Write sprint-status.yaml

Task(
  subagent_type="epic-test-reviewer",  # ISOLATED: Objective quality assessment
  model="haiku",
  description="Review test quality for {story_key}",
  prompt="Review test quality for story {story_key} (Phase 7).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md

CRITICAL: You did NOT write these tests. Apply quality criteria objectively.
Execute /bmad:bmm:workflows:testarch-test-review workflow.
Check BDD format, test IDs, priority markers, no hard waits, deterministic assertions.
Return ONLY JSON: {quality_score, grade, tests_reviewed, issues_found, by_category, recommendations, status}"
)

Parse quality report

IF quality_score < 80 OR has_high_severity_issues:
  Output: "Test quality issues detected (score: {quality_score}%)"
  Output: "Issues: {issues_found}"

  quality_decision = AskUserQuestion(
    question: "How to handle test quality issues?",
    header: "Quality",
    options: [
      {label: "Fix issues", description: "Auto-fix test quality issues"},
      {label: "Continue", description: "Accept current quality and proceed to gate"}
    ]
  )

  IF quality_decision == "Fix issues":
    Task(
      subagent_type="epic-test-reviewer",  # Same agent fixes issues it identified
      model="haiku",
      description="Fix test quality issues for {story_key}",
      prompt="Fix test quality issues for story {story_key}.

Issues to Fix:
{issues_found}

Apply auto-fixes for: hard waits, missing docstrings, missing priority markers.
Run tests after fixes to ensure they still pass.
Return ONLY JSON: {fixes_applied, tests_passing, quality_score, status}"
    )

Update session:
  - phase: "test_review_complete"

Write sprint-status.yaml

Output: "Test quality review complete. Score: {quality_score}%"

PROCEED TO VERIFICATION GATE 7.5
```

---

### VERIFICATION GATE 7.5: Post-Quality-Review Test Verification

**Purpose**: Verify all tests still pass after quality review fixes. Test refactoring may inadvertently break functionality.

```
Output: "=== [Gate 7.5] Verifying test state after quality review fixes ==="

INITIALIZE:
  verification_iteration = 0
  max_verification_iterations = 3

WHILE verification_iteration < max_verification_iterations:

  # Orchestrator directly runs tests (not delegated)
  ```bash
  cd {project_root}
  TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
  ```

  # Check for failures
  IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
    verification_iteration += 1
    Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing after quality fixes"

    IF verification_iteration < max_verification_iterations:
      # Quality review changes may have altered test behavior
      Task(
        subagent_type="epic-implementer",
        model="sonnet",
        description="Fix post-quality-review test failures (iteration {verification_iteration})",
        prompt="Fix test failures after quality review for story {story_key} (iteration {verification_iteration}).

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

Quality review may have:
1. Refactored test structure
2. Fixed test naming/IDs
3. Removed hardcoded waits
4. Changed assertions

Ensure fixes maintain test intent while passing.
Return JSON: {fixes_applied, tests_passing, status}"
      )
    ELSE:
      # Max iterations reached
      Output: "ERROR: Gate 7.5 - Max verification iterations ({max_verification_iterations}) reached"

      gate_escalation = AskUserQuestion(
        question: "Verification gate 7.5 failed after 3 iterations. How to proceed?",
        header: "Gate 7.5 Failed",
        options: [
          {label: "Revert quality fixes", description: "Revert test quality changes and proceed"},
          {label: "Continue anyway", description: "Proceed to quality gate with failing tests"},
          {label: "Manual fix", description: "Pause for manual intervention"},
          {label: "Stop", description: "Save state and exit"}
        ]
      )

      Handle gate_escalation accordingly
  ELSE:
    Output: "VERIFICATION GATE 7.5 PASSED: All tests green after quality review"
    BREAK from loop
  END IF

END WHILE

PROCEED TO PHASE 8
```

---

### PHASE 8: Requirements Traceability & Quality Gate (opus)

**Execute when:** `phase == "test_review_complete"` OR `phase == "testarch_trace"`

This phase generates traceability matrix and makes quality gate decision.

```
Output: "=== [Phase 8/8] Quality Gate Decision: {story_key} (opus) ==="

Update session:
  - phase: "testarch_trace"
  - last_updated: {timestamp}

Write sprint-status.yaml

Task(
  subagent_type="epic-story-validator",
  model="opus",
  description="Quality gate decision for {story_key}",
  prompt="Make quality gate decision for story {story_key} (Phase 8).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md
- ATDD checklist: {session.atdd_checklist_file}

Execute /bmad:bmm:workflows:testarch-trace workflow.
Generate traceability matrix and make gate decision (PASS/CONCERNS/FAIL).
Return ONLY JSON: {decision, p0_coverage, p1_coverage, overall_coverage, traceability_matrix, gaps, rationale}"
)

Parse gate decision

# ═══════════════════════════════════════════════════════════════════════════
# QUALITY GATE DECISION HANDLING
# ═══════════════════════════════════════════════════════════════════════════

Output:
═══════════════════════════════════════════════════════════════════════════
QUALITY GATE RESULT: {decision}
═══════════════════════════════════════════════════════════════════════════
P0 Coverage (Critical): {p0_coverage}% (required: 100%)
P1 Coverage (Important): {p1_coverage}% (target: 90%)
Overall Coverage: {overall_coverage}% (target: 80%)

Rationale: {rationale}
═══════════════════════════════════════════════════════════════════════════

IF decision == "PASS":
  Output: "Quality Gate: PASS - Story ready for completion"

  Update session:
    - phase: "complete"
    - gate_decision: "PASS"
    - p0_coverage: {p0_coverage}
    - p1_coverage: {p1_coverage}
    - overall_coverage: {overall_coverage}

  Write sprint-status.yaml
  PROCEED TO STORY COMPLETION

ELSE IF decision == "CONCERNS":
  Output: "Quality Gate: CONCERNS - Minor gaps detected"

  Update session:
    - phase: "gate_decision"
    - gate_decision: "CONCERNS"

  Write sprint-status.yaml

  concerns_decision = AskUserQuestion(
    question: "Quality gate has CONCERNS. How to proceed?",
    header: "Gate Decision",
    options: [
      {label: "Accept and continue", description: "Acknowledge gaps, mark story done"},
      {label: "Loop back to dev", description: "Fix gaps, re-run phases 4-8"},
      {label: "Skip story", description: "Mark as skipped, continue to next"},
      {label: "Stop", description: "Save state and exit"}
    ]
  )

  Handle concerns_decision (see LOOP-BACK LOGIC below)

ELSE IF decision == "FAIL":
  Output: "Quality Gate: FAIL - Blocking issues detected"
  Output: "Gaps identified:"
  FOR each gap in gaps:
    Output: "  - {gap.ac_id}: {gap.reason}"

  Update session:
    - phase: "gate_decision"
    - gate_decision: "FAIL"

  Write sprint-status.yaml

  fail_decision = AskUserQuestion(
    question: "Quality gate FAILED. How to proceed?",
    header: "Gate Failed",
    options: [
      {label: "Loop back to dev", description: "Fix gaps, re-run phases 4-8"},
      {label: "Request waiver", description: "Document business justification"},
      {label: "Skip story", description: "Mark as skipped, continue to next"},
      {label: "Stop", description: "Save state and exit"}
    ]
  )

  IF fail_decision == "Request waiver":
    Output: "Requesting waiver for quality gate failure."
    Output: "Provide waiver details:"

    waiver_info = AskUserQuestion(
      question: "What is the business justification for waiver?",
      options: [
        {label: "Time-critical", description: "Deadline requires shipping now"},
        {label: "Low risk", description: "Missing coverage is low-risk area"},
        {label: "Tech debt", description: "Will address in future sprint"},
        {label: "Custom", description: "Provide custom justification"}
      ]
    )

    # Mark as WAIVED
    Update session:
      - gate_decision: "WAIVED"
      - waiver_reason: {waiver_info}

    PROCEED TO STORY COMPLETION

  ELSE:
    Handle fail_decision accordingly
```

---

## LOOP-BACK LOGIC

When user chooses "Loop back to dev" after gate FAIL or CONCERNS:

```
Output: "Looping back to Phase 4 (dev-story) to address gaps..."

# Reset tracking for phases 4-8
Update session:
  - phase: "dev_story"
  - review_iteration: 0
  - gate_iteration: {gate_iteration + 1}
  - gate_decision: null

Write sprint-status.yaml

# Provide gap context to dev-story
Task(
  subagent_type="epic-implementer",
  model="sonnet",
  description="Fix gaps for {story_key}",
  prompt="Fix quality gate gaps for story {story_key} (loop-back iteration {gate_iteration + 1}).

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md
- Previous gate decision: {previous_decision}

GAPS TO ADDRESS:
{FOR each gap in gaps:}
- {gap.ac_id}: {gap.reason}
{END FOR}

Add missing tests and implement missing functionality.
Run pnpm prepush. Ensure P0 coverage reaches 100%.
Return ONLY JSON: {gaps_fixed, tests_added, prepush_status, p0_coverage}"
)

# Continue through phases 5-8 again
PROCEED TO PHASE 5
```

---

## STEP 6: Story Completion - MANDATORY STATUS UPDATES

**CRITICAL: Execute these steps DIRECTLY using Edit tool (this is the exception to "no Edit" rule).**

After quality gate passes (PASS or WAIVED):

### 6.1 Update sprint-status.yaml

```
max_retries = 3
retry_count = 0

WHILE retry_count < max_retries:

  # 1. Read current file to get ACTUAL content
  content = Read("{sprint_artifacts}/sprint-status.yaml")

  # 2. Find current status - look for "  {story_key}: <status>"
  SEARCH for line matching "  {story_key}: " and extract current_status

  IF current_status == "done":
    Output: "✅ sprint-status.yaml already shows 'done'"
    BREAK

  # 3. Edit with EXACT strings (preserve 2-space indent)
  Edit(
    file_path="{sprint_artifacts}/sprint-status.yaml",
    old_string="  {story_key}: {current_status}",
    new_string="  {story_key}: done"
  )

  # 4. Verify by re-reading
  updated = Read("{sprint_artifacts}/sprint-status.yaml")
  IF updated contains "  {story_key}: done":
    Output: "✅ sprint-status.yaml updated successfully"
    BREAK
  ELSE:
    retry_count += 1
    Output: "⚠️ Verification failed, retry {retry_count}/{max_retries}"

END WHILE

IF retry_count >= max_retries:
  Output: "❌ FAILED to update sprint-status.yaml after 3 retries"
  HALT with "Manual intervention required for status update"
```

### 6.2 Update story file Status

```
max_retries = 3
retry_count = 0

WHILE retry_count < max_retries:

  # 1. Read story file
  content = Read("{sprint_artifacts}/stories/{story_key}.md")

  # 2. Find current Status line (e.g., "Status: in_progress")
  SEARCH for line starting with "Status: " and extract current_status

  IF current_status == "done":
    Output: "✅ Story file already shows 'done'"
    BREAK

  # 3. Edit with EXACT strings
  Edit(
    file_path="{sprint_artifacts}/stories/{story_key}.md",
    old_string="Status: {current_status}",
    new_string="Status: done"
  )

  # 4. Verify by re-reading
  updated = Read("{sprint_artifacts}/stories/{story_key}.md")
  IF updated contains "Status: done":
    Output: "✅ Story file status updated successfully"
    BREAK
  ELSE:
    retry_count += 1
    Output: "⚠️ Verification failed, retry {retry_count}/{max_retries}"

END WHILE

IF retry_count >= max_retries:
  Output: "❌ FAILED to update story file status after 3 retries"
  HALT with "Manual intervention required for status update"
```

### 6.3 Clear session state

Clear epic_dev_session (or update for next story)

```
Output:
═══════════════════════════════════════════════════════════════════════════
✅ STORY COMPLETE: {story_key}
═══════════════════════════════════════════════════════════════════════════
Phases completed: 8/8
Quality Gate: {gate_decision}
Coverage: P0={p0_coverage}%, P1={p1_coverage}%, Overall={overall_coverage}%
Status updated: sprint-status.yaml and story file → done
═══════════════════════════════════════════════════════════════════════════

IF NOT --yolo AND more_stories_remaining:
  next_decision = AskUserQuestion(
    question: "Continue to next story: {next_story_key}?",
    header: "Next Story",
    options: [
      {label: "Continue", description: "Process next story with full 8-phase workflow"},
      {label: "Stop", description: "Exit (resume later with /epic-dev-full {epic_num} --resume)"}
    ]
  )

  IF next_decision == "Stop":
    HALT
```

---

## STEP 7: Epic Completion - MANDATORY EPIC STATUS UPDATE

When all stories in the epic are done (no more pending stories):

**CRITICAL: Execute these steps DIRECTLY using Edit tool.**

### 7.1 Update epic status in sprint-status.yaml

```
max_retries = 3
retry_count = 0

WHILE retry_count < max_retries:

  # 1. Read current file
  content = Read("{sprint_artifacts}/sprint-status.yaml")

  # 2. Find current epic status - look for "  epic-{epic_num}: <status>"
  SEARCH for line matching "  epic-{epic_num}: " and extract current_status

  IF current_status == "done":
    Output: "✅ Epic status already shows 'done'"
    BREAK

  # 3. Edit with EXACT strings
  Edit(
    file_path="{sprint_artifacts}/sprint-status.yaml",
    old_string="  epic-{epic_num}: {current_status}",
    new_string="  epic-{epic_num}: done"
  )

  # 4. Verify
  updated = Read("{sprint_artifacts}/sprint-status.yaml")
  IF updated contains "  epic-{epic_num}: done":
    Output: "✅ Epic status updated successfully"
    BREAK
  ELSE:
    retry_count += 1
    Output: "⚠️ Verification failed, retry {retry_count}/{max_retries}"

END WHILE
```

### 7.2 Update epic retrospective status (if exists)

```
# Look for retrospective entry
content = Read("{sprint_artifacts}/sprint-status.yaml")

IF content contains "epic-{epic_num}-retrospective:":
  SEARCH for "  epic-{epic_num}-retrospective: " and extract current_status

  IF current_status in ["optional", "backlog"]:
    Edit(
      file_path="{sprint_artifacts}/sprint-status.yaml",
      old_string="  epic-{epic_num}-retrospective: {current_status}",
      new_string="  epic-{epic_num}-retrospective: pending"
    )
    Output: "✅ Retrospective status set to 'pending'"
```

### 7.3 Verify all story statuses

```
content = Read("{sprint_artifacts}/sprint-status.yaml")

# Count stories for this epic that are NOT done
SEARCH for all lines matching "  {epic_num}-*: "
FOR each match:
  IF status != "done":
    Output: "⚠️ Story {key} is still '{status}' - epic cannot be complete"
    HALT

Output: "✅ All {count} stories verified as 'done'"
```

```
Output:
════════════════════════════════════════════════════════════════════════════════
✅ EPIC {epic_num} COMPLETE!
════════════════════════════════════════════════════════════════════════════════
Stories completed: {count}
Total phases executed: {count * 8}
All quality gates: {summary}
Epic status: done
Retrospective status: pending

Next steps:
- Retrospective: /bmad:bmm:workflows:retrospective
- Next epic: /epic-dev-full {next_epic_num}
════════════════════════════════════════════════════════════════════════════════
```

---

## ERROR HANDLING

On any workflow failure:

```
1. Capture error output
2. Update session:
   - phase: "error"
   - last_error: "{error_message}"
3. Write sprint-status.yaml

4. Display error with phase context:
   Output: "ERROR in Phase {current_phase}: {error_message}"

5. Offer recovery options:
   error_decision = AskUserQuestion(
     question: "How to handle this error?",
     header: "Error Recovery",
     options: [
       {label: "Retry", description: "Re-run the failed phase"},
       {label: "Skip phase", description: "Skip to next phase (if safe)"},
       {label: "Skip story", description: "Mark story skipped, continue to next"},
       {label: "Stop", description: "Save state and exit"}
     ]
   )

6. Handle recovery choice:
   - Retry: Reset phase state, re-execute
   - Skip phase: Only allowed for non-critical phases (6, 7)
   - Skip story: Mark skipped in sprint-status, continue loop
   - Stop: HALT with resume instructions
```

---

## EXECUTE NOW

Parse "$ARGUMENTS" and begin processing immediately with the full 8-phase TDD/ATDD workflow.
