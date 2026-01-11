# Interactive Failure Handler Library

Shared library for handling failures during refactoring operations. Provides user prompts for continue/abort/retry decisions.

---

## Overview

When a refactoring agent fails, this library provides an interactive prompt allowing the user to decide whether to:
1. **Continue** - Skip the failed file and proceed with remaining work
2. **Abort** - Stop all refactoring, preserve current state
3. **Retry** - Attempt to refactor the failed file again

---

## Failure Prompt Template

When a refactoring failure occurs, display this prompt:

```markdown
## Refactoring Failed

**File**: {failed_file}
**Error**: {error_summary}
**Rollback Status**: {rollback_status}

### Error Details
```
{error_message_first_500_chars}
```

### Remaining Queue
{remaining_count} files remaining to refactor:
1. {file_1} ({loc_1} LOC, priority: {priority_1})
2. {file_2} ({loc_2} LOC, priority: {priority_2})
{...truncate if > 5 files...}

### Options
1. **Continue** - Skip failed file, proceed with remaining {remaining_count} files
2. **Abort** - Stop refactoring, preserve current state
3. **Retry** - Attempt to refactor {failed_file} again

What would you like to do?
```

---

## Implementation with AskUserQuestion

Use the AskUserQuestion tool to present the failure prompt:

```
AskUserQuestion(
  questions=[{
    "question": "Refactoring of {failed_file} failed with: {error_summary}. {remaining_count} files remain. What would you like to do?",
    "header": "Failure",
    "options": [
      {
        "label": "Continue with remaining files",
        "description": "Skip {failed_file} and proceed with the remaining {remaining_count} files"
      },
      {
        "label": "Abort refactoring",
        "description": "Stop all refactoring now. Current state preserved, no rollback needed."
      },
      {
        "label": "Retry this file",
        "description": "Attempt to refactor {failed_file} again with the same approach"
      }
    ],
    "multiSelect": false
  }]
)
```

---

## Response Handling

### On "Continue"

```bash
# Log the decision
echo '{"event": "user_decision", "action": "continue", "skipped_file": "'$failed_file'", "remaining": '$remaining_count'}' >> .claude/logs/orchestration-$(date +%Y%m%d).jsonl

# Add to skipped files list
echo "$failed_file" >> .claude/cache/skipped-files.txt

# Remove from remaining queue
remaining_files=$(echo "$remaining_files" | grep -v "$failed_file")

# Continue with next file in queue
```

### On "Abort"

```bash
# Log the decision
echo '{"event": "user_decision", "action": "abort", "at_file": "'$failed_file'", "remaining_skipped": '$remaining_count'}' >> .claude/logs/orchestration-$(date +%Y%m%d).jsonl

# Clean up any locks
rm -f .claude/locks/*.lock

# Report final status
echo "
## Refactoring Aborted

**Completed**: {completed_count} files
**Skipped**: {skipped_count} files
**Aborted at**: {failed_file}
**Not started**: {remaining_count} files

Current codebase state is consistent (no partial changes).
"

# Exit orchestration
exit 0
```

### On "Retry"

```bash
# Log the decision
echo '{"event": "user_decision", "action": "retry", "file": "'$failed_file'", "attempt": '$retry_count'}' >> .claude/logs/orchestration-$(date +%Y%m%d).jsonl

# Increment retry counter
retry_count=$((retry_count + 1))

# Check retry limit (max 2 retries per file)
if [ $retry_count -gt 2 ]; then
    echo "Maximum retries (2) reached for $failed_file. Forcing continue or abort decision."
    # Force re-prompt without retry option
fi

# Re-attempt refactoring with same parameters
```

---

## Failure Context Collection

Before showing the prompt, collect relevant context:

```bash
collect_failure_context() {
    local failed_file="$1"
    local error_output="$2"

    # Extract key error information
    error_summary=$(echo "$error_output" | grep -E "(Error|Exception|FAILED)" | head -1)
    error_type=$(echo "$error_summary" | grep -oE "(AssertionError|ImportError|SyntaxError|RuntimeError|TestFailed)")

    # Check rollback status
    rollback_status="Unknown"
    if git stash list | grep -q "safe-refactor"; then
        rollback_status="Rollback available via git stash"
    fi

    # Get remaining files info
    remaining_count=$(echo "$remaining_files" | wc -w | tr -d ' ')

    # Build file list with metadata
    remaining_list=""
    for file in $remaining_files; do
        loc=$(wc -l < "$file" 2>/dev/null || echo "?")
        remaining_list="$remaining_list\n  - $file ($loc LOC)"
    done

    echo "$error_summary|$rollback_status|$remaining_count|$remaining_list"
}
```

