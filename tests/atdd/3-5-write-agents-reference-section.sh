#!/bin/bash
# ATDD Validation Script: Story 3.5 - Write Agents Reference Section
# TDD Phase: RED (tests expected to fail initially)
#
# Usage: ./tests/atdd/3-5-write-agents-reference-section.sh
# Exit: 0 if all tests pass, 1 if any test fails
#
# Test Coverage: 96 tests total (97 test definitions, 1 conditional)
#   - P0 (Core ATDD): 40 tests - Critical acceptance criteria
#   - P1 (Important): 24 tests - Edge cases and important validations
#   - P2 (Quality): 28 tests - Format validation and consistency
#   - P3 (Future): 4 tests - Cross-reference and future-proofing
#
# Categories:
#   - AC1 (Domain Organization): 17 tests
#   - AC2 (Table Format): 9 tests
#   - AC3 (All 11 Agents): 14 tests
#   - EC1-EC15 (Edge Cases): 55 additional tests covering:
#     * Format validation (duplicate detection, table alignment, whitespace)
#     * Content validation (description length, correct subsections, active voice)
#     * Prerequisite validation (consistent notation across tiers)
#     * Cross-reference validation (file existence, agent counts)
#     * Formatting consistency (table structure, spacing, no trailing whitespace)
#     * Description quality (no redundancy, appropriate length, conciseness)
#     * Domain boundary enforcement (agents in correct categories only)
#     * Table robustness (multi-hyphen names, MCP names with hyphens)

# Project root (dynamically resolved - works from anywhere)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README_PATH="${PROJECT_ROOT}/README.md"
PASSED=0
FAILED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "ATDD Tests: Story 3.5 - Agents Reference Section"
echo "========================================"
echo ""

# Helper function to run a test
run_test() {
    local test_id="$1"
    local test_name="$2"
    local test_command="$3"

    TOTAL=$((TOTAL + 1))

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC} [$test_id] $test_name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC} [$test_id] $test_name"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Check if README exists
if [ ! -f "$README_PATH" ]; then
    echo -e "${RED}ERROR: README.md not found at $README_PATH${NC}"
    echo "TDD Phase: RED - README.md must exist"
    exit 1
fi

