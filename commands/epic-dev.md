---
description: "Automate BMAD development cycle for stories in an epic"
argument-hint: "<epic-number> [--yolo] [--loop N] [--loop-delay S]"
---

# BMAD Epic Development

Execute development cycle for epic: "$ARGUMENTS"

---

## STEP 1: Parse Arguments

Parse "$ARGUMENTS":
- **epic_number** (required): First positional argument (e.g., "2")
- **--yolo**: Skip confirmation prompts between stories
- **--loop N**: Enable Ralph loop mode with max N iterations (default: 10)
- **--loop-delay S**: Seconds to wait between iterations (default: 5)

Validation:
- If no epic_number: Error "Usage: /epic-dev <epic-number> [--yolo] [--loop N]"

---

## STEP 1.5: Ralph Loop Mode Detection

**If `--loop` is present in arguments, execute fresh-context loop instead of normal flow.**

```
IF "$ARGUMENTS" contains "--loop":

  # Extract loop parameters
  loop_max = extract_number_after("--loop", default=10)
  loop_delay = extract_number_after("--loop-delay", default=5)

  Output: "════════════════════════════════════════════════════════"
  Output: "🔄 RALPH LOOP MODE ACTIVATED"
  Output: "════════════════════════════════════════════════════════"
  Output: "  Epic: {epic_num}"
  Output: "  Max iterations: {loop_max}"
  Output: "  Delay between iterations: {loop_delay}s"
  Output: "  Fresh context per iteration: YES"
  Output: "  Mode: Unattended (--yolo implied)"
  Output: "════════════════════════════════════════════════════════"
  Output: ""

  # Build inner command (without --loop to avoid infinite recursion)
  # --phase-single flag enables phase-level granularity (one phase per iteration)
  inner_command = "/epic-dev {epic_num} --yolo --phase-single"

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

    # Check for epic completion signals
    IF OUTPUT matches regex "EPIC.*COMPLETE|All stories in Epic.*complete|Epic.*finished":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "✅ RALPH LOOP SUCCESS"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Epic {epic_num} completed at iteration {iteration}!"
      Output: "  Total iterations used: {iteration}/{loop_max}"
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
      Output: "  Resume: /epic-dev {epic_num} --loop {remaining_iterations}"
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
  Output: "  Resume: /epic-dev {epic_num} --loop {loop_max}"
  Output: "════════════════════════════════════════════════════════"
  EXIT 1

ELSE:
  # Normal execution - continue to STEP 2
  PROCEED TO STEP 2
END IF
```

---

## STEP 2: Verify BMAD Project

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

## STEP 3: Load Stories

Read `{sprint_artifacts}/sprint-status.yaml`

If not found:
- Error: "Run /bmad:bmm:workflows:sprint-planning first"

Find stories for epic {epic_number}:
- Pattern: `{epic_num}-{story_num}-{title}`
- Filter: status NOT "done"
- Order by story number

If no pending stories:
- Output: "All stories in Epic {epic_num} complete!"
- HALT

---

## MODEL STRATEGY

| Phase | Model | Rationale |
|-------|-------|-----------|
| create-story | opus | Deep understanding for quality stories |
| dev-story | sonnet | Balanced speed/quality for implementation |
| code-review | opus | Thorough adversarial review |

---

## STEP 4: Process Each Story

**Phase-Level Mode Detection:**

