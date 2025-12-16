# ATDD Checklist: Story 3.4 - Write Commands Reference Section

**Story:** 3-4-write-commands-reference-section
**TDD Phase:** RED (tests expected to fail)
**Target File:** README.md

## Acceptance Criteria Tests

### AC1: Workflow Moment Organization (4 subsections in order)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC1.1 | README.md contains `## Commands Reference` section | Present | [ ] |
| AC1.2 | Contains `### Starting Work` subsection | Present | [ ] |
| AC1.3 | Contains `### Building` subsection | Present | [ ] |
| AC1.4 | Contains `### Quality Gates` subsection | Present | [ ] |
| AC1.5 | Contains `### Shipping` subsection | Present | [ ] |
| AC1.6 | Subsections in correct order | Starting Work < Building < Quality Gates < Shipping | [ ] |
| AC1.7 | Starting Work contains `/nextsession` | Present in Starting Work | [ ] |
| AC1.8 | Starting Work contains `/epic-dev-init` | Present in Starting Work | [ ] |
| AC1.9 | Building contains `/epic-dev` | Present in Building | [ ] |
| AC1.10 | Building contains `/epic-dev-full` | Present in Building | [ ] |
| AC1.11 | Building contains `/parallelize` | Present in Building | [ ] |
| AC1.12 | Building contains `/parallelize-agents` | Present in Building | [ ] |
| AC1.13 | Quality Gates contains `/ci-orchestrate` | Present in Quality Gates | [ ] |
| AC1.14 | Quality Gates contains `/test-orchestrate` | Present in Quality Gates | [ ] |
| AC1.15 | Quality Gates contains `/usertestgates` | Present in Quality Gates | [ ] |
| AC1.16 | Shipping contains `/pr` | Present in Shipping | [ ] |
| AC1.17 | Shipping contains `/commit-orchestrate` | Present in Shipping | [ ] |

### AC2: Table Format (exact structure with Command, What it does, Prerequisites)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC2.1 | Starting Work has correct table header | `| Command | What it does | Prerequisites |` | [ ] |
| AC2.2 | Building has correct table header | `| Command | What it does | Prerequisites |` | [ ] |
| AC2.3 | Quality Gates has correct table header | `| Command | What it does | Prerequisites |` | [ ] |
| AC2.4 | Shipping has correct table header | `| Command | What it does | Prerequisites |` | [ ] |
| AC2.5 | Standalone commands use em dash (---) | `/nextsession`, `/test-orchestrate`, etc. use `---` | [ ] |
| AC2.6 | MCP-Enhanced commands use backtick format | `/ci-orchestrate` uses `\`github\` MCP` | [ ] |
| AC2.7 | BMAD-Required commands use BMAD framework | `/epic-dev-init` uses `BMAD framework` | [ ] |
| AC2.8 | Project-Context commands use descriptive text | `/usertestgates` uses descriptive prereq | [ ] |
| AC2.9 | Tables have separator row | `|---|---|---|` format present | [ ] |

### AC3: All 11 Commands Documented (each appears exactly once)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC3.1 | Exactly 11 unique commands documented | Count = 11 | [ ] |
| AC3.2 | `/nextsession` appears exactly once | Count = 1 | [ ] |
| AC3.3 | `/epic-dev-init` appears exactly once | Count = 1 | [ ] |
| AC3.4 | `/epic-dev` appears exactly once | Count = 1 | [ ] |
| AC3.5 | `/epic-dev-full` appears exactly once | Count = 1 | [ ] |
| AC3.6 | `/parallelize` appears exactly once | Count = 1 | [ ] |
| AC3.7 | `/parallelize-agents` appears exactly once | Count = 1 | [ ] |
| AC3.8 | `/ci-orchestrate` appears exactly once | Count = 1 | [ ] |
| AC3.9 | `/test-orchestrate` appears exactly once | Count = 1 | [ ] |
| AC3.10 | `/usertestgates` appears exactly once | Count = 1 | [ ] |
| AC3.11 | `/pr` appears exactly once | Count = 1 | [ ] |
| AC3.12 | `/commit-orchestrate` appears exactly once | Count = 1 | [ ] |
| AC3.13 | Every command has a description | Non-empty second column | [ ] |
| AC3.14 | Every command has prerequisites | Non-empty third column | [ ] |

### Edge Cases & Quality Checks

| ID | Priority | Test | Expected | Status |
|----|----------|------|----------|--------|
| EC1.1 | P1 | Commands Reference positioned after Quick Start | Section order correct | [ ] |
| EC1.2 | P1 | Commands Reference positioned before Agents Reference | Section order correct | [ ] |
| EC2.1 | P2 | No broken markdown in Commands Reference | Valid markdown syntax | [ ] |
| EC2.2 | P1 | Commands use kebab-case (no underscores) | No `/command_name` format | [ ] |
| EC2.3 | P2 | Commands wrapped in backticks | All commands use `` `/command` `` format | [ ] |
| EC3.1 | P2 | Descriptions start with present-tense verb | Verbs like "Generates", "Manages" | [ ] |
| EC3.2 | P1 | `/pr` command uses `github` MCP prerequisite | Correct MCP notation | [ ] |
| EC3.3 | P2 | Section has intro sentence | Explains workflow moment organization | [ ] |

## Command Reference (for implementation)

| Command | Workflow Moment | Description | Prerequisites |
|---------|-----------------|-------------|---------------|
| `/nextsession` | Starting Work | Generates continuation prompt for next session | --- |
| `/epic-dev-init` | Starting Work | Verifies BMAD project setup for epic development | BMAD framework |
| `/epic-dev` | Building | Automates BMAD development cycle for epic stories | BMAD framework |
| `/epic-dev-full` | Building | Executes full TDD/ATDD-driven BMAD development | BMAD framework |
| `/parallelize` | Building | Parallelizes tasks across multiple sub-agents | --- |
| `/parallelize-agents` | Building | Parallelizes tasks using specialized subagents | --- |
| `/ci-orchestrate` | Quality Gates | Orchestrates CI failure analysis and fixes | `github` MCP |
| `/test-orchestrate` | Quality Gates | Orchestrates test failure analysis and fixes | --- |
| `/usertestgates` | Quality Gates | Runs prioritized test suites with quality gates | test gates infrastructure |
| `/pr` | Shipping | Manages pull request workflows | `github` MCP |
| `/commit-orchestrate` | Shipping | Orchestrates git commit with quality checks | --- |

## Validation Script

Run: `./tests/atdd/3-4-write-commands-reference-section.sh`

## Pass Criteria

All tests must pass (exit code 0) for story completion.

## Current Status

**Phase:** RED - Tests expected to fail
**Test Count:** 40 tests (31 core ATDD + 9 edge case/quality tests)
**Coverage:**
- AC1 (Workflow Moment Organization): 17 tests
- AC2 (Table Format): 9 tests
- AC3 (All 11 Commands): 14 tests
- Edge Cases/Quality: 8 tests

**Priority Distribution:**
- P0: 31 tests (core acceptance criteria)
- P1: 5 tests (section positioning, kebab-case, MCP notation)
- P2: 4 tests (markdown quality, backticks, verbs, intro sentence)
