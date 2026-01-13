# Ralph Loop Pattern Library

Provides the fresh-context loop pattern for unattended/overnight command execution.

## Why This Library Exists

Traditional Claude sessions accumulate context over time, leading to:
1. Context window exhaustion on long-running tasks
2. Decreased accuracy as context fills up
3. No clean "checkpoint and restart" mechanism

The Ralph Loop pattern solves this by:
- Spawning FRESH Claude instances per iteration
- Each iteration gets a full 200K context window
- Completion signals allow early termination on success
- Blocking signals halt the loop for human intervention

---

## Core Pattern

```bash
# Ralph Loop execution pattern
# Used by: epic-dev, epic-dev-full, code-quality, test-orchestrate, ci-orchestrate

FOR iteration IN 1..loop_max:

  # 1. Spawn fresh Claude instance
  OUTPUT=$(claude -p "{inner_command}" --dangerously-skip-permissions 2>&1 | tee /dev/stderr)
  EXIT_CODE=$?

  # 2. Check completion signals
  IF OUTPUT matches regex "{completion_signals}":
    EXIT 0  # Success!

  # 3. Check blocking signals
  IF OUTPUT matches regex "{blocking_signals}":
    EXIT 1  # Needs human intervention

  # 4. Handle crash/error
  IF EXIT_CODE != 0:
    # Continue (may be transient)

  # 5. Delay before next iteration
  sleep {loop_delay}

END FOR

# Max iterations reached
EXIT 1
```

---

## Function: ralph_loop

Executes a command in fresh-context loop mode.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `inner_command` | string | required | The command to execute (without --loop) |
| `loop_max` | integer | 10 | Maximum number of iterations |
| `loop_delay` | integer | 5 | Seconds to wait between iterations |
| `completion_signals` | regex | varies | Regex pattern for success detection |
| `blocking_signals` | regex | varies | Regex pattern for halt detection |

### Standard Signals

**Completion Signals (per command):**

| Command | Completion Regex |
|---------|------------------|
| epic-dev | `EPIC.*COMPLETE\|All stories in Epic.*complete\|Epic.*finished` |
| epic-dev-full | `✅ EPIC.*COMPLETE\|All stories in Epic.*complete\|Epic.*finished` |
| code-quality | `All.*violations.*fixed\|0 violations remaining\|Code Quality.*PASS` |
| test-orchestrate | `All tests passing\|PYTEST_FAILURES=0.*VITEST_FAILURES=0\|0 failures` |
| ci-orchestrate | `All CI checks passing\|CI_STATUS.*passing\|CI pipeline.*PASS` |

**Blocking Signals (universal):**
```regex
HALT|BLOCKED|Cannot proceed|Manual intervention|STATUS UPDATE FAILED|Maximum.*depth
```

---

## Algorithm

```
FUNCTION ralph_loop(command, loop_max, loop_delay, completion_signals, blocking_signals):

  Output: "════════════════════════════════════════════════════════"
  Output: "🔄 RALPH LOOP MODE ACTIVATED"
  Output: "════════════════════════════════════════════════════════"
  Output: "  Command: {command}"
  Output: "  Max iterations: {loop_max}"
  Output: "  Delay between iterations: {loop_delay}s"
  Output: "  Fresh context per iteration: YES"
  Output: "════════════════════════════════════════════════════════"

  FOR iteration IN 1..loop_max:

    Output: ""
    Output: "═══════════════════════════════════════════════════════════"
    Output: "═══ RALPH ITERATION {iteration}/{loop_max} ═══"
    Output: "═══════════════════════════════════════════════════════════"
    Output: "Starting fresh Claude instance..."

    # Execute command in fresh Claude instance
    ```bash
    OUTPUT=$(claude -p "{command}" --dangerously-skip-permissions 2>&1 | tee /dev/stderr)
    EXIT_CODE=$?
    ```

    # Check for successful completion
    IF OUTPUT matches regex "{completion_signals}":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "✅ RALPH LOOP SUCCESS"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Completed at iteration {iteration}!"
      Output: "  Total iterations used: {iteration}/{loop_max}"
      Output: "════════════════════════════════════════════════════════"
      RETURN success

    # Check for blocking conditions
    IF OUTPUT matches regex "{blocking_signals}":
      Output: ""
      Output: "════════════════════════════════════════════════════════"
      Output: "⚠️ RALPH LOOP BLOCKED"
      Output: "════════════════════════════════════════════════════════"
      Output: "  Blocked at iteration {iteration}"
      Output: "  Reason: Manual intervention required"
      Output: "  Action: Review output above and resolve issue"
      Output: "════════════════════════════════════════════════════════"
      RETURN blocked

    # Handle crash/error (non-zero exit)
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
  Output: "════════════════════════════════════════════════════════"
  RETURN incomplete

END FUNCTION
```

---

## Usage in Commands

Commands should implement the `--loop` modifier like this:

### Step 1: Update frontmatter
```yaml
argument-hint: "... [--loop N] [--loop-delay S]"
```

