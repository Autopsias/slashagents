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

    # Execute command in fresh Claude instance with timeout protection
    ```bash
    ITERATION_START=$SECONDS
    TIMEOUT_MINUTES={timeout}  # Command-specific (see Timeout Recommendations)
    TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))

    # Start Claude in background
    LOG_FILE="/tmp/ralph-loop-{command}-iter-${iteration}.log"
    claude -p "{command}" --dangerously-skip-permissions > "$LOG_FILE" 2>&1 &
    CLAUDE_PID=$!

    # Monitor with timeout
    EXIT_CODE=0
    while kill -0 $CLAUDE_PID 2>/dev/null; do
      ELAPSED=$((SECONDS - ITERATION_START))
      if [ $ELAPSED -gt $TIMEOUT_SECONDS ]; then
        echo "⚠️ TIMEOUT: Exceeded ${TIMEOUT_MINUTES} minutes"
        kill -9 $CLAUDE_PID 2>/dev/null
        OUTPUT="TIMEOUT: Process exceeded ${TIMEOUT_MINUTES} minutes"
        EXIT_CODE=124
        break
      fi
      sleep 5
    done

    # Collect output if not timeout
    if [ $EXIT_CODE -ne 124 ]; then
      wait $CLAUDE_PID
      EXIT_CODE=$?
      OUTPUT=$(cat "$LOG_FILE")
      echo "$OUTPUT" | tee /dev/stderr
    fi

    # Cleanup
    rm -f "$LOG_FILE"
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

## Timeout Recommendations

**Critical Fix (2026-01-13):** All Ralph loop commands now include timeout protection to prevent indefinite hangs.

### Timeout Durations by Command

| Command | Timeout | Rationale |
|---------|---------|-----------|
| **epic-dev-full** | 20 minutes | 8 phases, opus-heavy (create, atdd, code-review, trace) |
| **epic-dev** | 15 minutes | 3 phases, uses opus for create/review |
| **code-quality** | 15 minutes | TEST-SAFE workflow with verification loops |
| **test-orchestrate** | 12 minutes | Parallel fixing with mostly sonnet/haiku |
| **ci-orchestrate** | 10 min (tactical)<br>20 min (strategic) | Tactical: fast fixes<br>Strategic: opus research |

### Implementation

```bash
ITERATION_START=$SECONDS
TIMEOUT_MINUTES=15  # Adjust per command
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))

# Start Claude in background with PID tracking
LOG_FILE="/tmp/ralph-loop-{command}-iter-${iteration}.log"
claude -p "{inner_command}" --dangerously-skip-permissions > "$LOG_FILE" 2>&1 &
CLAUDE_PID=$!

# Active monitoring with kill -0 every 5 seconds
while kill -0 $CLAUDE_PID 2>/dev/null; do
  ELAPSED=$((SECONDS - ITERATION_START))
  if [ $ELAPSED -gt $TIMEOUT_SECONDS ]; then
    echo "⚠️ TIMEOUT: Exceeded ${TIMEOUT_MINUTES} minutes"
    kill -9 $CLAUDE_PID 2>/dev/null
    EXIT_CODE=124
    break
  fi
  sleep 5
done

# Collect output and cleanup
if [ $EXIT_CODE -ne 124 ]; then
  wait $CLAUDE_PID
  EXIT_CODE=$?
  OUTPUT=$(cat "$LOG_FILE")
fi
rm -f "$LOG_FILE"
```

**Why timeout protection is critical:**
- Prevents 43-minute+ hangs from model selection prompts
- Detects stuck processes early (vs infinite wait)
- Enables unattended overnight execution
- Exit code 124 = timeout (standard convention)

---

## Model Selection Bypass

**Critical Fix (2026-01-13):** Commands using opus/sonnet/haiku model selection now support `--force-model` flag.

### Which Commands Need It

| Command | Needs --force-model? | Why |
|---------|---------------------|-----|
| **epic-dev** | ✅ YES | Uses opus for create/review phases |
| **epic-dev-full** | ✅ YES | Uses opus/sonnet/haiku across 8 phases |
| **ci-orchestrate** | ⚠️ CONDITIONAL | Only for `--strategic` mode (uses opus) |
| **test-orchestrate** | ❌ NO | Uses default models only |
| **code-quality** | ❌ NO | Uses default models only |

### Implementation Pattern

**For commands that always need it (epic-dev, epic-dev-full):**
```bash
inner_command = "/{command} {args} --yolo --phase-single --force-model"
```

**For conditional usage (ci-orchestrate):**
```bash
inner_command = "/ci_orchestrate {inner_flags} --fix-single-category"

