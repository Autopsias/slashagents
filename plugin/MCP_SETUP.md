# MCP Server Configuration Guide

This plugin includes pre-configured MCP (Model Context Protocol) servers that enhance the capabilities of certain tools. This guide explains which servers are required, how to set them up, and which tools benefit from them.

## Overview

MCP servers extend Claude Code's capabilities by providing integrations with external services like GitHub, Perplexity AI, Exa search, and browser automation tools. The plugin includes a `.mcp.json` configuration file with **8 pre-configured MCP servers** that makes setup straightforward.

## Required vs Optional Servers

### Required for Specific Tools

These MCP servers are **required** only if you want to use the tools that depend on them. All other tools in the plugin work without any MCP configuration.

| MCP Server | Required By | Purpose |
|------------|-------------|---------|
| `github` | `/pr`, `/ci-orchestrate`, `pr-workflow-manager` | GitHub API integration for PR management and CI operations |
| `perplexity-ask` | `digdeep`, `test-strategy-analyst` | AI-powered research and root cause analysis |
| `exa` | `digdeep`, `test-strategy-analyst` | Advanced web search and research capabilities |
| `ref` | `digdeep` | Documentation search (official framework/library docs) |
| `grep` | `digdeep` | GitHub code search for real-world examples |
| `semgrep-hosted` | `digdeep`, `security-scanner` | Security vulnerability scanning and code analysis |
| `chrome-devtools` | `browser-executor`, `chrome-browser-executor` | Browser automation via Chrome DevTools |
| `playwright` | `playwright-browser-executor` | E2E test automation with Playwright |

### Optional for All Users

If you don't use the tools listed above, you don't need to configure any MCP servers. The majority of commands and agents work standalone.

## Setup Instructions

### 1. Copy MCP Configuration

The plugin includes a pre-configured `.mcp.json` file. You have two options:

**Option A: Project-Level (Recommended for specific projects)**
```bash
# Copy to your project's .claude folder
cp ~/.claude/plugins/cc-agents-commands/.mcp.json /path/to/your/project/.claude/
```

**Option B: Global (All projects)**
```bash
# Copy to your global Claude config
cp ~/.claude/plugins/cc-agents-commands/.mcp.json ~/.claude/
```

### 2. API Key Setup

The MCP configuration references environment variables for API keys. This section explains how to set up each key by priority tier.

#### Tier 1 - Recommended (High Value)

These MCPs provide the most value across many commands:

