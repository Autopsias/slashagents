# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.3.x   | :white_check_mark: |
| < 1.3   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in CC_Agents_Commands, please report it responsibly.

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Email security concerns to the repository maintainer via GitHub's private vulnerability reporting:
   - Go to the **Security** tab of this repository
   - Click **Report a vulnerability**
   - Provide a detailed description of the issue

### What to Include

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Any suggested fixes (optional)

### Response Timeline

- **Initial response**: Within 48 hours
- **Status update**: Within 7 days
- **Resolution target**: Within 30 days for critical issues

### Scope

This security policy covers:

- Slash commands in `commands/`
- Subagents in `agents/`
- Skills in `skills/`
- Plugin configuration in `plugin/`

### Out of Scope

The following are NOT security vulnerabilities in this project:

- Issues in Claude Code itself (report to [Anthropic](https://github.com/anthropics/claude-code))
- Issues in MCP servers (report to respective MCP server maintainers)
- Issues in the BMAD framework (report to [BMAD repository](https://github.com/codevalley/BMAD))

## Security Best Practices for Users

When using CC_Agents_Commands:

1. **Never commit API keys** - Use environment variables as shown in `plugin/MCP_SETUP.md`
2. **Review agent actions** - Agents can modify files; review changes before committing
3. **Keep Claude Code updated** - Run `claude update` regularly
4. **Use branch protection** - Enable branch protection rules on your repositories

## Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers who help improve this project.
