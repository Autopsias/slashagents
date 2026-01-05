# Contributing to CC_Agents_Commands

Thank you for your interest in contributing! This document provides guidelines for contributing to the CC_Agents_Commands collection.

## Code of Conduct

Be respectful, inclusive, and constructive. We welcome contributors of all experience levels.

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/Autopsias/claude-agents-commands/issues) first
2. Open a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Claude Code version (`claude --version`)

### Suggesting Enhancements

1. Open an issue with the `enhancement` label
2. Describe the use case and proposed solution
3. Explain how it benefits the community

### Submitting Changes

#### 1. Fork and Clone

```bash
git clone https://github.com/YOUR-USERNAME/claude-agents-commands.git
cd claude-agents-commands
```

#### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

#### 3. Make Changes

Follow our standards (see below).

#### 4. Test Your Changes

- Test commands in a clean Claude Code session
- Verify agents work without prerequisites (graceful failure)
- Run the validation checklist in `VALIDATION.md`

#### 5. Commit

```bash
git commit -m "feat: Add new-feature-name

Brief description of what this adds.

Co-Authored-By: Your Name <your.email@example.com>"
```

#### 6. Submit Pull Request

- Reference any related issues
- Describe what the PR does
- Include testing notes

## Standards

### File Naming

- **kebab-case** for all files (e.g., `unit-test-fixer.md`)
- Commands: `{action}-{target}.md`
- Agents: `{role}-{specialization}.md`

### Metadata Format

Every tool must have YAML frontmatter:

```yaml
---
name: tool-name
description: |
  Present-tense verb description under 60 characters.
  Additional context on second line if needed.
tools: Tool1, Tool2, Tool3
model: sonnet
---
```

### Description Voice

- Start with present-tense verb
- Under 60 characters for first line
- Examples:
  - "Fixes Python test failures for pytest and unittest"
  - "Manages pull request workflows via GitHub"

### No Hardcoded Paths

Tools must work across any project:

```markdown
<!-- Bad -->
/Users/username/project/tests/

<!-- Good -->
tests/
${PROJECT_ROOT}/tests/
```

### Tier Classification

Classify your tool:

| Tier | Prerequisites | Example |
|------|---------------|---------|
| Standalone | None | `/nextsession` |
| MCP-Enhanced | Requires MCP server | `/pr` (needs `github` MCP) |
| BMAD-Required | Requires BMAD framework | `/epic-dev` |
| Project-Context | Requires project files | `unit-test-fixer` |

## Pull Request Checklist

Before submitting:

- [ ] File follows kebab-case naming
- [ ] YAML frontmatter is complete and valid
- [ ] Description starts with present-tense verb
- [ ] No hardcoded paths
- [ ] Tested in clean Claude Code session
- [ ] Graceful failure if prerequisites missing
- [ ] Updated README.md if adding new tool

## Questions?

Open a [discussion](https://github.com/Autopsias/claude-agents-commands/discussions) for questions or ideas.

---

Thank you for contributing!
