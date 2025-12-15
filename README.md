# Claude Code Extensions

A curated collection of battle-tested Claude Code extensions designed to help developers stay in flow.

## Contents

| Type | Count | Description |
|------|-------|-------------|
| **Commands** | 11 | Slash commands for workflows (`/pr`, `/ci-orchestrate`, etc.) |
| **Agents** | 11 | Specialized subagents for specific tasks |
| **Skills** | 1 | Reusable skill definitions |

## Installation

Copy the desired folders to your Claude Code configuration directory:

```bash
# Global installation (all projects)
cp -r commands/ ~/.claude/commands/
cp -r agents/ ~/.claude/agents/
cp -r skills/ ~/.claude/skills/

# Project-specific installation
cp -r commands/ .claude/commands/
cp -r agents/ .claude/agents/
cp -r skills/ .claude/skills/
```

## Commands

| Command | Description |
|---------|-------------|
| `/pr` | Manages pull request workflows |
| `/ci-orchestrate` | Orchestrates CI/CD pipeline fixes |
| `/test-orchestrate` | Coordinates test failure analysis |
| `/commit-orchestrate` | Automates git commit workflows |
| `/parallelize` | Parallelizes tasks across sub-agents |
| `/parallelize-agents` | Parallelizes using specialized subagents |
| `/epic-dev` | BMAD development cycle automation |
| `/epic-dev-full` | Full TDD/ATDD BMAD development |
| `/epic-dev-init` | Verifies BMAD project setup |
| `/nextsession` | Generates continuation prompts |
| `/usertestgates` | Finds and runs next test gate |

## Agents

| Agent | Description |
|-------|-------------|
| `unit-test-fixer` | Fixes unit test failures |
| `api-test-fixer` | Fixes API endpoint test failures |
| `database-test-fixer` | Fixes database mock and fixture issues |
| `e2e-test-fixer` | Fixes end-to-end test failures |
| `linting-fixer` | Fixes linting errors |
| `type-error-fixer` | Fixes TypeScript type errors |
| `import-error-fixer` | Fixes import and module errors |
| `security-scanner` | Scans for security vulnerabilities |
| `pr-workflow-manager` | Manages PR lifecycle |
| `parallel-executor` | Executes tasks in parallel |
| `digdeep` | Advanced root cause analysis |

## Skills

| Skill | Description |
|-------|-------------|
| `pr-workflow` | Pull request operations skill |

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- Some extensions require specific MCP servers (noted in individual files)
- BMAD extensions require BMAD framework installed

## License

MIT
