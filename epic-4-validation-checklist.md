# Epic 4 Validation Test Checklist

Use this checklist when performing the validation tests for Epic 4.

## Pre-Test Setup

### Environment Verification
- [ ] Fresh Claude Code installation OR cleared `~/.claude/` directory
- [ ] No existing CC_Agents_Commands files in `~/.claude/commands/`
- [ ] No existing CC_Agents_Commands files in `~/.claude/agents/`
- [ ] No existing CC_Agents_Commands files in `~/.claude/skills/`

### Test Repository Clone
- [ ] Repository cloned to test location
- [ ] On `epic-4-human-validation-and-release` branch
- [ ] All files present: README.md, VALIDATION.md, commands/, agents/, skills/

## Tool Testing - Standalone Tier (6 tools)

These should work immediately with zero configuration.

### Commands
- [ ] `/test-orchestrate` - Try running without arguments
- [ ] `/commit-orchestrate` - Try with a test message
- [ ] `/parallelize` - Try with a simple task
- [ ] `/parallelize-agents` - Try with a simple task
- [ ] `/nextsession` - Try running

### Agents  
- [ ] `@parallel-executor` - Try invoking

**Result:** __ of 6 tools working ✅

## Tool Testing - MCP-Enhanced Tier (5 tools)

These should show clear error messages about missing MCP servers.

### Commands
- [ ] `/pr` - Should mention `github` MCP requirement
- [ ] `/ci-orchestrate` - Should mention `github` MCP requirement

### Agents
- [ ] `@pr-workflow-manager` - Should mention `github` MCP requirement  
- [ ] `@digdeep` - Should mention `perplexity-ask` MCP requirement

### Skills
- [ ] Skill: `pr-workflow` - Should mention `github` MCP requirement

**Result:** __ of 5 tools showing graceful failure ✅

## Tool Testing - BMAD-Required Tier (3 tools)

These should show clear "BMAD framework not found" errors.

### Commands
- [ ] `/epic-dev` - Should explain BMAD requirement
- [ ] `/epic-dev-full` - Should explain BMAD requirement
- [ ] `/epic-dev-init` - Should explain BMAD requirement

**Result:** __ of 3 tools showing clear BMAD error ✅

## Tool Testing - Project-Context Tier (9 tools)

These should show clear error messages about missing project files.

### Agents
- [ ] `@unit-test-fixer` - Should mention no test files found
- [ ] `@api-test-fixer` - Should mention no API test files found
- [ ] `@database-test-fixer` - Should mention no database test files found
- [ ] `@e2e-test-fixer` - Should mention no E2E test files found
- [ ] `@linting-fixer` - Should mention no linting config found
- [ ] `@type-error-fixer` - Should mention no Python/TS files found
- [ ] `@import-error-fixer` - Should mention no code files found
- [ ] `@security-scanner` - Should mention no code files found

### Commands
- [ ] `/usertestgates` - Should mention no test gate infrastructure

**Result:** __ of 9 tools showing actionable errors ✅

## First-Use Test Results

Complete this section after testing:

### Tester Information
- **Name:** 
- **Date:** 
- **Claude Code Version:** 
- **Experience Level:** Beginner / Intermediate / Advanced

### Installation Experience
- **Time to install:** ___ minutes
- **Installation steps clear?** 1-5 rating: __
- **Any confusion points?** 

### Command Experience
- **First command tried:** 
- **First command success?** Yes / No
- **Error messages helpful?** Yes / No

### Overall Feedback
- **Would recommend to colleague?** Yes / No
- **Most confusing part:** 
- **Suggested improvements:** 

---

## Validation Matrix Results

After testing all tools, update the VALIDATION.md file:

| Tool | Clean Env Test | Graceful Failure |
|------|----------------|------------------|
| test-orchestrate | ✅ | N/A |
| commit-orchestrate | ✅ | N/A |
| parallelize | ✅ | N/A |
| parallelize-agents | ✅ | N/A |
| nextsession | ✅ | N/A |
| parallel-executor | ✅ | N/A |
| pr | N/A | ✅ |
| ci-orchestrate | N/A | ✅ |
| pr-workflow-manager | N/A | ✅ |
| digdeep | N/A | ✅ |
| pr-workflow (skill) | N/A | ✅ |
| epic-dev | N/A | ✅ |
| epic-dev-full | N/A | ✅ |
| epic-dev-init | N/A | ✅ |
| unit-test-fixer | N/A | ✅ |
| api-test-fixer | N/A | ✅ |
| database-test-fixer | N/A | ✅ |
| e2e-test-fixer | N/A | ✅ |
| linting-fixer | N/A | ✅ |
| type-error-fixer | N/A | ✅ |
| import-error-fixer | N/A | ✅ |
| security-scanner | N/A | ✅ |
| usertestgates | N/A | ✅ |

**Total:** 23/23 tools validated ✅