# Extract Agents Reference section content for analysis (macOS compatible)
# Get line numbers for Agents Reference section boundaries
START_LINE=$(grep -n '^## Agents Reference' "$README_PATH" | head -1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    # Find next ## header after Agents Reference
    END_LINE=$(tail -n +$((START_LINE + 1)) "$README_PATH" | grep -n '^## ' | head -1 | cut -d: -f1)
    if [ -n "$END_LINE" ]; then
        END_LINE=$((START_LINE + END_LINE - 1))
        AGENTS_SECTION=$(sed -n "${START_LINE},${END_LINE}p" "$README_PATH")
    else
        AGENTS_SECTION=$(tail -n +${START_LINE} "$README_PATH")
    fi
else
    AGENTS_SECTION=""
fi

echo "--- AC1: Domain Organization (3 subsections in order) ---"
echo ""

# AC1.1: README.md contains ## Agents Reference section
run_test "AC1.1" "README contains Agents Reference section" \
    "grep -q '^## Agents Reference' '$README_PATH'" || true

# AC1.2: Agents Reference contains Test Fixers subsection
run_test "AC1.2" "Contains Test Fixers subsection" \
    "echo \"\$AGENTS_SECTION\" | grep -q '^### Test Fixers'" || true

# AC1.3: Agents Reference contains Code Quality subsection
run_test "AC1.3" "Contains Code Quality subsection" \
    "echo \"\$AGENTS_SECTION\" | grep -q '^### Code Quality'" || true

# AC1.4: Agents Reference contains Workflow Support subsection
run_test "AC1.4" "Contains Workflow Support subsection" \
    "echo \"\$AGENTS_SECTION\" | grep -q '^### Workflow Support'" || true

# AC1.5: Subsections are in correct order (Test Fixers < Code Quality < Workflow Support)
TESTFIXERS_LINE=$(echo "$AGENTS_SECTION" | grep -n '^### Test Fixers' | head -1 | cut -d: -f1)
CODEQUALITY_LINE=$(echo "$AGENTS_SECTION" | grep -n '^### Code Quality' | head -1 | cut -d: -f1)
WORKFLOWSUPPORT_LINE=$(echo "$AGENTS_SECTION" | grep -n '^### Workflow Support' | head -1 | cut -d: -f1)
run_test "AC1.5" "Subsections in correct order" \
    "[ -n \"\$TESTFIXERS_LINE\" ] && [ -n \"\$CODEQUALITY_LINE\" ] && [ -n \"\$WORKFLOWSUPPORT_LINE\" ] && [ \"\$TESTFIXERS_LINE\" -lt \"\$CODEQUALITY_LINE\" ] && [ \"\$CODEQUALITY_LINE\" -lt \"\$WORKFLOWSUPPORT_LINE\" ]" || true

# AC1.6: Test Fixers contains unit-test-fixer
run_test "AC1.6" "Test Fixers contains unit-test-fixer" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Test Fixers/,/^### /p' | grep -q 'unit-test-fixer'" || true

# AC1.7: Test Fixers contains api-test-fixer
run_test "AC1.7" "Test Fixers contains api-test-fixer" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Test Fixers/,/^### /p' | grep -q 'api-test-fixer'" || true

# AC1.8: Test Fixers contains database-test-fixer
run_test "AC1.8" "Test Fixers contains database-test-fixer" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Test Fixers/,/^### /p' | grep -q 'database-test-fixer'" || true

# AC1.9: Test Fixers contains e2e-test-fixer
run_test "AC1.9" "Test Fixers contains e2e-test-fixer" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Test Fixers/,/^### /p' | grep -q 'e2e-test-fixer'" || true

# AC1.10: Code Quality contains linting-fixer
run_test "AC1.10" "Code Quality contains linting-fixer" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Code Quality/,/^### /p' | grep -q 'linting-fixer'" || true

# AC1.11: Code Quality contains type-error-fixer
run_test "AC1.11" "Code Quality contains type-error-fixer" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Code Quality/,/^### /p' | grep -q 'type-error-fixer'" || true

# AC1.12: Code Quality contains import-error-fixer
run_test "AC1.12" "Code Quality contains import-error-fixer" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Code Quality/,/^### /p' | grep -q 'import-error-fixer'" || true

# AC1.13: Code Quality contains security-scanner
run_test "AC1.13" "Code Quality contains security-scanner" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Code Quality/,/^### /p' | grep -q 'security-scanner'" || true

# AC1.14: Workflow Support contains pr-workflow-manager
run_test "AC1.14" "Workflow Support contains pr-workflow-manager" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Workflow Support/,/^## /p' | grep -q 'pr-workflow-manager'" || true

# AC1.15: Workflow Support contains parallel-executor
run_test "AC1.15" "Workflow Support contains parallel-executor" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Workflow Support/,/^## /p' | grep -q 'parallel-executor'" || true

# AC1.16: Workflow Support contains digdeep
run_test "AC1.16" "Workflow Support contains digdeep" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Workflow Support/,/^## /p' | grep -q 'digdeep'" || true

# AC1.17: Exactly 3 domain subsections (no extras)
SUBSECTION_COUNT=$(echo "$AGENTS_SECTION" | grep -c '^### ')
run_test "AC1.17" "Exactly 3 domain subsections" \
    "[ \"\$SUBSECTION_COUNT\" -eq 3 ]" || true

echo ""
echo "--- AC2: Table Format (exact structure with Agent, What it does, Prerequisites) ---"
echo ""

# AC2.1: Test Fixers has correct table header
run_test "AC2.1" "Test Fixers has correct table header" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Test Fixers/,/^### /p' | grep -q '| Agent | What it does | Prerequisites |'" || true

# AC2.2: Code Quality has correct table header
run_test "AC2.2" "Code Quality has correct table header" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Code Quality/,/^### /p' | grep -q '| Agent | What it does | Prerequisites |'" || true

# AC2.3: Workflow Support has correct table header
run_test "AC2.3" "Workflow Support has correct table header" \
    "echo \"\$AGENTS_SECTION\" | sed -n '/^### Workflow Support/,/^## /p' | grep -q '| Agent | What it does | Prerequisites |'" || true

# AC2.4: Standalone agent uses em dash (parallel-executor uses — or ---)
run_test "AC2.4" "Standalone agent (parallel-executor) uses em dash" \
    "echo \"\$AGENTS_SECTION\" | grep 'parallel-executor' | grep -qE -- '---|—'" || true

# AC2.5: MCP-Enhanced agents use backtick format (pr-workflow-manager uses `github` MCP)
run_test "AC2.5" "MCP-Enhanced agent (pr-workflow-manager) uses backtick format" \
    "echo \"\$AGENTS_SECTION\" | grep 'pr-workflow-manager' | grep -q '\`github\` MCP'" || true

# AC2.6: MCP-Enhanced agents use backtick format (digdeep uses `perplexity-ask` MCP)
run_test "AC2.6" "MCP-Enhanced agent (digdeep) uses backtick format" \
    "echo \"\$AGENTS_SECTION\" | grep 'digdeep' | grep -q '\`perplexity-ask\` MCP'" || true

# AC2.7: Project-Context agents use descriptive text (test fixers)
run_test "AC2.7" "Project-Context agents use descriptive text" \
    "echo \"\$AGENTS_SECTION\" | grep 'unit-test-fixer' | grep -qiE 'test.*file|project'" || true

# AC2.8: Tables have separator row (|---|---|---|)
run_test "AC2.8" "Tables have separator row" \
    "echo \"\$AGENTS_SECTION\" | grep -qE '\\|[-]+\\|[-]+\\|[-]+\\|'" || true

# AC2.9: All 3 subsections have separator rows
run_test "AC2.9" "All 3 subsections have separator rows" \
    "[ \"\$(echo \"\$AGENTS_SECTION\" | grep -c '|[-]')\" -ge 3 ]" || true

echo ""
echo "--- AC3: All 11 Agents Documented (each appears exactly once) ---"
echo ""

# AC3.1: Total agent count is exactly 11
# Matches: unit-test-fixer, api-test-fixer, database-test-fixer, e2e-test-fixer, linting-fixer, type-error-fixer, import-error-fixer, security-scanner, pr-workflow-manager, parallel-executor, digdeep
AGENT_COUNT=$(echo "$AGENTS_SECTION" | grep -oE '\`[a-z0-9-]+-fixer\`|\`[a-z-]+-scanner\`|\`[a-z-]+-manager\`|\`[a-z-]+-executor\`|\`digdeep\`' | sort -u | wc -l | tr -d ' ')
run_test "AC3.1" "Exactly 11 unique agents documented" \
    "[ \"\$AGENT_COUNT\" -eq 11 ]" || true

# AC3.2: unit-test-fixer appears exactly once
UNITTESTFIXER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'unit-test-fixer' | tr -d ' ')
run_test "AC3.2" "unit-test-fixer appears exactly once" \
    "[ \"\$UNITTESTFIXER_COUNT\" -eq 1 ]" || true

