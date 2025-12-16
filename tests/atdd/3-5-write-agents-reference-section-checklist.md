# ATDD Checklist: Story 3.5 - Write Agents Reference Section

**Story:** 3-5-write-agents-reference-section
**TDD Phase:** RED (tests expected to fail)
**Target File:** README.md

## Acceptance Criteria Tests

### AC1: Domain Organization (3 subsections in order)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC1.1 | README.md contains `## Agents Reference` section | Present | [ ] |
| AC1.2 | Contains `### Test Fixers` subsection | Present | [ ] |
| AC1.3 | Contains `### Code Quality` subsection | Present | [ ] |
| AC1.4 | Contains `### Workflow Support` subsection | Present | [ ] |
| AC1.5 | Subsections in correct order | Test Fixers < Code Quality < Workflow Support | [ ] |
| AC1.6 | Test Fixers contains `unit-test-fixer` | Present in Test Fixers | [ ] |
| AC1.7 | Test Fixers contains `api-test-fixer` | Present in Test Fixers | [ ] |
| AC1.8 | Test Fixers contains `database-test-fixer` | Present in Test Fixers | [ ] |
| AC1.9 | Test Fixers contains `e2e-test-fixer` | Present in Test Fixers | [ ] |
| AC1.10 | Code Quality contains `linting-fixer` | Present in Code Quality | [ ] |
| AC1.11 | Code Quality contains `type-error-fixer` | Present in Code Quality | [ ] |
| AC1.12 | Code Quality contains `import-error-fixer` | Present in Code Quality | [ ] |
| AC1.13 | Code Quality contains `security-scanner` | Present in Code Quality | [ ] |
| AC1.14 | Workflow Support contains `pr-workflow-manager` | Present in Workflow Support | [ ] |
| AC1.15 | Workflow Support contains `parallel-executor` | Present in Workflow Support | [ ] |
| AC1.16 | Workflow Support contains `digdeep` | Present in Workflow Support | [ ] |
| AC1.17 | Exactly 3 domain subsections | Count = 3 | [ ] |

### AC2: Table Format (exact structure with Agent, What it does, Prerequisites)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC2.1 | Test Fixers has correct table header | `| Agent | What it does | Prerequisites |` | [ ] |
| AC2.2 | Code Quality has correct table header | `| Agent | What it does | Prerequisites |` | [ ] |
| AC2.3 | Workflow Support has correct table header | `| Agent | What it does | Prerequisites |` | [ ] |
| AC2.4 | Standalone agent uses em dash (---) | `parallel-executor` uses `---` | [ ] |
| AC2.5 | MCP-Enhanced agent uses backtick format | `pr-workflow-manager` uses `\`github\` MCP` | [ ] |
| AC2.6 | MCP-Enhanced agent uses backtick format | `digdeep` uses `\`perplexity-ask\` MCP` | [ ] |
| AC2.7 | Project-Context agents use descriptive text | `unit-test-fixer` uses descriptive prereq | [ ] |
| AC2.8 | Tables have separator row | `|---|---|---|` format present | [ ] |
| AC2.9 | All 3 subsections have separator rows | Count >= 3 | [ ] |

### AC3: All 11 Agents Documented (each appears exactly once)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC3.1 | Exactly 11 unique agents documented | Count = 11 | [ ] |
| AC3.2 | `unit-test-fixer` appears exactly once | Count = 1 | [ ] |
| AC3.3 | `api-test-fixer` appears exactly once | Count = 1 | [ ] |
| AC3.4 | `database-test-fixer` appears exactly once | Count = 1 | [ ] |
| AC3.5 | `e2e-test-fixer` appears exactly once | Count = 1 | [ ] |
| AC3.6 | `linting-fixer` appears exactly once | Count = 1 | [ ] |
| AC3.7 | `type-error-fixer` appears exactly once | Count = 1 | [ ] |
| AC3.8 | `import-error-fixer` appears exactly once | Count = 1 | [ ] |
| AC3.9 | `security-scanner` appears exactly once | Count = 1 | [ ] |
| AC3.10 | `pr-workflow-manager` appears exactly once | Count = 1 | [ ] |
| AC3.11 | `parallel-executor` appears exactly once | Count = 1 | [ ] |
| AC3.12 | `digdeep` appears exactly once | Count = 1 | [ ] |
| AC3.13 | Every agent has a description | Non-empty second column | [ ] |
| AC3.14 | Every agent has prerequisites | Non-empty third column | [ ] |

### Edge Cases & Quality Checks