# Add --force-model only if strategic mode
IF "{inner_flags}" contains "--strategic":
  inner_command = "{inner_command} --force-model"
```

**Problem solved:**
- Prevents indefinite hangs waiting for user confirmation on model selection
- Enables truly unattended Ralph loop execution
- Required for overnight/automated workflows

---

## Best Practices

### 1. Timeout Selection
- **Baseline**: Start with command's recommended timeout
- **Adjust up**: Complex projects, slow CI, large refactorings (+5 min)
- **Adjust down**: Simple fixes, fast tests (-3 min)
- **Never below**: 10 minutes (minimum for model latency + work)

### 2. Log File Management
- **Location**: Use `/tmp/ralph-loop-{command}-iter-${iteration}.log`
- **Cleanup**: Always `rm -f` after collecting output
- **Debugging**: Keep log files on failure for forensics

### 3. Process Monitoring
- **Check interval**: 5 seconds (balance between responsiveness and CPU)
- **PID tracking**: Use `$CLAUDE_PID` for clean termination
- **Kill signal**: Use `-9` (SIGKILL) for stuck processes (can't be ignored)

### 4. State Management
- **Update before blocking operations**: Session state, file status
- **Atomic writes**: Use temp file + mv for critical state
- **Verify after write**: Re-read to confirm persistence

### 5. Completion Signals
- **Be specific**: Match actual output patterns from commands
- **Use alternation**: `|` for multiple valid completion messages
- **Test regex**: Verify with actual command output

---

## Troubleshooting

### Timeout Occurring Too Soon

**Symptoms**: Legitimate work killed mid-execution

**Solutions:**
1. Increase `TIMEOUT_MINUTES` for that command
2. Check if strategic mode needs longer timeout
3. Profile: Is the work genuinely taking that long?

**Example:**
```bash
# epic-dev-full with large codebase might need more time
TIMEOUT_MINUTES=25  # Increase from default 20
```

### Process Hangs Despite Timeout

**Symptoms**: Process still running after timeout should have triggered

**Causes:**
1. `kill -0` check not running (bash syntax error)
2. `CLAUDE_PID` not set correctly
3. `TIMEOUT_SECONDS` calculation wrong

**Debug:**
```bash
# Add debug output
echo "PID: $CLAUDE_PID, Timeout: $TIMEOUT_SECONDS"

# Verify kill -0 works
kill -0 $CLAUDE_PID && echo "Process alive" || echo "Process dead"
```

### Exit Code 124 Not Detected

**Symptoms**: Timeout occurs but loop doesn't handle it

**Solution:**
Check that completion/blocking signal regexes don't accidentally match timeout output:
```bash
# Good: Specific patterns
IF OUTPUT matches regex "✅ EPIC.*COMPLETE|All stories.*complete"

# Bad: Too broad (matches timeout message)
IF OUTPUT matches regex ".*COMPLETE.*"
```

### State Loss After Interrupt

**Symptoms**: Resume fails, state file missing or stale

**Solutions:**
1. Verify state written BEFORE blocking Task calls
2. Use atomic writes (write to `.tmp` → `mv` to final name)
3. Check file permissions and disk space

**Defensive pattern:**
```bash
# DEFENSIVE: Update state BEFORE Task call
Update session:
  - phase: "in_progress"
Write state file

Task(...)  # May hang or crash

# Update again AFTER success
Update session:
  - phase: "complete"
Write state file
```

### --force-model Not Working

**Symptoms**: Model selection prompt still appears

**Causes:**
1. Flag not propagated to inner command
2. Flag spelled incorrectly
3. Command doesn't support the flag yet

**Verify:**
```bash
# Check inner command includes flag
echo "$inner_command"  # Should show --force-model

# Test directly
/epic-dev 2 --force-model  # Should not prompt
```

### Logs Not Captured

**Symptoms**: `OUTPUT` variable empty after execution

**Causes:**
1. Log file path wrong (typo or permission issue)
2. `cat` failing silently
3. File deleted before reading

**Fix:**
```bash
# Verify log file exists before reading
if [ -f "$LOG_FILE" ]; then
  OUTPUT=$(cat "$LOG_FILE")
else
  OUTPUT="ERROR: Log file not found"
fi
```

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