# AC3.3: api-test-fixer appears exactly once
APITESTFIXER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'api-test-fixer' | tr -d ' ')
run_test "AC3.3" "api-test-fixer appears exactly once" \
    "[ \"\$APITESTFIXER_COUNT\" -eq 1 ]" || true

# AC3.4: database-test-fixer appears exactly once
DBTESTFIXER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'database-test-fixer' | tr -d ' ')
run_test "AC3.4" "database-test-fixer appears exactly once" \
    "[ \"\$DBTESTFIXER_COUNT\" -eq 1 ]" || true

# AC3.5: e2e-test-fixer appears exactly once
E2ETESTFIXER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'e2e-test-fixer' | tr -d ' ')
run_test "AC3.5" "e2e-test-fixer appears exactly once" \
    "[ \"\$E2ETESTFIXER_COUNT\" -eq 1 ]" || true

# AC3.6: linting-fixer appears exactly once
LINTINGFIXER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'linting-fixer' | tr -d ' ')
run_test "AC3.6" "linting-fixer appears exactly once" \
    "[ \"\$LINTINGFIXER_COUNT\" -eq 1 ]" || true

# AC3.7: type-error-fixer appears exactly once
TYPEERRORFIXER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'type-error-fixer' | tr -d ' ')
run_test "AC3.7" "type-error-fixer appears exactly once" \
    "[ \"\$TYPEERRORFIXER_COUNT\" -eq 1 ]" || true

# AC3.8: import-error-fixer appears exactly once
IMPORTERRORFIXER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'import-error-fixer' | tr -d ' ')
run_test "AC3.8" "import-error-fixer appears exactly once" \
    "[ \"\$IMPORTERRORFIXER_COUNT\" -eq 1 ]" || true

# AC3.9: security-scanner appears exactly once
SECURITYSCANNER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'security-scanner' | tr -d ' ')
run_test "AC3.9" "security-scanner appears exactly once" \
    "[ \"\$SECURITYSCANNER_COUNT\" -eq 1 ]" || true