---

## Integration with Orchestrators

### In code_quality.md

After each safe-refactor agent completes:

```markdown
### Check Agent Result

Parse agent JSON output:
- If status == "fixed": Mark file complete, continue
- If status == "partial": Prompt user with partial success context
- If status == "failed": Invoke failure-handler prompt

Example:
```json
{
  "status": "failed",
  "file": "services/user_service.py",
  "error": "Test test_user.py::test_create_user failed after migration",
  "rollback_performed": true
}
```
-> Trigger failure handler with collected context
```

### In ci_orchestrate.md

For refactoring-related failures:

```markdown
### Refactoring Failure Handling

When safe-refactor agent returns failed status:
1. Collect failure context
2. Check if file was rolled back properly
3. Present failure-handler prompt
4. Process user decision
5. Continue, abort, or retry based on response
```

### In test_orchestrate.md

For test file modification failures:

```markdown
### Test Modification Failure

When test fixer returns failed status:
1. Check if conftest.py was involved (higher risk)
2. Collect context about affected test suite
3. Present failure-handler prompt
4. Handle decision appropriately
```

---

## Observability

Log all failure handler invocations:

```json
{
  "event": "failure_handler_invoked",
  "timestamp": "2025-01-15T10:35:00Z",
  "failed_file": "services/user_service.py",
  "error_type": "TestFailed",
  "error_summary": "test_create_user failed after migration",
  "rollback_status": "completed",
  "remaining_files": 5,
  "retry_count": 0
}
```

Log user decisions:

```json
{
  "event": "failure_handler_decision",
  "timestamp": "2025-01-15T10:35:30Z",
  "decision": "continue",
  "failed_file": "services/user_service.py",
  "remaining_files": 5,
  "session_stats": {
    "completed": 3,
    "skipped": 1,
    "remaining": 5
  }
}
```

---

## Error Classification

Classify errors to provide better context to users:

| Error Type | Severity | Default Recommendation |
|------------|----------|----------------------|
| TestFailed | Medium | Continue (test may be flaky) |
| ImportError | High | Retry (may be transient) |
| SyntaxError | Critical | Abort (code corruption) |
| MergeConflict | Critical | Abort (manual resolution needed) |
| Timeout | Medium | Retry (resource contention) |
| PermissionError | High | Abort (environment issue) |

---

## Retry Strategy

### Exponential Backoff

```bash
calculate_retry_delay() {
    local attempt="$1"
    local base_delay=5  # seconds
    local max_delay=30  # seconds

    delay=$((base_delay * (2 ** (attempt - 1))))
    [ $delay -gt $max_delay ] && delay=$max_delay

    echo $delay
}
```

### Retry Modifications

On retry, consider these adjustments:
1. **First retry**: Same approach, fresh git stash
2. **Second retry**: More conservative chunking (smaller batches)
3. **Third attempt blocked**: Force continue/abort decision

---

## Session Summary

After orchestration completes (or aborts), provide session summary:

```markdown
## Refactoring Session Summary

### Statistics
| Metric | Count |
|--------|-------|
| Files attempted | 10 |
| Successfully refactored | 7 |
| Skipped (user decision) | 2 |
| Failed (aborted at) | 1 |

### Skipped Files
- `services/user_utils.py` - TestFailed (user chose continue)
- `services/auth_handler.py` - Timeout (user chose continue)

### Recommendations
- `services/user_utils.py`: Run `/test_orchestrate` to investigate test failures
- `services/auth_handler.py`: Check for resource contention, retry during low-load period

### Files Successfully Refactored
1. `services/payment_service.py` (612 -> 3 files)
2. `services/notification.py` (534 -> 2 files)
...
```

---

## Best Practices

1. **Always show rollback status** - Users need to know if state is recoverable
2. **Provide estimated time** - Help users decide between continue/abort
3. **Classify errors** - Different errors warrant different default recommendations
4. **Log all decisions** - Enable post-mortem analysis
5. **Limit retries** - Prevent infinite retry loops
6. **Clear remaining queue** - Users should see what's left before deciding