### Step 2: Add Ralph Loop Detection early in the command
```markdown
## STEP 1.5: Ralph Loop Mode Detection

**If `--loop` is present in arguments, execute fresh-context loop instead of normal flow.**

```
IF "$ARGUMENTS" contains "--loop":

  # Extract loop parameters
  loop_max = extract_number_after("--loop", default=10)
  loop_delay = extract_number_after("--loop-delay", default=5)

  # Build inner command (remove --loop flags to avoid recursion)
  inner_flags = "$ARGUMENTS" without "--loop" and "--loop-delay"
  inner_command = "/{command_name} {inner_flags}"

  # Execute Ralph loop with command-specific signals
  ralph_loop(
    command=inner_command,
    loop_max=loop_max,
    loop_delay=loop_delay,
    completion_signals="{command_specific_completion_regex}",
    blocking_signals="HALT|BLOCKED|Cannot proceed|Manual intervention"
  )

  EXIT (with ralph_loop return code)

ELSE:
  # Normal execution
  PROCEED TO STEP 2
END IF
```
```

---

## Implementation Notes

### Preventing Infinite Recursion
The inner command MUST NOT include `--loop` flags:
```
# WRONG - Will recurse infinitely
inner_command = "/epic-dev 2 --yolo --loop 10"

# RIGHT - Loop flags stripped
inner_command = "/epic-dev 2 --yolo"
```

### Implied Flags
Some commands imply flags in loop mode:
- `--yolo` (skip confirmations) - typically implied for unattended execution
- `--fix` (auto-fix mode) - for quality/test commands

### Smart Signal Escalation
Some commands can modify their inner command based on output:
```
# If strategic mode suggested, add flag for next iteration
IF OUTPUT matches "recommend.*--strategic":
  inner_command += " --strategic"
```

### State Preservation
Commands with `--continue` support can resume progress:
```
# If state was saved, use --continue on subsequent iterations
IF OUTPUT matches "state.*saved|--continue to resume":
  inner_command = "/{command} --continue {other_flags}"
```

---

## Examples

```bash
# Run epic development overnight (max 10 iterations)
/epic-dev 2 --loop 10

# Run code quality fixes with 30s delay between iterations
/code_quality --fix --loop 5 --loop-delay 30

# Run test fixes in loop mode
/test_orchestrate --loop 10

# CI fixes in loop mode with strategic escalation
/ci_orchestrate --loop 10 --strategic
```

---

## Workflow Granularity

**v1.5.0+**: Ralph loops now operate at **phase level** instead of story/task level.

### Why Granularity Matters

**Problem with story-level loops:**
- Each story = 150-200K tokens (fills context window)
- Phases share context (accumulated confusion/tunnel vision)
- Only 1 story per 200K context window
- Recovery from failures uses same confused context

**Solution with phase-level loops:**
- Each phase = 20-50K tokens
- Fresh context per phase (no tunnel vision)
- 4-6 phases per 200K context window
- Fresh perspective on failures

### Phase Progression by Command

| Command | Phases | Tokens per Phase |
|---------|--------|------------------|
| `/epic-dev` | CREATE → DEVELOP → REVIEW | 20-50K |
| `/epic-dev-full` | CREATE → VALIDATION → ATDD → DEV → REVIEW → AUTOMATE → TEST_REVIEW → TRACE (8 phases) | 20-40K |
| `/ci-orchestrate` | LINTING → TYPES → TESTS | 30-50K |
| `/test-orchestrate` | UNIT → INTEGRATION → E2E → API → DATABASE | 25-40K |
| `/code-quality` | COMPLEXITY → FILE_LENGTH → DUPLICATION | 20-35K |

### Implementation Pattern

Commands using phase-level granularity add `--phase-single` to the inner command:

```markdown
# In Ralph Loop section:
IF "$ARGUMENTS" contains "--loop":
  # Phase-single flag enables one-phase-per-iteration
  inner_command = "/{command} {flags} --phase-single"
```

The `--phase-single` flag causes the command to:
1. Detect the next incomplete phase
2. Execute ONLY that phase
3. Update state (sprint-status.yaml or equivalent)
4. Exit with `PHASE_COMPLETE: {phase_name}` signal

### Comparison Table

| Aspect | Story-Level | Phase-Level |
|--------|-------------|-------------|
| **Iteration Unit** | Entire story (5+ phases) | Single phase |
| **Token Cost** | 150-200K per iteration | 20-50K per iteration |
| **Iterations per 200K** | 1 story | 4-6 phases |
| **Context Accumulation** | High (phases share context) | None (fresh per phase) |
| **Recovery from Failures** | Tunnel vision by end | Fresh perspective each phase |
| **Git Commits** | 1 per story | 1 per phase |
| **User Intervention** | Between stories only | Between phases |

### Best Practices Research

**Anthropic's Approach:**
> "Incremental, one-feature-per-session loops reduced wasted tokens and rework compared to monolithic attempts"

**snarktank/ralph Pattern:**
> "Pick the next failing story, implement, test, commit, update, and log"
This is PHASE-level: implement → test → commit (not multi-phase story)

**Boris Cherny's Pattern:**
> "Work on exactly one task. Check browser console, confirm change matches acceptance criteria, append to activity.md, update plan.md, make one git commit."

---

## Attribution

The Ralph Loop pattern is inspired by [snarktank/ralph](https://github.com/snarktank/ralph) (2.5k stars).

The key insight from Ralph is that **fresh context per iteration** prevents:
1. Context window exhaustion
2. Accumulated confusion from prior failed attempts
3. Agent "tunnel vision" from seeing too much prior work

By spawning a fresh Claude instance per iteration, each attempt gets:
- Full 200K context window
- Clean slate (no prior mistakes to confuse)
- Fresh perspective on the problem