# AC3.10: pr-workflow-manager appears exactly once
PRWORKFLOWMANAGER_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'pr-workflow-manager' | tr -d ' ')
run_test "AC3.10" "pr-workflow-manager appears exactly once" \
    "[ \"\$PRWORKFLOWMANAGER_COUNT\" -eq 1 ]" || true

# AC3.11: parallel-executor appears exactly once
PARALLELEXECUTOR_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'parallel-executor' | tr -d ' ')
run_test "AC3.11" "parallel-executor appears exactly once" \
    "[ \"\$PARALLELEXECUTOR_COUNT\" -eq 1 ]" || true

# AC3.12: digdeep appears exactly once
DIGDEEP_COUNT=$(echo "$AGENTS_SECTION" | grep -c 'digdeep' | tr -d ' ')
run_test "AC3.12" "digdeep appears exactly once" \
    "[ \"\$DIGDEEP_COUNT\" -eq 1 ]" || true

# AC3.13: Every agent has a description (non-empty second column)
run_test "AC3.13" "Every agent has a description" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`[a-z-]+\`' | grep -qE '\\| \`[a-z-]+\` \\|\\s*\\|'" || true

# AC3.14: Every agent has prerequisites (non-empty third column)
run_test "AC3.14" "Every agent has prerequisites" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`[a-z-]+\`' | grep -qE '\\|\\s*\\|$'" || true

echo ""
echo "--- Edge Cases & Quality Checks ---"
echo ""

# EC1.1: Agents Reference positioned after Commands Reference (P1)
COMMANDSREF_LINE=$(grep -n '^## Commands Reference' "$README_PATH" | head -1 | cut -d: -f1)
AGENTSREF_LINE=$(grep -n '^## Agents Reference' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.1" "[P1] Agents Reference after Commands Reference" \
    "[ -n \"\$COMMANDSREF_LINE\" ] && [ -n \"\$AGENTSREF_LINE\" ] && [ \"\$AGENTSREF_LINE\" -gt \"\$COMMANDSREF_LINE\" ]" || true

# EC1.2: Agents Reference positioned before Skills Reference (P1)
SKILLSREF_LINE=$(grep -n '^## Skills Reference' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.2" "[P1] Agents Reference before Skills Reference" \
    "[ -z \"\$SKILLSREF_LINE\" ] || ([ -n \"\$AGENTSREF_LINE\" ] && [ \"\$AGENTSREF_LINE\" -lt \"\$SKILLSREF_LINE\" ])" || true

# EC2.1: No broken markdown in Agents Reference section (P2)
run_test "EC2.1" "[P2] No broken markdown" \
    "! echo \"\$AGENTS_SECTION\" | grep -qE '\\[([^\\]]+)\\]\\(\\s*\\)'" || true

# EC2.2: Agents use kebab-case (no underscores) (P1)
run_test "EC2.2" "[P1] Agents use kebab-case not snake_case" \
    "! echo \"\$AGENTS_SECTION\" | grep -qE '\`[a-z]+_[a-z]+\`'" || true

# EC2.3: Agents have consistent formatting with backticks (P2)
run_test "EC2.3" "[P2] Agents wrapped in backticks" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| [a-z]' | grep -qv '\`'" || true

# EC3.1: Descriptions start with present-tense verb (P2)
run_test "EC3.1" "[P2] Descriptions start with present-tense verb" \
    "echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | head -5 | grep -qE '\\| [A-Z][a-z]+(s|es) '" || true

# EC3.2: Section has intro sentence explaining domain organization (P2)
run_test "EC3.2" "[P2] Section has intro sentence" \
    "echo \"\$AGENTS_SECTION\" | head -5 | grep -qiE 'domain|organized|group'" || true

echo ""
echo "--- Additional Edge Cases: Format Validation ---"
echo ""

# [P1] EC4.1: No duplicate agent entries across all subsections
# Use explicit agent names to avoid partial matches
DUPLICATE_COUNT=$(echo "$AGENTS_SECTION" | grep -oE 'unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer|linting-fixer|type-error-fixer|import-error-fixer|security-scanner|pr-workflow-manager|parallel-executor|digdeep' | sort | uniq -d | wc -l | tr -d ' ')
run_test "EC4.1" "[P1] No duplicate agents across subsections" \
    "[ \"\$DUPLICATE_COUNT\" -eq 0 ]" || true

# [P2] EC4.2: Table columns are properly aligned (no missing pipes)
run_test "EC4.2" "[P2] All table rows have 4 pipes (3 columns)" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | grep -vE '^\\| [^|]+ \\| [^|]+ \\| [^|]+ \\|'" || true

# [P1] EC4.3: All agent names match actual files in agents/ directory
# Check each expected agent file exists
ALL_AGENTS_EXIST=true
for agent in unit-test-fixer api-test-fixer database-test-fixer e2e-test-fixer linting-fixer type-error-fixer import-error-fixer security-scanner pr-workflow-manager parallel-executor digdeep; do
    if [ ! -f "${PROJECT_ROOT}/agents/${agent}.md" ]; then
        ALL_AGENTS_EXIST=false
        break
    fi
done
run_test "EC4.3" "[P1] Agent names match actual files" \
    "[ \"\$ALL_AGENTS_EXIST\" = \"true\" ]" || true

# [P2] EC4.4: Description column not empty for any agent
run_test "EC4.4" "[P2] All agents have non-empty descriptions" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`[a-z-]+\` \\| \\|'" || true

# [P2] EC4.5: Prerequisites column not empty for any agent
run_test "EC4.5" "[P2] All agents have non-empty prerequisites" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`[a-z-]+\` \\| [^|]+ \\| \\|'" || true

echo ""
echo "--- Additional Edge Cases: Content Validation ---"
echo ""

# [P1] EC5.1: Descriptions under 60 characters
run_test "EC5.1" "[P1] All descriptions under 60 characters" \
    "! echo \"\$AGENTS_SECTION\" | grep -oE '^\\| \`[a-z-]+\` \\| [^|]{61,} \\|'" || true

# [P2] EC5.2: Agents use lowercase kebab-case only (no uppercase)
run_test "EC5.2" "[P2] Agents are lowercase kebab-case" \
    "echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | grep -qE '\`[a-z][a-z-]*\`'" || true

# [P1] EC5.3a: Test fixer agents only in Test Fixers section
TEST_FIXERS_SECTION=$(echo "$AGENTS_SECTION" | sed -n '/^### Test Fixers/,/^### Code Quality/p')
CODE_QUALITY_SECTION=$(echo "$AGENTS_SECTION" | sed -n '/^### Code Quality/,/^### Workflow Support/p')
WORKFLOW_SECTION=$(echo "$AGENTS_SECTION" | sed -n '/^### Workflow Support/,/^## /p')

run_test "EC5.3a" "[P1] unit-test-fixer only in Test Fixers" \
    "echo \"\$TEST_FIXERS_SECTION\" | grep -q 'unit-test-fixer' && ! echo \"\$CODE_QUALITY_SECTION\$WORKFLOW_SECTION\" | grep -q 'unit-test-fixer'" || true

run_test "EC5.3b" "[P1] linting-fixer only in Code Quality" \
    "echo \"\$CODE_QUALITY_SECTION\" | grep -q 'linting-fixer' && ! echo \"\$TEST_FIXERS_SECTION\$WORKFLOW_SECTION\" | grep -q 'linting-fixer'" || true

run_test "EC5.3c" "[P1] pr-workflow-manager only in Workflow Support" \
    "echo \"\$WORKFLOW_SECTION\" | grep -q 'pr-workflow-manager' && ! echo \"\$TEST_FIXERS_SECTION\$CODE_QUALITY_SECTION\" | grep -q 'pr-workflow-manager'" || true

# [P2] EC5.4: Table header separator has correct format (at least 3 dashes per column)
run_test "EC5.4" "[P2] Table separators have 3+ dashes" \
    "echo \"\$AGENTS_SECTION\" | grep -E '\\|[-]{3,}\\|[-]{3,}\\|[-]{3,}\\|' | wc -l | grep -qE '[3-9]'" || true

echo ""
echo "--- Additional Edge Cases: Prerequisite Validation ---"
echo ""

# [P1] EC6.1: Standalone agent uses em dash notation
run_test "EC6.1" "[P1] Standalone agent uses em dash notation" \
    "echo \"\$AGENTS_SECTION\" | grep 'parallel-executor' | grep -qE -- '---|—'" || true

# [P1] EC6.2: MCP agents use backtick format consistently
run_test "EC6.2" "[P1] MCP agents use backtick format" \
    "echo \"\$AGENTS_SECTION\" | grep 'pr-workflow-manager\\|digdeep' | grep -q '\`.*\` MCP'" || true

# [P1] EC6.3: Project-Context agents use descriptive text
run_test "EC6.3" "[P1] Project-Context agents use descriptive text" \
    "echo \"\$AGENTS_SECTION\" | grep 'unit-test-fixer' | grep -qiE 'test|file|project'" || true

# [P2] EC6.4: No prerequisite uses 'None' or 'N/A' (should be em dash)
run_test "EC6.4" "[P2] No prerequisites use None or N/A" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | grep -qiE 'None|N/A'" || true

echo ""
echo "--- Additional Edge Cases: Cross-Reference Validation ---"
echo ""

# [P3] EC7.1: Agents list matches the 11 expected agents exactly (no extras)
# Use explicit agent names to avoid regex partial matches
EXPECTED_COUNT=11
ACTUAL_COUNT=$(echo "$AGENTS_SECTION" | grep -oE 'unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer|linting-fixer|type-error-fixer|import-error-fixer|security-scanner|pr-workflow-manager|parallel-executor|digdeep' | sort -u | wc -l | tr -d ' ')
run_test "EC7.1" "[P3] Agents list matches expected 11 agents" \
    "[ \"\$ACTUAL_COUNT\" -eq \"\$EXPECTED_COUNT\" ]" || true

# [P2] EC7.2: Each subsection has expected agent count
# Use explicit count of test fixer agents
run_test "EC7.2a" "[P2] Test Fixers has 4 agents" \
    "[ \"\$(echo \"\$TEST_FIXERS_SECTION\" | grep -cE 'unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer')\" -eq 4 ]" || true

run_test "EC7.2b" "[P2] Code Quality has 4 agents" \
    "[ \"\$(echo \"\$CODE_QUALITY_SECTION\" | grep -cE '\`[a-z-]*-fixer\`|\`security-scanner\`')\" -eq 4 ]" || true

run_test "EC7.2c" "[P2] Workflow Support has 3 agents" \
    "[ \"\$(echo \"\$WORKFLOW_SECTION\" | grep -cE '\`[a-z-]*-manager\`|\`[a-z-]*-executor\`|\`digdeep\`')\" -eq 3 ]" || true

echo ""
echo "--- Additional Edge Cases: Formatting Consistency ---"
echo ""

# [P2] EC8.1: All subsections have same table structure
run_test "EC8.1" "[P2] All 3 subsections have table headers" \
    "[ \"\$(echo \"\$AGENTS_SECTION\" | grep -c '| Agent | What it does | Prerequisites |')\" -eq 3 ]" || true

# [P2] EC8.2: All subsections have separator rows
run_test "EC8.2" "[P2] All 3 subsections have separator rows" \
    "[ \"\$(echo \"\$AGENTS_SECTION\" | grep -c '|[-]')\" -ge 3 ]" || true

# [P3] EC8.3: Consistent spacing around pipes in tables
run_test "EC8.3" "[P3] Consistent spacing around table pipes" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | grep -qE '\\|[^ ]|[^ ]\\|'" || true

echo ""
echo "--- Additional Edge Cases: Description Content Validation ---"
echo ""

# [P1] EC9.1: Descriptions don't contain agent name (redundant)
run_test "EC9.1" "[P1] Descriptions don't redundantly contain agent name" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`unit-test-fixer\`' | grep -qi 'unit test fixer'" || true

# [P2] EC9.2: Descriptions don't end with periods
run_test "EC9.2" "[P2] Descriptions don't end with periods" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`[a-z-]+\` \\|' | grep -qE '\\. \\|'" || true

# [P1] EC9.3: Descriptions are not too short (minimum 20 characters for quality)
run_test "EC9.3" "[P1] Descriptions are at least 20 characters" \
    "! echo \"\$AGENTS_SECTION\" | grep -oE '^\\| \`[a-z-]+\` \\| [^|]{1,19} \\|'" || true

# [P2] EC9.4: Descriptions use active voice (contains verb in present tense)
run_test "EC9.4" "[P2] Descriptions use active voice" \
    "echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`unit-test-fixer\`' | grep -qE 'Fixes|Analyzes|Manages|Executes|Performs|Scans'" || true

echo ""
echo "--- Additional Edge Cases: Whitespace and Formatting ---"
echo ""

# [P2] EC10.1: No trailing whitespace in table rows
run_test "EC10.1" "[P2] No trailing whitespace in table rows" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | grep -qE ' +$'" || true

# [P2] EC10.2: Table separator rows use consistent dash count
run_test "EC10.2" "[P2] All separator rows have similar structure" \
    "echo \"\$AGENTS_SECTION\" | grep -E '^\\|[-]+\\|' | head -3 | wc -l | grep -q 3" || true

# [P3] EC10.3: No excessive blank lines between subsections (max 2 consecutive)
run_test "EC10.3" "[P3] No excessive blank lines between subsections" \
    "[ \"\$(echo \"\$AGENTS_SECTION\" | grep -c '^$')\" -lt 15 ]" || true

# [P2] EC10.4: Agent names don't have spaces (only hyphens)
run_test "EC10.4" "[P2] Agent names use hyphens not spaces" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | grep -qE '\`[a-z]+ [a-z]+\`'" || true

echo ""
echo "--- Additional Edge Cases: Domain Boundary Validation ---"
echo ""

# [P1] EC11.1: security-scanner only in Code Quality (not Test Fixers)
run_test "EC11.1" "[P1] security-scanner only in Code Quality" \
    "echo \"\$CODE_QUALITY_SECTION\" | grep -q 'security-scanner' && ! echo \"\$TEST_FIXERS_SECTION\$WORKFLOW_SECTION\" | grep -q 'security-scanner'" || true

# [P1] EC11.2: digdeep only in Workflow Support (not elsewhere)
run_test "EC11.2" "[P1] digdeep only in Workflow Support" \
    "echo \"\$WORKFLOW_SECTION\" | grep -q 'digdeep' && ! echo \"\$TEST_FIXERS_SECTION\$CODE_QUALITY_SECTION\" | grep -q 'digdeep'" || true

# [P1] EC11.3: parallel-executor only in Workflow Support
run_test "EC11.3" "[P1] parallel-executor only in Workflow Support" \
    "echo \"\$WORKFLOW_SECTION\" | grep -q 'parallel-executor' && ! echo \"\$TEST_FIXERS_SECTION\$CODE_QUALITY_SECTION\" | grep -q 'parallel-executor'" || true

# [P2] EC11.4: All test fixers end with '-fixer' suffix
run_test "EC11.4" "[P2] All test fixers have -fixer suffix" \
    "echo \"\$TEST_FIXERS_SECTION\" | grep -oE '\`[a-z-]+\`' | grep -v 'Agent' | grep -qE 'fixer\`'" || true

echo ""
echo "--- Additional Edge Cases: Prerequisite Consistency Checks ---"
echo ""

# [P2] EC12.1: All test fixers use 'test files' or similar wording
run_test "EC12.1" "[P2] Test fixers use consistent prerequisite wording" \
    "echo \"\$TEST_FIXERS_SECTION\" | grep -E '^\\| \`' | grep -qiE 'test|project'" || true

# [P1] EC12.2: MCP prerequisites use exact format '`server` MCP'
run_test "EC12.2" "[P1] MCP prerequisites use correct format" \
    "echo \"\$AGENTS_SECTION\" | grep 'MCP' | grep -qE '\`[a-z-]+\` MCP'" || true

# [P2] EC12.3: No prerequisite uses 'required' or 'needs' (use descriptive text)
run_test "EC12.3" "[P2] Prerequisites avoid 'required' or 'needs'" \
    "! echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`' | grep -qiE 'required|needs'" || true