| MCP Server | Environment Variable | Get Key From |
|------------|---------------------|--------------|
| `github` | `GITHUB_TOKEN` | [github.com/settings/tokens](https://github.com/settings/tokens) (scopes: `repo`, `workflow`) |
| `perplexity-ask` | `PERPLEXITY_API_KEY` | [perplexity.ai/settings/api](https://www.perplexity.ai/settings/api) |

#### Tier 2 - Useful (Moderate Value)

Helpful for web research and documentation lookup:

| MCP Server | Environment Variable | Get Key From |
|------------|---------------------|--------------|
| `exa` | `EXA_API_KEY` | [exa.ai](https://exa.ai/) (dashboard after signup) |
| `ref` | `REF_API_KEY` | [ref.tools/dashboard](https://ref.tools/dashboard) |

#### Tier 3 - Specialized (Niche Use Cases)

Only needed for specific browser automation or security scanning tasks:

| MCP Server | Environment Variable | Get Key From |
|------------|---------------------|--------------|
| `chrome-devtools` | none | No API key needed |
| `playwright` | none | No API key needed |
| `semgrep-hosted` | none | No API key needed |
| `grep` | none | No API key needed |

#### Environment Variable Configuration

Set these in your shell profile (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
# Tier 1 - Recommended
export GITHUB_TOKEN="your_github_personal_access_token"
export PERPLEXITY_API_KEY="your_perplexity_api_key"

# Tier 2 - Useful
export EXA_API_KEY="your_exa_api_key"
export REF_API_KEY="your_ref_api_key"

# No keys needed for Tier 3 (browser automation, code search)
```

After adding these to your shell profile, reload it:
```bash
source ~/.zshrc  # or ~/.bashrc
```

**Alternative:** For project-level configuration, you can also use a `.env` file in your project root. However, ensure it's added to `.gitignore` to prevent committing API keys.

### 3. Verification

To verify your MCP servers are configured correctly:

```bash
# Check if environment variables are set
echo $GITHUB_TOKEN
echo $PERPLEXITY_API_KEY
echo $EXA_API_KEY
echo $REF_API_KEY

# Try using a tool that requires MCP
/pr status  # Requires github MCP
```

## Tool Dependency Reference

### Standalone Tools (No MCP Required)

The majority of tools work without any MCP configuration:
- `/parallel`, `/parallelize`, `/parallelize-agents`
- `/commit-orchestrate`, `/test-orchestrate`
- `/coverage`, `/code-quality`, `/create-test-plan`
- `/nextsession`, `/usertestgates`, `/user-testing`
- Most fixer agents: `unit-test-fixer`, `api-test-fixer`, `database-test-fixer`, `e2e-test-fixer`, `linting-fixer`, `type-error-fixer`, `import-error-fixer`, `security-scanner`

### MCP-Enhanced Tools

These tools require specific MCP servers:

**GitHub MCP (`github`)**
- `/pr` - Pull request management
- `/ci-orchestrate` - CI/CD pipeline orchestration
- `pr-workflow-manager` - PR workflow automation
- `ci-infrastructure-builder` - CI infrastructure setup

**Research MCPs (`perplexity-ask`, `exa`)**
- `digdeep` - Five Whys root cause analysis
- `test-strategy-analyst` - Strategic test failure analysis
- `ci-strategy-analyst` - Strategic CI/CD analysis

**Browser Automation MCPs (`chrome-devtools`, `playwright`)**
- `browser-executor` - General browser automation
- `chrome-browser-executor` - Chrome-specific automation
- `playwright-browser-executor` - Playwright E2E automation

### BMAD-Required Tools

These tools require the BMAD framework (separate from MCP):
- `/epic-dev`, `/epic-dev-full`, `/epic-dev-init`, `/epic-dev-epic-end-tests`
- Related BMAD agents: `epic-story-creator`, `epic-story-validator`, `epic-test-generator`, `epic-implementer`, `epic-code-reviewer`

## Troubleshooting

**"MCP server not found" error:**
- Verify the `.mcp.json` file is in the correct location (project `.claude/` or global `~/.claude/`)
- Check that environment variables are set: `echo $GITHUB_TOKEN`
- Restart Claude Code after setting environment variables

**"Authentication failed" error:**
- Verify your API keys are valid and not expired
- For GitHub: ensure token has the required scopes (`repo`, `workflow`, `read:org`)
- Test API keys directly with curl to verify they work

**Browser automation not working:**
- `chrome-devtools` and `playwright` don't require API keys
- Ensure Chrome/Chromium is installed for browser automation
- Check that the MCP server packages are installed (they auto-install on first use)

## Cost Considerations

- **GitHub MCP**: Free (uses your GitHub account)
- **Perplexity**: Paid API (check pricing at perplexity.ai)
- **Exa**: Paid API with free tier (check pricing at exa.ai)
- **Browser Automation**: Free (local execution)

## Security Notes

- **Never commit** `.mcp.json` files with hardcoded API keys
- **Always use** environment variable syntax: `${VARIABLE_NAME}`
- **Store keys securely** in your shell profile or password manager
- **Rotate keys regularly** following security best practices
- **Use minimal scopes** for GitHub tokens (only what's needed)

## Additional Resources

- [Claude Code MCP Documentation](https://docs.claude.ai/mcp)
- [GitHub Token Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Perplexity API Documentation](https://docs.perplexity.ai/)
- [Exa API Documentation](https://docs.exa.ai/)

## Event Hooks

The plugin includes optional event hooks that can automate quality checks at key development moments. Hooks are configured in `hooks.json` and trigger automatically when specific events occur.

### Available Hooks

| Event | Command | Purpose | Blocking |
|-------|---------|---------|----------|
| `pre_push` | `/code-quality check` | Run linting and type checks before pushing code | Non-blocking (warns only) |

### How Hooks Work

Hooks are **optional** and **non-blocking** by default:
- **Optional**: Hooks don't prevent you from completing the action if they fail
- **Non-blocking**: Hooks run in warn mode - they notify you of issues but don't stop your workflow
- **Fast**: Hooks are designed to execute in under 30 seconds
- **Transparent**: You'll see when hooks run and what they check

### Enabling Hooks

Hooks are automatically enabled when the plugin is installed. The `hooks.json` file in the plugin directory defines all hook configurations.

### Disabling Individual Hooks

To disable a specific hook, edit `hooks.json` and remove the hook entry:

```bash
# Edit the hooks file
vim ~/.claude/plugins/cc-agents-commands/hooks.json

# Remove or comment out the hook you want to disable
```

Example of disabling the pre-push hook - simply remove the hook entry entirely:

```json
{
  "hooks": []
}
```

Or keep it for reference but leave the hooks array empty as shown above.

### Disabling All Hooks

To completely disable hooks, you have two options:

**Option 1: Remove the hooks.json file**
```bash
rm ~/.claude/plugins/cc-agents-commands/hooks.json
```

**Option 2: Empty the hooks array**
```bash
echo '{"hooks": []}' > ~/.claude/plugins/cc-agents-commands/hooks.json
```

### Troubleshooting Hooks

**Hook not running:**
- Verify `hooks.json` exists in the plugin directory
- Check JSON syntax is valid: `python3 -m json.tool hooks.json`
- Ensure the event name matches exactly (e.g., `pre_push` uses underscore, not hyphen `pre-push`) - Claude Code events use underscore naming convention

**Hook running too slowly:**
- Hooks should complete in under 30 seconds
- If a hook is slow, consider disabling it or using manual invocation instead
- Check if the command being triggered has performance issues

**Hook failing unexpectedly:**
- Remember hooks are non-blocking - they shouldn't prevent your workflow
- Check the command output for specific error messages
- Verify the command exists and has correct syntax

### Customizing Hooks

You can customize hooks by editing `hooks.json`. The file uses this format:

```json
{
  "hooks": [
    {
      "matcher": {
        "event": "event_name"
      },
      "hooks": [
        {
          "type": "command",
          "command": "/command-name args",
          "description": "What this hook does"
        }
      ]
    }
  ]
}
```

**Supported events** (based on Claude Code documentation):
- `pre_push` - Before pushing code to remote
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `Notification` - For notifications/alerts
- `Stop` - When agent stops

**Best practices for custom hooks:**
1. Keep hooks fast (< 30 seconds execution time)
2. Use non-blocking commands that warn rather than fail
3. Only hook events that provide clear value
4. Document why each hook exists
5. Test hooks thoroughly before committing

## Command Aliases

The plugin provides short-name aliases for all namespaced commands, allowing you to use familiar names like `/pr` instead of `/cc-agents-commands:pr`.

### What Are Aliases?

When you install the plugin via `--plugin-dir`, commands are namespaced to prevent conflicts with other plugins. For example, the PR command becomes `/cc-agents-commands:pr`. Aliases provide convenient shortcuts that delegate to the full namespaced commands.

### Available Aliases

All 18 commands have corresponding aliases in the `aliases/` directory:

| Alias | Delegates To |
|-------|--------------|
| `/ci-orchestrate` | `/cc-agents-commands:ci-orchestrate` |
| `/code-quality` | `/cc-agents-commands:code-quality` |
| `/commit-orchestrate` | `/cc-agents-commands:commit-orchestrate` |
| `/coverage` | `/cc-agents-commands:coverage` |
| `/create-test-plan` | `/cc-agents-commands:create-test-plan` |
| `/epic-dev` | `/cc-agents-commands:epic-dev` |
| `/epic-dev-epic-end-tests` | `/cc-agents-commands:epic-dev-epic-end-tests` |
| `/epic-dev-full` | `/cc-agents-commands:epic-dev-full` |
| `/epic-dev-init` | `/cc-agents-commands:epic-dev-init` |
| `/nextsession` | `/cc-agents-commands:nextsession` |
| `/parallel` | `/cc-agents-commands:parallel` |
| `/parallelize` | `/cc-agents-commands:parallelize` |
| `/parallelize-agents` | `/cc-agents-commands:parallelize-agents` |
| `/pr` | `/cc-agents-commands:pr` |
| `/test-epic-full` | `/cc-agents-commands:test-epic-full` |
| `/test-orchestrate` | `/cc-agents-commands:test-orchestrate` |
| `/user-testing` | `/cc-agents-commands:user-testing` |
| `/usertestgates` | `/cc-agents-commands:usertestgates` |

### How Aliases Work

Aliases use the Skill tool to invoke the namespaced command and pass through all arguments automatically. For example:

```markdown
# /pr (Alias)

Use the Skill tool to invoke: `cc-agents-commands:pr`
Pass through any arguments: $ARGUMENTS
```

### Using Aliases

Simply invoke commands using the short name:

```bash
# Instead of this:
/cc-agents-commands:pr status

# Use this:
/pr status

# Arguments are automatically passed through
/pr create story 5.7
/ci-orchestrate --fix-all
/commit-orchestrate
```

### Naming Conflicts

**Important:** If you have global commands with the same names, aliases may conflict. You have two options:

1. **Use the namespaced command** directly (e.g., `/cc-agents-commands:pr`)
2. **Rename or remove conflicting global commands** to use the aliases

Claude Code will prompt you if there's a naming conflict and let you choose which command to execute.

### Tab Completion

Aliases appear in Claude Code's tab completion alongside other commands. Type `/` and press Tab to see all available commands, including both namespaced commands and their aliases.

## Bundled Utility Scripts

The plugin includes utility scripts that enhance certain commands with token-efficient context caching and test gate discovery features.

### Overview

Scripts are located in the `scripts/` directory and are automatically discovered by commands that need them. No manual installation or configuration is required.

### Available Scripts

#### shared-discovery.sh

**Purpose:** Token-efficient project context caching for orchestration commands

**Used By:**
- `/ci-orchestrate`
- `/commit-orchestrate`
- `/test-orchestrate`

**What it does:**
- Discovers project structure, configuration files, and test patterns
- Caches results for 15 minutes to avoid redundant discovery
- Provides shared variables: `SHARED_CONTEXT`, `PROJECT_TYPE`, `VALIDATION_CMD`
- Saves ~8K tokens per orchestration command (2K per agent)

**How it works:**
Commands automatically source this script and call `discover_project_context`. Results are cached in `/tmp/claude-code-cache/` and reused for 15 minutes. The cache is automatically refreshed when stale.

**Example:**
```bash
# Automatically sourced by commands
source "${CLAUDE_PLUGIN_ROOT}/scripts/shared-discovery.sh"
discover_project_context

# Variables now available:
# - $PROJECT_TYPE (e.g., "node", "python", "rust")
# - $VALIDATION_CMD (e.g., "pnpm test", "pytest")
# - $SHARED_CONTEXT (summary of project context)
```

#### testgates_discovery.py

**Purpose:** Discovers test gates from project documentation

**Used By:**
- `/usertestgates`

**What it does:**
- Scans `docs/epics.md` for test gate definitions
- Outputs JSON format configuration for test gate execution
- Determines next test gate to run based on story status

**How it works:**
Commands automatically locate this script in plugin or global locations. It parses epic documentation to find test gate definitions and provides structured output.

**Example:**
```bash
# Automatically discovered by usertestgates command
python3 "$TESTGATES_SCRIPT" . --format json > /tmp/testgates_config.json
```

### Script Discovery

Commands use a **fallback chain** to locate scripts:

1. **Plugin location** (when installed as plugin): `${CLAUDE_PLUGIN_ROOT}/scripts/`
2. **Global installation**: `$HOME/.claude/lib/` or `$HOME/.claude/scripts/` (checked in this order)
3. **Inline fallback**: Commands gracefully degrade to inline discovery if scripts are not found

This ensures commands work in all installation modes without manual configuration.

### Cache Management

**shared-discovery.sh** uses automatic cache management:

- **Cache location**: `${TMPDIR:-/tmp}/claude-code-cache/`
- **Cache TTL**: 15 minutes (900 seconds)
- **Cache key**: Project path hash (unique per project)
- **Auto-refresh**: Stale caches are automatically regenerated

To manually clear the cache:
```bash
rm -rf /tmp/claude-code-cache/
```

### Troubleshooting Scripts

**Scripts not found:**
- Scripts are bundled in the plugin - no installation needed
- If seeing "script not found" warnings, commands will use inline fallback
- Verify plugin installation: `ls ~/.claude/plugins/cc-agents-commands/scripts/`

**Cache issues:**
- Clear cache manually: `rm -rf /tmp/claude-code-cache/`
- Cache is automatically refreshed after 15 minutes
- Each project has its own cache (no conflicts between projects)

**testgates_discovery.py errors:**
- Requires Python 3.6+ (uses f-strings and type hints)
- Only works for projects with `docs/epics.md` containing test gate definitions
- Uses only Python standard library (no external dependencies)

### Performance Impact

Scripts provide significant performance benefits:

- **Token savings**: ~8K tokens per orchestration command
- **Execution time**: Cached discovery adds <100ms overhead
- **Network impact**: None (all local operations)
- **Disk usage**: Minimal (<1KB per project cache)

## Support

For issues with:
- **MCP configuration**: Check Claude Code documentation
- **API keys**: Contact the respective service provider
- **Plugin tools**: Refer to the main README.md for tool-specific documentation
- **Event hooks**: Verify hooks.json syntax and event names
- **Utility scripts**: Check that plugin is installed correctly