```
IF "--phase-single" in "$ARGUMENTS":
  # PHASE-LEVEL MODE: Execute ONLY the next incomplete phase

  Output: "📋 Phase-level mode active - executing next incomplete phase..."

  # Load current sprint status
  content = Read("{sprint_artifacts}/sprint-status.yaml")

  # Find next incomplete phase across all stories in epic
  # Story status progression: backlog -> created -> implemented -> reviewed -> done

  FOR each story in epic {epic_number}:
    story_status = Extract status from sprint-status.yaml

    IF story_status == "backlog":
      # PHASE: CREATE
      Output: "=== [PHASE: CREATE] Creating story: {story_key} ==="

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
Return ONLY JSON summary: {story_path, ac_count, task_count, status}"
      )

      # Update status (no status file update - let BMAD handle it)
      Output: "✅ PHASE_COMPLETE: CREATE {story_key}"
      Output: "   Story created with acceptance criteria"
      Exit 0

    ELIF story_status == "created":
      # PHASE: DEVELOP
      Output: "=== [PHASE: DEVELOP] Implementing story: {story_key} ==="

      Task(
        subagent_type="epic-implementer",
        model="sonnet",
        description="Develop story {story_key}",
        prompt="Implement story {story_key}.

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md

Execute the BMAD dev-story workflow.
Make all acceptance criteria pass.
Run pnpm prepush before completing.
Return ONLY JSON summary: {tests_passing, prepush_status, files_modified, status}"
      )

      # Run post-implementation verification gate
      Output: "=== [Gate 2.5] Verifying test state after implementation ==="

      verification_iteration = 0
      max_verification_iterations = 3

      WHILE verification_iteration < max_verification_iterations:
        ```bash
        cd {project_root}
        TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
        ```

        IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
          verification_iteration += 1
          Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing"

          IF verification_iteration < max_verification_iterations:
            Task(
              subagent_type="epic-implementer",
              model="sonnet",
              description="Fix failing tests (iteration {verification_iteration})",
              prompt="Fix failing tests for story {story_key}.

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

Fix the failing tests. Return JSON: {fixes_applied, tests_passing, status}"
            )
          ELSE:
            Output: "ERROR: Max verification iterations reached"
            Output: "Tests still failing - manual intervention required"
            Exit 1
        ELSE:
          Output: "VERIFICATION GATE 2.5 PASSED: All tests green"
          BREAK from loop
      END WHILE

      Output: "✅ PHASE_COMPLETE: DEVELOP {story_key}"
      Output: "   Implementation complete, all tests passing"
      Exit 0

    ELIF story_status == "implemented":
      # PHASE: REVIEW
      Output: "=== [PHASE: REVIEW] Reviewing story: {story_key} ==="

      Task(
        subagent_type="epic-code-reviewer",
        model="opus",
        description="Review story {story_key}",
        prompt="Review implementation for {story_key}.

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md

Execute the BMAD code-review workflow.
MUST find 3-10 specific issues.
Return ONLY JSON summary: {total_issues, high_issues, medium_issues, low_issues, auto_fixable}"
      )

      # Run post-review verification gate
      Output: "=== [Gate 3.5] Verifying test state after code review ==="

      verification_iteration = 0
      max_verification_iterations = 3

      WHILE verification_iteration < max_verification_iterations:
        ```bash
        cd {project_root}
        TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
        ```

        IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
          verification_iteration += 1
          Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing after review"

          IF verification_iteration < max_verification_iterations:
            Task(
              subagent_type="epic-implementer",
              model="sonnet",
              description="Fix post-review failures",
              prompt="Fix test failures caused by code review changes for story {story_key}.

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

Fix without reverting the review improvements.
Return JSON: {fixes_applied, tests_passing, status}"
            )
          ELSE:
            Output: "ERROR: Max verification iterations reached"
            Output: "Tests still failing - manual intervention required"
            Exit 1
        ELSE:
          Output: "VERIFICATION GATE 3.5 PASSED: All tests green after review"
          BREAK from loop
      END WHILE

      # CRITICAL: Update sprint-status.yaml story status to "done"
      max_retries = 3
      retry_count = 0

      WHILE retry_count < max_retries:
        content = Read("{sprint_artifacts}/sprint-status.yaml")
        SEARCH for line matching "  {story_key}: " and extract current_status

        IF current_status == "done":
          Output: "✅ sprint-status.yaml already shows 'done'"
          BREAK

        Edit(
          file_path="{sprint_artifacts}/sprint-status.yaml",
          old_string="  {story_key}: {current_status}",
          new_string="  {story_key}: done"
        )

        updated = Read("{sprint_artifacts}/sprint-status.yaml")
        IF updated contains "  {story_key}: done":
          Output: "✅ sprint-status.yaml updated successfully"
          BREAK
        ELSE:
          retry_count += 1
          Output: "⚠️ Verification failed, retry {retry_count}/{max_retries}"
      END WHILE

      # CRITICAL: Update story file Status field to "done"
      retry_count = 0
      WHILE retry_count < max_retries:
        content = Read("{sprint_artifacts}/stories/{story_key}.md")
        SEARCH for line starting with "Status: " and extract current_status

        IF current_status == "done":
          Output: "✅ Story file already shows 'done'"
          BREAK

        Edit(
          file_path="{sprint_artifacts}/stories/{story_key}.md",
          old_string="Status: {current_status}",
          new_string="Status: done"
        )

        updated = Read("{sprint_artifacts}/stories/{story_key}.md")
        IF updated contains "Status: done":
          Output: "✅ Story file status updated successfully"
          BREAK
        ELSE:
          retry_count += 1
          Output: "⚠️ Verification failed, retry {retry_count}/{max_retries}"
      END WHILE

      Output: "✅ PHASE_COMPLETE: REVIEW {story_key}"
      Output: "   Code review complete, story marked done"
      Exit 0

  END FOR

  # All stories complete - check if epic is done
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
        Output: "⚠️ Verification failed, retry {retry_count}/{max_retries}"
    END WHILE

    Output: "════════════════════════════════════════════════════════"
    Output: "✅ EPIC {epic_num} COMPLETE!"
    Output: "════════════════════════════════════════════════════════"
    Exit 0
  ELSE:
    Output: "ERROR: No incomplete phases found but epic not complete"
    Exit 1

ELSE:
  # STORY-LEVEL MODE: Original behavior (complete entire story)
  Output: "📋 Story-level mode active - executing complete stories..."
END IF
```