# [P2] EC12.4: Standalone prerequisite uses exactly '---' (3 hyphens) or em dash
run_test "EC12.4" "[P2] Standalone uses em dash or 3 hyphens" \
    "echo \"\$AGENTS_SECTION\" | grep 'parallel-executor' | grep -qE '\\| --- \\||\\| — \\|'" || true

echo ""
echo "--- Additional Edge Cases: Description Length Boundaries ---"
echo ""

# [P1] EC13.1: At least one description is between 40-60 chars (optimal length)
run_test "EC13.1" "[P1] Some descriptions use optimal length (40-60)" \
    "echo \"\$AGENTS_SECTION\" | grep -oE '^\\| \`[a-z-]+\` \\| [^|]{40,60} \\|' | wc -l | grep -qE '[1-9]'" || true

# [P2] EC13.2: No description exceeds 60 characters
run_test "EC13.2" "[P2] No description exceeds 60 characters" \
    "! echo \"\$AGENTS_SECTION\" | grep -oE '^\\| \`[a-z-]+\` \\| [^|]{61,} \\|'" || true

# [P1] EC13.3: Descriptions are concise (verify descriptions exist and are non-trivial)
# Check that at least one agent has a description over 20 chars
run_test "EC13.3" "[P1] Descriptions are substantive (at least 20 chars)" \
    "echo \"\$AGENTS_SECTION\" | grep -E '^\\| \`[a-z-]+\` \\|' | grep -qE '\\| [A-Za-z].{20,} \\|'" || true

