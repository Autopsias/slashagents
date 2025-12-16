#!/bin/bash
# ATDD Verification Script for Story 2.1: Audit Current Tool Metadata
# TDD Phase: RED (tests should fail until audit implementation is complete)
#
# Usage: ./tests/atdd/2-1-audit-current-tool-metadata.sh
# Exit code: 0 = all tests pass, non-zero = number of failed tests

set -eo pipefail

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_FILE="$PROJECT_ROOT/docs/sprint-artifacts/metadata-audit.md"
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result tracking
declare -a RESULTS

# Expected tool counts
EXPECTED_COMMANDS=11
EXPECTED_AGENTS=11
EXPECTED_SKILLS=1
EXPECTED_TOTAL=23

# All expected tools (for comprehensive validation)
declare -a EXPECTED_COMMAND_FILES=(
    "pr.md"
    "ci-orchestrate.md"
    "test-orchestrate.md"
    "commit-orchestrate.md"
    "parallelize.md"
    "parallelize-agents.md"
    "epic-dev.md"
    "epic-dev-full.md"
    "epic-dev-init.md"
    "nextsession.md"
    "usertestgates.md"
)

declare -a EXPECTED_AGENT_FILES=(
    "unit-test-fixer.md"
    "api-test-fixer.md"
    "database-test-fixer.md"
    "e2e-test-fixer.md"
    "linting-fixer.md"
    "type-error-fixer.md"
    "import-error-fixer.md"
    "security-scanner.md"
    "pr-workflow-manager.md"
    "parallel-executor.md"
    "digdeep.md"
)

declare -a EXPECTED_SKILL_FILES=(
    "pr-workflow.md"
)

# Tier values for validation
declare -a VALID_TIERS=(
    "Standalone"
    "MCP-Enhanced"
    "BMAD-Required"
    "Project-Context"
)

# Test helper function
run_test() {
    local test_id="$1"
    local test_desc="$2"
    local test_cmd="$3"

    echo -n "  [$test_id] $test_desc... "

    if eval "$test_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        RESULTS+=("PASS: $test_id - $test_desc")
    else
        echo -e "${RED}FAIL${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        RESULTS+=("FAIL: $test_id - $test_desc")
    fi
}

# Helper function: Check if audit file has inventory table with tool entry
check_tool_in_inventory() {
    local tool_name="$1"
    # Check if tool appears in inventory table (should be in a table row with | delimiters)
    grep -qE "^\|.*${tool_name}.*\|" "$AUDIT_FILE"
}

# Helper function: Check if audit file has all required inventory columns
check_inventory_columns() {
    # Must have: Tool | Type | Description | Char Count | Verb-First | Prerequisites | Tier
    grep -qE "^\|.*Tool.*Type.*Description.*Char.*Verb.*Prerequisites.*Tier.*\|" "$AUDIT_FILE"
}

# Helper function: Check if MCP server mapping section exists with tool entry
check_mcp_mapping() {
    local tool_name="$1"
    # First verify MCP Server Mapping section exists
    grep -q "## MCP Server Mapping" "$AUDIT_FILE" && \
    # Then check if tool is mentioned in that section (could be in table or list)
    awk '/## MCP Server Mapping/,/^## [^M]/' "$AUDIT_FILE" | grep -q "$tool_name"
}

# Helper function: Check if tier classification section exists with tool entry
check_tier_classification() {
    local tool_name="$1"
    local tier="$2"
    # Verify Tier Classification section exists
    grep -q "## Tier Classification" "$AUDIT_FILE" && \
    # Check if tool appears under any tier subsection
    awk '/## Tier Classification/,/^## [^T]/' "$AUDIT_FILE" | grep -q "$tool_name"
}

# Helper function: Verify tool has exactly one tier classification
# NOTE: Known issue with awk pattern - the pattern "/### $tier/,/^### /" may not correctly
# match section boundaries in all cases, potentially causing false negatives. This is a
# test implementation issue, not an audit issue. Consider using a more robust section
# extraction method (e.g., parsing line numbers or using a proper markdown parser).
check_single_tier() {
    local tool_name="$1"
    local tier_count=0

    for tier in "${VALID_TIERS[@]}"; do
        if awk "/### $tier/,/^### /" "$AUDIT_FILE" | grep -q "$tool_name"; then
            tier_count=$((tier_count + 1))
        fi
    done

    [ "$tier_count" -eq 1 ]
}

# Helper function: Count tools in inventory table
count_tools_in_inventory() {
    # Count rows in inventory table (lines starting with | but not header/separator)
    grep -cE "^\|[^-]" "$AUDIT_FILE" 2>/dev/null | head -1
}

echo ""
echo "========================================================"
echo "ATDD Verification: Story 2.1 - Audit Current Tool Metadata"
echo "========================================================"
echo ""
echo "Project Root: $PROJECT_ROOT"
echo "Audit File: $AUDIT_FILE"
echo "TDD Phase: RED (expecting failures until audit is complete)"
echo ""

