# CC_Agents_Commands

**Version:** 1.1.0 | **Updated:** 2025-12-25 | **Author:** Ricardo

A curated collection of 38 battle-tested Claude Code extensions designed to help developers **stay in flow**. This toolkit includes 17 slash commands (workflow automation like `/pr` and `/ci-orchestrate`), 20 agents (specialized agents for testing, code quality, and workflow automation), and 1 skill (reusable PR operations).

Whether you're managing pull requests, orchestrating CI pipelines, or following structured BMAD development cycles, these tools preserve your creative momentum by automating repetitive tasks and providing intelligent assistance exactly when you need it.

## Contents

| Type | Count | Description |

| ------ | ------- | ------------- |

| **Commands** | 17 | Slash commands for workflows (`/pr`, `/ci-orchestrate`, etc.) |

| **Agents** | 20 | Specialized agents for specific tasks |

| **Skills** | 1 | Reusable skill definitions |

## Installation

> ⚠️ **Warning:** If you have existing commands in `~/.claude/`, back them up first. New files with the same name will overwrite existing ones.

Follow these steps to install CC_Agents_Commands:

1. **Clone the repository**

   ```bash
   git clone https://github.com/ricardocarvalho/CC_Agents_Commands.git
   cd CC_Agents_Commands

   ```

2. **Backup existing commands** (if any exist)

   ```bash
   cp -r ~/.claude ~/.claude.backup

   ```

3. **Copy tools to your target location**

   Choose between **global** installation (tools available in all projects) or **project** installation (project-specific, version-controlled).

   **Global installation** (`~/.claude/`) - recommended for personal productivity tools:

   ```bash
   cp -r commands/ ~/.claude/commands/
   cp -r agents/ ~/.claude/agents/
   cp -r skills/ ~/.claude/skills/

   ```

   **Project installation** (`.claude/`) - recommended for team projects:

   ```bash
   cp -r commands/ .claude/commands/
   cp -r agents/ .claude/agents/
   cp -r skills/ .claude/skills/

   ```

4. **Start a new Claude Code session**

   Commands load automatically when you start a new session (no restart required).

5. **Verify installation**

   In your Claude Code session, type `/help` and you should see your installed commands listed.

## Quick Start

Try these commands to experience immediate value:

### Resume Your Workflow

Generates a continuation prompt to pick up where you left off in a new session.

```text

/nextsession

```text

### Check PR Status

Shows your open pull requests and their current state. _Note: Enhanced with `github` MCP server for full functionality._

```text

/pr status

```text

### Orchestrate Quality Checks

Runs quality checks, stages changes, and creates a well-formatted commit.

```text

/commit-orchestrate

```text

### The 'Aha' Moment: Auto-Fix CI Failures

Analyzes CI failures, spawns parallel agents, and fixes issues automatically. _Note: Enhanced with `github` MCP server for full functionality._

```text

/ci-orchestrate

```text

## CI/CD

This project uses self-hosted macOS runners for continuous integration. See [docs/SELF_HOSTED_RUNNERS.md](docs/SELF_HOSTED_RUNNERS.md) for runner setup and maintenance instructions.

**Pipeline:** `.github/workflows/docs-ci.yml`
- Markdown linting (markdownlint-cli2)
- Link validation (markdown-link-check)
- Shell script linting (ShellCheck)
- File structure validation
- Content validation (frontmatter, hardcoded paths)

**Maintenance:** Weekly automated cleanup via `runner-maintenance.yml`

## Commands Reference

Commands are organized by workflow moment to help you quickly find the right tool for your task.

### Starting Work

| Command | What it does | Prerequisites |

| --------- | -------------- | --------------- |

| `/nextsession` | Generates continuation prompt for next session | — |

| `/epic-dev-init` | Verifies BMAD project setup for epic development | BMAD framework |

### Building

| Command | What it does | Prerequisites |

| --------- | -------------- | --------------- |

| `/epic-dev` | Automates BMAD development cycle for epic stories | BMAD framework |

| `/epic-dev-full` | Executes full TDD/ATDD-driven BMAD development | BMAD framework |

| `/epic-dev-epic-end-tests` | Validates epic completion with NFR assessment | BMAD framework |

| `/parallelize` | Parallelizes tasks across sub-agents | — |

| `/parallelize-agents` | Parallelizes tasks with specialized agents | — |

### Quality Gates

| Command | What it does | Prerequisites |

| --------- | -------------- | --------------- |

| `/ci-orchestrate` | Orchestrates CI failure analysis and fixes | `github` MCP |

| `/test-orchestrate` | Orchestrates test failure analysis and fixes | test files and results |

| `/code-quality` | Analyzes and fixes code quality issues | code files in project |

| `/coverage` | Orchestrates test coverage improvement | test coverage tools |