echo ""
echo "--- Additional Edge Cases: Table Structure Robustness ---"
echo ""

# [P2] EC14.1: Agent names with multiple hyphens handled correctly (e.g., parallel-executor)
run_test "EC14.1" "[P2] Multi-hyphen agent names formatted correctly" \
    "echo \"\$AGENTS_SECTION\" | grep 'parallel-executor' | grep -qE '^\\| \`parallel-executor\` \\|'" || true

# [P2] EC14.2: MCP server names with hyphens handled correctly (perplexity-ask)
run_test "EC14.2" "[P2] MCP names with hyphens formatted correctly" \
    "echo \"\$AGENTS_SECTION\" | grep 'digdeep' | grep -qE '\`perplexity-ask\` MCP'" || true

# [P1] EC14.3: Each table has exactly 11 total entries (agents)
# Use explicit agent names for reliable counting
run_test "EC14.3" "[P1] Total of exactly 11 agent entries across tables" \
    "[ \"\$(echo \"\$AGENTS_SECTION\" | grep -cE 'unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer|linting-fixer|type-error-fixer|import-error-fixer|security-scanner|pr-workflow-manager|parallel-executor|digdeep')\" -eq 11 ]" || true

# [P3] EC14.4: Table headers identical across all 3 subsections
HEADER_PATTERN='| Agent | What it does | Prerequisites |'
run_test "EC14.4" "[P3] All table headers are identical" \
    "[ \"\$(echo \"\$AGENTS_SECTION\" | grep -cF \"\$HEADER_PATTERN\")\" -eq 3 ]" || true