FOR each pending story:

### Create (if status == "backlog") - opus

```
IF status == "backlog":
  Output: "=== Creating story: {story_key} (opus) ==="
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
Return ONLY JSON summary: {story_path, ac_count, task_count, status}"
  )

  # Parse JSON response - expect: {"story_path": "...", "ac_count": N, "status": "created"}
  # Verify story was created successfully
```

### Develop - sonnet

```
Output: "=== Developing story: {story_key} (sonnet) ==="
Task(
  subagent_type="epic-implementer",
  model="sonnet",
  description="Develop story {story_key}",
  prompt="Implement story {story_key}.

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md

Execute the BMAD dev-story workflow.
Make all acceptance criteria pass.
Run pnpm prepush before completing.
Return ONLY JSON summary: {tests_passing, prepush_status, files_modified, status}"
)

# Parse JSON response - expect: {"tests_passing": N, "prepush_status": "pass", "status": "implemented"}
```

### VERIFICATION GATE 2.5: Post-Implementation Test Verification

**Purpose**: Verify all tests pass after implementation. Don't trust JSON output - directly verify.

```
Output: "=== [Gate 2.5] Verifying test state after implementation ==="

INITIALIZE:
  verification_iteration = 0
  max_verification_iterations = 3

WHILE verification_iteration < max_verification_iterations:

  # Orchestrator directly runs tests
  ```bash
  cd {project_root}
  TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
  ```

  IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
    verification_iteration += 1
    Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing"

    IF verification_iteration < max_verification_iterations:
      Task(
        subagent_type="epic-implementer",
        model="sonnet",
        description="Fix failing tests (iteration {verification_iteration})",
        prompt="Fix failing tests for story {story_key} (iteration {verification_iteration}).

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

Fix the failing tests. Return JSON: {fixes_applied, tests_passing, status}"
      )
    ELSE:
      Output: "ERROR: Max verification iterations reached"
      gate_escalation = AskUserQuestion(
        question: "Gate 2.5 failed after 3 iterations. How to proceed?",
        header: "Gate Failed",
        options: [
          {label: "Continue anyway", description: "Proceed to code review with failing tests"},
          {label: "Manual fix", description: "Pause for manual intervention"},
          {label: "Skip story", description: "Mark story as blocked"},
          {label: "Stop", description: "Save state and exit"}
        ]
      )
      Handle gate_escalation accordingly
  ELSE:
    Output: "VERIFICATION GATE 2.5 PASSED: All tests green"
    BREAK from loop
  END IF

END WHILE
```

### Review - opus