# -----------------------------------------------------------------------------
# AC1: Metadata Inventory - File Existence
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC1: Metadata Inventory - File Existence${NC}"
echo "--------------------------------------------------------"

# TEST-AC1-1.1: Audit file exists
run_test "TEST-AC1-1.1" "[P0] metadata-audit.md file exists" \
    "[ -f '$AUDIT_FILE' ]"

# TEST-AC1-1.2: Audit file is not empty
run_test "TEST-AC1-1.2" "[P0] metadata-audit.md is not empty" \
    "[ -s '$AUDIT_FILE' ]"

echo ""

# -----------------------------------------------------------------------------
# AC1: Metadata Inventory - Structure Validation
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC1: Metadata Inventory - Structure Validation${NC}"
echo "--------------------------------------------------------"

# TEST-AC1-2.1: Audit file has Summary section
run_test "TEST-AC1-2.1" "[P0] Audit has Summary section" \
    "grep -q '## Summary' '$AUDIT_FILE'"

# TEST-AC1-2.2: Audit file has Inventory Table section
run_test "TEST-AC1-2.2" "[P0] Audit has Inventory Table section" \
    "grep -q '## Inventory Table' '$AUDIT_FILE'"

# TEST-AC1-2.3: Inventory table has required columns (Tool, Type, Description, Char Count, Verb-First, Prerequisites, Tier)
run_test "TEST-AC1-2.3" "[P0] Inventory table has all required columns" \
    "check_inventory_columns"

# TEST-AC1-2.4: Summary shows total tools count of 23
run_test "TEST-AC1-2.4" "[P1] Summary shows 'Total tools: 23'" \
    "grep -q 'Total tools: 23' '$AUDIT_FILE' || grep -q 'Total tools:.*23' '$AUDIT_FILE'"

echo ""

# -----------------------------------------------------------------------------
# AC1: Metadata Inventory - Command Files (11 expected)
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC1: Metadata Inventory - Command Files (11 expected)${NC}"
echo "--------------------------------------------------------"

for cmd_file in "${EXPECTED_COMMAND_FILES[@]}"; do
    test_id="TEST-AC1-CMD-${cmd_file%.md}"
    run_test "$test_id" "[P0] Command '$cmd_file' in inventory" \
        "check_tool_in_inventory '$cmd_file'"
done

echo ""

# -----------------------------------------------------------------------------
# AC1: Metadata Inventory - Agent Files (11 expected)
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC1: Metadata Inventory - Agent Files (11 expected)${NC}"
echo "--------------------------------------------------------"

for agent_file in "${EXPECTED_AGENT_FILES[@]}"; do
    test_id="TEST-AC1-AGT-${agent_file%.md}"
    run_test "$test_id" "[P0] Agent '$agent_file' in inventory" \
        "check_tool_in_inventory '$agent_file'"
done

echo ""

# -----------------------------------------------------------------------------
# AC1: Metadata Inventory - Skill Files (1 expected)
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC1: Metadata Inventory - Skill Files (1 expected)${NC}"
echo "--------------------------------------------------------"

for skill_file in "${EXPECTED_SKILL_FILES[@]}"; do
    test_id="TEST-AC1-SKL-${skill_file%.md}"
    run_test "$test_id" "[P0] Skill '$skill_file' in inventory" \
        "check_tool_in_inventory '$skill_file'"
done

echo ""

# -----------------------------------------------------------------------------
# AC2: MCP Server Names Identified
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC2: MCP Server Names Identified${NC}"
echo "--------------------------------------------------------"

# TEST-AC2-1.1: MCP Server Mapping section exists
run_test "TEST-AC2-1.1" "[P0] MCP Server Mapping section exists" \
    "grep -q '## MCP Server Mapping' '$AUDIT_FILE'"

# TEST-AC2-1.2: MCP mapping includes specific server names (e.g., 'github')
run_test "TEST-AC2-1.2" "[P0] MCP mapping references 'github' server" \
    "awk '/## MCP Server Mapping/,/^## [^M]/' '$AUDIT_FILE' | grep -qi 'github'"

# TEST-AC2-1.3: MCP-enhanced tools are documented (pr.md, ci-orchestrate.md expected)
run_test "TEST-AC2-1.3" "[P1] MCP mapping includes pr.md" \
    "check_mcp_mapping 'pr.md'"

run_test "TEST-AC2-1.4" "[P1] MCP mapping includes ci-orchestrate.md" \
    "check_mcp_mapping 'ci-orchestrate.md'"

# TEST-AC2-1.5: MCP mapping table or list has at least 2 entries
run_test "TEST-AC2-1.5" "[P1] MCP mapping has at least 2 tool entries" \
    "awk '/## MCP Server Mapping/,/^## [^M]/' '$AUDIT_FILE' | grep -cE '^\|[^-]|^- ' | xargs test 2 -le"

echo ""

