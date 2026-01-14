# Status Updater Library

Provides reliable status file update patterns for orchestrator commands.

## Why This Library Exists

Status updates frequently fail because:
1. Edit tool requires EXACT string matching (including whitespace)
2. Indentation/whitespace mismatches cause silent failures
3. No retry mechanism when Edit fails to match
4. Verification step doesn't trigger retries on mismatch

This library provides:
- Read-before-edit pattern to get ACTUAL current value
- Exact string construction with proper indentation
- Verification after edit with retry mechanism
- Clear success/failure reporting

---

## Function: update_sprint_status

Updates a story or epic status in sprint-status.yaml.

### Parameters
- `sprint_artifacts`: Path to sprint artifacts folder (e.g., `docs/sprint-artifacts`)
- `item_key`: Story key (e.g., `2-3-auth-flow`) or epic key (e.g., `epic-2`)
- `new_status`: Target status (`done`, `in_progress`, `blocked`, `backlog`, etc.)

### Algorithm

```
FUNCTION update_sprint_status(sprint_artifacts, item_key, new_status):

  file_path = "{sprint_artifacts}/sprint-status.yaml"
  max_retries = 3
  retry_count = 0

  WHILE retry_count < max_retries:

    # Step 1: Read current file to get ACTUAL content
    content = Read(file_path)

    IF content is empty or file not found:
      Output: "ERROR: sprint-status.yaml not found at {file_path}"
      RETURN failure

    # Step 2: Find current status using regex
    # YAML format: "  {item_key}: <status>" (2-space indent)
    # Search for pattern like "  2-3-auth-flow: in_progress"

    SEARCH content for line matching:
      - Starts with "  " (2 spaces)
      - Followed by "{item_key}:"
      - Followed by space and status value

    Extract current_status from matched line

    IF no match found:
      Output: "ERROR: Could not find '{item_key}' in sprint-status.yaml"
      Output: "Searched in file: {file_path}"
      RETURN failure

    IF current_status == new_status:
      Output: "✅ Status already '{new_status}', no update needed"
      RETURN success

    # Step 3: Construct EXACT old and new strings
    # CRITICAL: Must match whitespace exactly
    old_string = "  {item_key}: {current_status}"
    new_string = "  {item_key}: {new_status}"

    # Step 4: Attempt Edit
    Output: "Updating {item_key}: {current_status} → {new_status}"

    Edit(
      file_path=file_path,
      old_string=old_string,
      new_string=new_string
    )

    # Step 5: Verify by re-reading file
    updated_content = Read(file_path)

    IF updated_content contains "  {item_key}: {new_status}":
      Output: "✅ Successfully updated {item_key} to '{new_status}'"
      RETURN success
    ELSE:
      retry_count += 1
      Output: "⚠️ Verification failed (attempt {retry_count}/{max_retries})"
      Output: "   Expected: '  {item_key}: {new_status}'"
      Output: "   Re-reading file for next attempt..."
      # Loop will re-read and try again with fresh content

  END WHILE

  Output: "❌ Failed to update {item_key} after {max_retries} retries"
  Output: "   Manual intervention required"
  RETURN failure

END FUNCTION
```

---

## Function: update_story_file_status

Updates the Status field in a story markdown file.

### Parameters
- `story_path`: Full path to story file (e.g., `docs/sprint-artifacts/stories/2-3-auth-flow.md`)
- `new_status`: Target status (`done`, `in_progress`, `blocked`, `review`, etc.)

### Algorithm

```
FUNCTION update_story_file_status(story_path, new_status):

  max_retries = 3
  retry_count = 0

  WHILE retry_count < max_retries:

    # Step 1: Read current file
    content = Read(story_path)

    IF content is empty or file not found:
      Output: "ERROR: Story file not found at {story_path}"
      RETURN failure

    # Step 2: Find current Status line
    # Markdown format: "Status: <value>" (typically near top of file)
    # May also appear as "**Status:** <value>"

    SEARCH content for line matching:
      - "Status: " followed by status value
      - OR "**Status:** " followed by status value

    Extract current_status from matched line
    Extract exact_prefix from matched line ("Status: " or "**Status:** ")

    IF no match found:
      Output: "ERROR: Could not find 'Status:' field in story file"
      Output: "File: {story_path}"
      RETURN failure

    IF current_status == new_status:
      Output: "✅ Story status already '{new_status}', no update needed"
      RETURN success

    # Step 3: Construct EXACT old and new strings
    old_string = "{exact_prefix}{current_status}"
    new_string = "{exact_prefix}{new_status}"

    # Step 4: Attempt Edit
    Output: "Updating story status: {current_status} → {new_status}"

    Edit(
      file_path=story_path,
      old_string=old_string,
      new_string=new_string
    )

    # Step 5: Verify by re-reading file
    updated_content = Read(story_path)

    IF updated_content contains "{exact_prefix}{new_status}":
      Output: "✅ Successfully updated story status to '{new_status}'"
      RETURN success
    ELSE:
      retry_count += 1
      Output: "⚠️ Verification failed (attempt {retry_count}/{max_retries})"
      Output: "   Re-reading file for next attempt..."

  END WHILE

  Output: "❌ Failed to update story status after {max_retries} retries"
  Output: "   Manual intervention required"
  RETURN failure

END FUNCTION
```

---

## Usage Pattern for Commands

Commands that need status updates (like `epic-dev.md`, `epic-dev-full.md`) should use this pattern:

```markdown
### Status Update - EXECUTE DIRECTLY (not via subagent)

**CRITICAL**: The orchestrator MUST execute these steps directly using Edit tool.
Do NOT delegate status updates to subagents.

#### Update sprint-status.yaml

1. Read current file: `{sprint_artifacts}/sprint-status.yaml`
2. Find line containing `{story_key}:` and extract current status
3. If already `done`, skip to step 6
4. Edit: Change `  {story_key}: {current_status}` to `  {story_key}: done`
5. Verify: Re-read file, grep for `{story_key}: done`
6. If verification fails: Retry up to 3 times, then HALT

#### Update story file Status

1. Read story file: `{sprint_artifacts}/stories/{story_key}.md`
2. Find line starting with `Status:` and extract current status
3. If already `done`, skip to step 6
4. Edit: Change `Status: {current_status}` to `Status: done`
5. Verify: Re-read file, confirm `Status: done`
6. If verification fails: Retry up to 3 times, then HALT

#### Confirm completion

Only after BOTH updates verified:
```
Output: "✅ Story {story_key} COMPLETE! Status updated in both files."
```
```

---

## Common Failure Modes and Solutions

| Failure | Cause | Solution |
|---------|-------|----------|
| "Could not find item_key" | Typo in story key OR different naming convention | Verify exact key format in sprint-status.yaml |
| Edit silently fails | old_string doesn't match exactly | Always read-before-edit to get actual value |
| Wrong indentation | YAML uses 2 spaces, Edit matched different whitespace | Use regex to detect actual indentation |
| Status field not found | Story file uses different format | Check for `**Status:**` variant |
| Concurrent modification | Multiple agents editing same file | Not supported - serialize status updates |

---

## Integration Notes

1. **Orchestrators ONLY**: Only orchestrator commands (epic-dev, epic-dev-full) should update status files
2. **Subagents report, don't update**: Subagents return JSON with completion info, orchestrator updates status
3. **Single writer**: Never have multiple agents trying to update the same status file simultaneously
4. **Verify before proceeding**: Don't continue to next story until status update is verified