```
Output: "=== Reviewing story: {story_key} (opus) ==="
Task(
  subagent_type="epic-code-reviewer",
  model="opus",
  description="Review story {story_key}",
  prompt="Review implementation for {story_key}.

Context:
- Story file: {sprint_artifacts}/stories/{story_key}.md

Execute the BMAD code-review workflow.
MUST find 3-10 specific issues.
Return ONLY JSON summary: {total_issues, high_issues, medium_issues, low_issues, auto_fixable}"
)

# Parse JSON response
# If high/medium issues found, auto-fix and re-review
```

### VERIFICATION GATE 3.5: Post-Review Test Verification

**Purpose**: Verify all tests still pass after code review fixes.

```
Output: "=== [Gate 3.5] Verifying test state after code review ==="

INITIALIZE:
  verification_iteration = 0
  max_verification_iterations = 3

WHILE verification_iteration < max_verification_iterations:

  # Orchestrator directly runs tests
  ```bash
  cd {project_root}
  TEST_OUTPUT=$(cd apps/api && uv run pytest tests -q --tb=short 2>&1 || true)
  ```

  IF TEST_OUTPUT contains "FAILED" OR "failed" OR "ERROR":
    verification_iteration += 1
    Output: "VERIFICATION ITERATION {verification_iteration}/{max_verification_iterations}: Tests failing after review"

    IF verification_iteration < max_verification_iterations:
      Task(
        subagent_type="epic-implementer",
        model="sonnet",
        description="Fix post-review failures (iteration {verification_iteration})",
        prompt="Fix test failures caused by code review changes for story {story_key}.

Test failure output (last 50 lines):
{TEST_OUTPUT tail -50}

Fix without reverting the review improvements.
Return JSON: {fixes_applied, tests_passing, status}"
      )
    ELSE:
      Output: "ERROR: Max verification iterations reached"
      gate_escalation = AskUserQuestion(
        question: "Gate 3.5 failed after 3 iterations. How to proceed?",
        header: "Gate Failed",
        options: [
          {label: "Continue anyway", description: "Mark story done with failing tests (risky)"},
          {label: "Revert review", description: "Revert code review fixes"},
          {label: "Manual fix", description: "Pause for manual intervention"},
          {label: "Stop", description: "Save state and exit"}
        ]
      )
      Handle gate_escalation accordingly
  ELSE:
    Output: "VERIFICATION GATE 3.5 PASSED: All tests green after review"
    BREAK from loop
  END IF

END WHILE
```

### Complete - MANDATORY STATUS UPDATES

**CRITICAL: Execute these steps DIRECTLY (not via subagent). These are the ONLY Edit operations the orchestrator performs.**

After code review passes (Gate 3.5 green):

#### Step A: Update sprint-status.yaml

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

#### Step B: Update story file Status field

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

#### Step C: Confirm completion

Only after BOTH updates verified:
```
Output: "✅ Story {story_key} COMPLETE! Status updated to 'done' in both files."
```

### Confirm Next (unless --yolo)

```
IF NOT --yolo AND more_stories_remaining:
  decision = AskUserQuestion(
    question="Continue to next story: {next_story_key}?",
    options=[
      {label: "Continue", description: "Process next story"},
      {label: "Stop", description: "Exit (resume later with /epic-dev {epic_num})"}
    ]
  )

  IF decision == "Stop":
    HALT
```

---

## STEP 5: Epic Complete - MANDATORY EPIC STATUS UPDATE

When all stories in the epic are done (no more pending stories):

**CRITICAL: Execute these steps DIRECTLY using Edit tool.**

#### Step A: Update epic status in sprint-status.yaml

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

#### Step B: Update retrospective status (if exists)

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

#### Step C: Verify all story statuses

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
================================================
EPIC {epic_num} COMPLETE!
================================================
Stories completed: {count}
Epic status: done
Retrospective status: pending

Next steps:
- Retrospective: /bmad:bmm:workflows:retrospective
- Next epic: /epic-dev {next_epic_num}
================================================
```

---

## ERROR HANDLING

On workflow failure:
1. Display error with context
2. Ask: "Retry / Skip story / Stop"
3. Handle accordingly

---

## EXECUTE NOW

Parse "$ARGUMENTS" and begin processing immediately.