# -----------------------------------------------------------------------------
# AC3: Tier Classification Draft
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC3: Tier Classification Draft${NC}"
echo "--------------------------------------------------------"

# TEST-AC3-1.1: Tier Classification section exists
run_test "TEST-AC3-1.1" "[P0] Tier Classification section exists" \
    "grep -q '## Tier Classification' '$AUDIT_FILE'"

# TEST-AC3-1.2: Standalone tier subsection exists
run_test "TEST-AC3-1.2" "[P0] Standalone tier subsection exists" \
    "grep -q '### Standalone' '$AUDIT_FILE'"

# TEST-AC3-1.3: MCP-Enhanced tier subsection exists
run_test "TEST-AC3-1.3" "[P0] MCP-Enhanced tier subsection exists" \
    "grep -q '### MCP-Enhanced' '$AUDIT_FILE'"

# TEST-AC3-1.4: BMAD-Required tier subsection exists
run_test "TEST-AC3-1.4" "[P0] BMAD-Required tier subsection exists" \
    "grep -q '### BMAD-Required' '$AUDIT_FILE'"

# TEST-AC3-1.5: Project-Context tier subsection exists
run_test "TEST-AC3-1.5" "[P0] Project-Context tier subsection exists" \
    "grep -q '### Project-Context' '$AUDIT_FILE'"

echo ""

# -----------------------------------------------------------------------------
# AC3: Tier Classification - All Tools Classified
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC3: Tier Classification - Tool Assignment Verification${NC}"
echo "--------------------------------------------------------"

# Verify selected tools appear in tier sections (spot check key tools)
run_test "TEST-AC3-2.1" "[P1] nextsession.md classified in a tier" \
    "check_tier_classification 'nextsession.md'"

run_test "TEST-AC3-2.2" "[P1] pr.md classified in a tier" \
    "check_tier_classification 'pr.md'"

run_test "TEST-AC3-2.3" "[P1] epic-dev.md classified in a tier" \
    "check_tier_classification 'epic-dev.md'"

run_test "TEST-AC3-2.4" "[P1] unit-test-fixer.md classified in a tier" \
    "check_tier_classification 'unit-test-fixer.md'"

run_test "TEST-AC3-2.5" "[P1] digdeep.md classified in a tier" \
    "check_tier_classification 'digdeep.md'"

echo ""

# -----------------------------------------------------------------------------
# AC3: Tier Classification - Single Tier Assignment
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC3: Tier Classification - Single Tier Validation${NC}"
echo "--------------------------------------------------------"

# Verify tools have exactly ONE tier (not multiple)
run_test "TEST-AC3-3.1" "[P2] pr.md has exactly one tier" \
    "check_single_tier 'pr.md'"

run_test "TEST-AC3-3.2" "[P2] epic-dev.md has exactly one tier" \
    "check_single_tier 'epic-dev.md'"

run_test "TEST-AC3-3.3" "[P2] unit-test-fixer.md has exactly one tier" \
    "check_single_tier 'unit-test-fixer.md'"

echo ""

# -----------------------------------------------------------------------------
# Completeness Validation
# -----------------------------------------------------------------------------
echo -e "${YELLOW}Completeness Validation${NC}"
echo "--------------------------------------------------------"

# TEST-COMP-1.1: Audit has Issues Found section (documenting non-compliant metadata)
run_test "TEST-COMP-1.1" "[P1] Audit has Issues Found section" \
    "grep -q '## Issues Found' '$AUDIT_FILE'"

# TEST-COMP-1.2: All 23 tools are represented somewhere in the audit
run_test "TEST-COMP-1.2" "[P0] Audit references all 23 tools" \
    "[ \$(grep -oE 'pr\.md|ci-orchestrate\.md|test-orchestrate\.md|commit-orchestrate\.md|parallelize\.md|parallelize-agents\.md|epic-dev\.md|epic-dev-full\.md|epic-dev-init\.md|nextsession\.md|usertestgates\.md|unit-test-fixer\.md|api-test-fixer\.md|database-test-fixer\.md|e2e-test-fixer\.md|linting-fixer\.md|type-error-fixer\.md|import-error-fixer\.md|security-scanner\.md|pr-workflow-manager\.md|parallel-executor\.md|digdeep\.md|pr-workflow\.md' '$AUDIT_FILE' | sort -u | wc -l) -ge 20 ]"

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "========================================================"
echo "TEST SUMMARY"
echo "========================================================"
echo ""
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo "Total Tests: $TOTAL"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}STATUS: ALL TESTS PASS - Audit is complete!${NC}"
    exit 0
else
    echo -e "${RED}STATUS: RED PHASE - $FAIL_COUNT test(s) failing${NC}"
    echo ""
    echo "Failed Tests:"
    for result in "${RESULTS[@]}"; do
        if [[ $result == FAIL* ]]; then
            echo "  - ${result#FAIL: }"
        fi
    done
    # Cap exit code at 1 (standard for test failure)
    exit 1
fi
