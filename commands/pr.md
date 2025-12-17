---
description: "Manages pull request workflows"
prerequisites: "`github` MCP"
argument-hint: "[action] [details] | Examples: 'create story 8.1', 'status', 'merge', 'fix CI'"
allowed-tools: ["Task", "Bash", "SlashCommand"]
---

# PR Workflow Helper

## STEP 0: Verify Prerequisites

Check if GitHub CLI (gh) is available:

```bash
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) not found"
  echo ""
  echo "This command requires the \`github\` MCP server configured in Claude Code."
  echo ""
  echo "To configure:"
  echo "  1. Open Claude Code settings"
  echo "  2. Add the \`github\` MCP server"
  echo "  3. Restart Claude Code session"
  echo ""
  echo "Learn more: https://modelcontextprotocol.io/docs/tools/github"
  exit 1
fi
```

---

Understand the user's PR request: "$ARGUMENTS"

## Default Behavior (No Arguments)

**When the user runs `/pr` with no arguments, default to "update" which commits all changes and pushes:**

If "$ARGUMENTS" is empty or not provided, treat it as "update" - meaning:
1. Stage all changes (`git add -A`)
2. Create a commit with an auto-generated message based on the changes
3. Push to the current branch

## Quick Status Check

If the user asks for "status" or similar, show a simple PR status:
```bash
gh pr view --json number,title,state,statusCheckRollup 2>/dev/null || echo "No PR for current branch"
```

## Delegate Complex Operations

For any PR operation (create, update, merge, review, fix CI, etc.), delegate to the pr-workflow-manager agent:

```
Task(
    subagent_type="pr-workflow-manager",
    description="Handle PR request: ${ARGUMENTS:-update}",
    prompt="User requests: ${ARGUMENTS:-update}

    **IMPORTANT:** If the request is empty or 'update':
    - Stage ALL changes (git add -A)
    - Auto-generate a commit message based on the diff
    - Push to the current branch
    - This is the DEFAULT behavior when /pr is run without arguments

    Please handle this PR operation which may include:
    - **update** (DEFAULT): Stage all, commit, and push
    - Creating PRs for stories
    - Checking PR status
    - Managing merges
    - Fixing CI failures (use /ci_orchestrate if needed)
    - Running quality reviews
    - Setting up auto-merge
    - Resolving conflicts
    - Cleaning up branches

    The pr-workflow-manager agent has full capability to handle all PR operations."
)
```

## Common Requests the Agent Handles

- **update** (DEFAULT when no args): Stage all changes, commit, and push
- Create PR for story
- Check PR status and health
- Merge PR (with auto-merge option)
- Fix CI/CD failures
- Run quality reviews
- Resolve merge conflicts
- Clean up merged branches

The pr-workflow-manager agent will handle all complexity and coordination with other specialist agents as needed.

## Intelligent Chain Invocation

When the pr-workflow-manager reports CI failures, automatically invoke the CI orchestrator:

```bash
# After pr-workflow-manager completes, check if CI failures were detected
# The agent will report CI status in its output
if [[ "$AGENT_OUTPUT" =~ "CI.*fail" ]] || [[ "$AGENT_OUTPUT" =~ "Checks.*failing" ]]; then
    echo "CI failures detected. Invoking /ci_orchestrate to fix them..."
    SlashCommand(command="/ci_orchestrate --fix-all")
fi
```