| ID | Priority | Test | Expected | Status |
|----|----------|------|----------|--------|
| EC1.1 | P1 | Agents Reference positioned after Commands Reference | Section order correct | [ ] |
| EC1.2 | P1 | Agents Reference positioned before Skills Reference | Section order correct | [ ] |
| EC2.1 | P2 | No broken markdown in Agents Reference | Valid markdown syntax | [ ] |
| EC2.2 | P1 | Agents use kebab-case (no underscores) | No `agent_name` format | [ ] |
| EC2.3 | P2 | Agents wrapped in backticks | All agents use `` `agent-name` `` format | [ ] |
| EC3.1 | P2 | Descriptions start with present-tense verb | Verbs like "Analyzes", "Fixes" | [ ] |
| EC3.2 | P2 | Section has intro sentence | Explains domain organization | [ ] |
| EC4.1 | P1 | No duplicate agents across subsections | No duplicates | [ ] |
| EC4.2 | P2 | Table columns properly aligned | 4 pipes per row | [ ] |
| EC4.3 | P1 | Agent names match actual files | Files exist in agents/ | [ ] |
| EC4.4 | P2 | All agents have non-empty descriptions | No empty cells | [ ] |
| EC4.5 | P2 | All agents have non-empty prerequisites | No empty cells | [ ] |
| EC5.1 | P1 | Descriptions under 60 characters | All < 60 chars | [ ] |
| EC5.2 | P2 | Agents are lowercase kebab-case | No uppercase | [ ] |
| EC5.3a | P1 | unit-test-fixer only in Test Fixers | Correct section | [ ] |
| EC5.3b | P1 | linting-fixer only in Code Quality | Correct section | [ ] |
| EC5.3c | P1 | pr-workflow-manager only in Workflow Support | Correct section | [ ] |
| EC5.4 | P2 | Table separators have 3+ dashes | Proper format | [ ] |
| EC6.1 | P1 | Standalone agent uses em dash notation | parallel-executor uses --- | [ ] |
| EC6.2 | P1 | MCP agents use backtick format | Consistent notation | [ ] |
| EC6.3 | P1 | Project-Context agents use descriptive text | Consistent notation | [ ] |
| EC6.4 | P2 | No prerequisites use None or N/A | Use em dash instead | [ ] |
| EC7.1 | P3 | Agents list matches expected 11 agents | No extras | [ ] |
| EC7.2a | P2 | Test Fixers has 4 agents | Count = 4 | [ ] |
| EC7.2b | P2 | Code Quality has 4 agents | Count = 4 | [ ] |
| EC7.2c | P2 | Workflow Support has 3 agents | Count = 3 | [ ] |
| EC8.1 | P2 | All 3 subsections have table headers | Count = 3 | [ ] |
| EC8.2 | P2 | All 3 subsections have separator rows | Count >= 3 | [ ] |
| EC8.3 | P3 | Consistent spacing around table pipes | No spacing issues | [ ] |

## Agent Reference (for implementation)

### Test Fixers (4 agents)

| Agent | What it does | Prerequisites |
|-------|--------------|---------------|
| `unit-test-fixer` | Analyzes and fixes failing unit tests | test files in project |
| `api-test-fixer` | Analyzes and fixes failing API tests | API test files in project |
| `database-test-fixer` | Analyzes and fixes failing database tests | database test files in project |
| `e2e-test-fixer` | Analyzes and fixes failing E2E tests | E2E test files in project |

### Code Quality (4 agents)

| Agent | What it does | Prerequisites |
|-------|--------------|---------------|
| `linting-fixer` | Analyzes and fixes linting errors | linting config in project |
| `type-error-fixer` | Analyzes and fixes type errors | Python/TypeScript project |
| `import-error-fixer` | Analyzes and fixes import errors | code files in project |
| `security-scanner` | Scans code for security vulnerabilities | code files in project |

### Workflow Support (3 agents)

| Agent | What it does | Prerequisites |
|-------|--------------|---------------|
| `pr-workflow-manager` | Manages pull request workflows via GitHub | `github` MCP |
| `parallel-executor` | Executes tasks independently without delegation | --- |
| `digdeep` | Performs Five Whys root cause analysis | `perplexity-ask` MCP |

## Validation Script

Run: `./tests/atdd/3-5-write-agents-reference-section.sh`

## Pass Criteria

All tests must pass (exit code 0) for story completion.

## Current Status

**Phase:** RED - Tests expected to fail
**Test Count:** 62 tests total
**Coverage:**
- AC1 (Domain Organization): 17 tests
- AC2 (Table Format): 9 tests
- AC3 (All 11 Agents): 14 tests
- Edge Cases/Quality: 22 tests

**Priority Distribution:**
- P0: 38 tests (core acceptance criteria)
- P1: 12 tests (section positioning, kebab-case, MCP notation)
- P2: 10 tests (markdown quality, backticks, verbs, intro sentence)
- P3: 2 tests (cross-reference validation)