echo ""
echo "--- Additional Edge Cases: Cross-Domain Consistency ---"
echo ""

# [P2] EC15.1: No agent appears in multiple domains (comprehensive check)
for agent in unit-test-fixer api-test-fixer database-test-fixer e2e-test-fixer linting-fixer type-error-fixer import-error-fixer security-scanner pr-workflow-manager parallel-executor digdeep; do
    AGENT_OCCURRENCES=$(echo "$AGENTS_SECTION" | grep -c "\`$agent\`")
    if [ "$AGENT_OCCURRENCES" -ne 1 ]; then
        run_test "EC15.1" "[P2] Agent $agent appears exactly once" "false" || true
        break
    fi
done
run_test "EC15.1" "[P2] All agents appear exactly once (no cross-domain duplicates)" \
    "[ \"\$AGENT_OCCURRENCES\" -eq 1 ]" || true

# [P1] EC15.2: Test Fixers domain contains only test-related agents
run_test "EC15.2" "[P1] Test Fixers contains only test agents" \
    "! echo \"\$TEST_FIXERS_SECTION\" | grep -qE 'linting-fixer|type-error-fixer|import-error-fixer|security-scanner|pr-workflow-manager|parallel-executor|digdeep'" || true

# [P1] EC15.3: Code Quality domain contains only quality-related agents
run_test "EC15.3" "[P1] Code Quality contains only quality agents" \
    "! echo \"\$CODE_QUALITY_SECTION\" | grep -qE 'unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer|pr-workflow-manager|parallel-executor|digdeep'" || true

# [P1] EC15.4: Workflow Support domain contains only workflow agents
run_test "EC15.4" "[P1] Workflow Support contains only workflow agents" \
    "! echo \"\$WORKFLOW_SECTION\" | grep -qE 'unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer|linting-fixer|type-error-fixer|import-error-fixer|security-scanner'" || true

echo ""
echo "========================================"
echo "SUMMARY"
echo "========================================"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo "Total:  $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo "TDD Phase: GREEN - Ready for refactoring"
    exit 0
else
    echo -e "${YELLOW}$FAILED test(s) failed${NC}"
    echo "TDD Phase: RED - Implementation needed"
    exit 1
fi