| `/create-test-plan` | Creates comprehensive test plans | project documentation |

| `/test-epic-full` | Tests epic-dev-full command workflow | BMAD framework |

| `/user-testing` | Facilitates user testing sessions | user testing setup |

| `/usertestgates` | Finds and runs next test gate | test gates in project |

### Shipping

| Command | What it does | Prerequisites |

| --------- | -------------- | --------------- |

| `/pr` | Manages pull request workflows | `github` MCP |

| `/commit-orchestrate` | Orchestrates git commit with quality checks | — |

## Agents Reference

Agents are organized by domain to help you quickly find the right specialist for your task.

### Test Fixers

| Agent | What it does | Prerequisites |

| ------- | -------------- | --------------- |

| `unit-test-fixer` | Fixes Python test failures for pytest and unittest | test files in project |

| `api-test-fixer` | Fixes API endpoint test failures | API test files in project |

| `database-test-fixer` | Fixes database mock and integration test failures | database test files in project |

| `e2e-test-fixer` | Fixes Playwright E2E test failures | E2E test files in project |

### Code Quality

| Agent | What it does | Prerequisites |

| ------- | -------------- | --------------- |

| `linting-fixer` | Fixes Python linting and formatting issues | linting config in project |

| `type-error-fixer` | Fixes Python type errors and annotations | Python/TypeScript project |

| `import-error-fixer` | Fixes Python import and dependency errors | code files in project |

| `security-scanner` | Scans code for security vulnerabilities | code files in project |

| `code-quality-analyzer` | Analyzes code quality metrics and patterns | code files in project |

| `requirements-analyzer` | Analyzes and validates project requirements | project documentation |

### Workflow Support

| Agent | What it does | Prerequisites |

| ------- | -------------- | --------------- |

| `pr-workflow-manager` | Manages pull request workflows via GitHub | `github` MCP |

| `parallel-executor` | Executes tasks independently without delegation | — |

| `digdeep` | Performs Five Whys root cause analysis | `perplexity-ask` MCP |

### Testing & Strategy

| Agent | What it does | Prerequisites |

| ------- | -------------- | --------------- |

| `test-strategy-analyst` | Analyzes test failures with Five Whys methodology | `perplexity-ask` MCP, `exa` MCP |

| `test-documentation-generator` | Generates test failure runbooks and documentation | test files in project |

| `ui-test-discovery` | Discovers UI components for test generation | UI code in project |

| `validation-planner` | Plans validation strategies for features | project files |

| `scenario-designer` | Transforms requirements into test scenarios | project files |

| `evidence-collector` | Validates and collects test evidence | project files |

| `interactive-guide` | Guides human testers through validation | project files |

### CI/DevOps

| Agent | What it does | Prerequisites |

| ------- | -------------- | --------------- |

| `ci-strategy-analyst` | Analyzes CI/CD pipeline issues strategically | `perplexity-ask` MCP, `exa` MCP |

| `ci-infrastructure-builder` | Builds CI/CD infrastructure and workflows | `github` MCP |

| `ci-documentation-generator` | Generates CI/CD documentation | CI infrastructure |

### Browser Automation

| Agent | What it does | Prerequisites |

| ------- | -------------- | --------------- |

| `browser-executor` | Executes browser automation with Chrome DevTools | `chrome-devtools` MCP or `playwright` MCP |

| `chrome-browser-executor` | Chrome-specific browser automation executor | `chrome-devtools` MCP |

| `playwright-browser-executor` | Playwright-specific browser automation executor | `playwright` MCP |

## Skills Reference

Skills leverage agents to provide natural language interfaces for complex multi-step workflows.

| Skill | What it does | Prerequisites |

| ------- | -------------- | --------------- |

| `pr-workflow` | Manages PR workflows - create, status, merge, sync | `github` MCP (via pr-workflow-manager) |

## Troubleshooting

**Prerequisites notation:**
The Prerequisites column uses `—` for standalone tools, `server-name` MCP for tools requiring MCP servers, and "BMAD framework" or descriptive text for specialized requirements.

**MCP server not working?**
Configure the required MCP server in your Claude settings (e.g., `github` or `perplexity-ask`). Check the Prerequisites column in reference tables above to see which tools require MCP servers. Then restart Claude Code to apply the changes.

**BMAD commands not found?**
Install the BMAD framework from https://github.com/BESTRobotics/BMAD before using `/epic-dev`, `/epic-dev-full`, or `/epic-dev-init` commands. See BMAD documentation for installation instructions.

**Command or agent not recognized?**
Verify files are in the correct location (`~/.claude/` for global or `.claude/` for project). Then start a new Claude Code session (commands load automatically). Ensure you are in an active Claude Code session, not a regular terminal.

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- Some extensions require specific MCP servers (noted in individual files)
- BMAD extensions require BMAD framework installed

## License

MIT
