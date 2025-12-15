#!/bin/bash

# Test Expansion: Story 2.3 - Agent Metadata Edge Cases & Boundary Conditions
# Priority: P2 (Good to Have - Edge Cases)
# Focus: Boundary conditions, format variations, whitespace handling

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Project root
PROJECT_ROOT="/Users/ricardocarvalho/CC_Agents_Commands"
AGENTS_DIR="$PROJECT_ROOT/agents"

# Helper function to run a test
run_test() {
    local test_id="$1"
    local test_description="$2"
    local test_command="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${YELLOW}TEST:${NC} $test_id: $test_description"

    if eval "$test_command"; then
        echo -e "${GREEN}PASS:${NC} $test_id: $test_description"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}FAIL:${NC} $test_id: $test_description"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

echo "============================================================================="
echo "EXPANDED TEST SUITE: Story 2.3 - Agent Metadata"
echo "Priority: P2 (Edge Cases & Boundary Conditions)"
echo "============================================================================="
echo ""

# =============================================================================
# CATEGORY 1: Description Boundaries (55 tests)
# =============================================================================

echo "-----------------------------------------------------------------------------"
echo "CATEGORY 1: Description Boundaries (55 tests)"
echo "-----------------------------------------------------------------------------"

# Test 1.1: Description not exactly 60 chars (should be under) (11 tests)
echo -e "\n${YELLOW}Test Group 1.1: Description Not Exactly 60 Characters${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    char_count=$(grep '^description:' "$agent_file" | sed 's/description: "\(.*\)"/\1/' | wc -c | tr -d ' ')
    run_test "TEST-P2-1.1-$agent_name" \
        "Description not exactly 60 chars (under 60) in $agent_name" \
        "[[ $char_count -lt 60 ]]"
done

# Test 1.2: No YAML-breaking characters (11 tests)
echo -e "\n${YELLOW}Test Group 1.2: No YAML-Breaking Characters${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P2-1.2-$agent_name" \
        "No unescaped quotes or colons in description of $agent_name" \
        "! grep '^description:' '$agent_file' | grep -v '\".*\"' | grep -E '[:\"]' > /dev/null"
done

# Test 1.3: No leading/trailing whitespace in description (11 tests)
echo -e "\n${YELLOW}Test Group 1.3: No Leading/Trailing Whitespace in Description${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P2-1.3-$agent_name" \
        "No leading/trailing whitespace in description of $agent_name" \
        "! grep '^description: \" ' '$agent_file' > /dev/null && \
         ! grep '^description:.*\" $' '$agent_file' > /dev/null"
done

# Test 1.4: No multiple consecutive spaces in description (11 tests)
echo -e "\n${YELLOW}Test Group 1.4: No Multiple Consecutive Spaces${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P2-1.4-$agent_name" \
        "No multiple consecutive spaces in description of $agent_name" \
        "! grep '^description:' '$agent_file' | grep -E '  +' > /dev/null"
done

# Test 1.5: No ending punctuation in description (11 tests)
echo -e "\n${YELLOW}Test Group 1.5: No Ending Punctuation in Description${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P2-1.5-$agent_name" \
        "No ending punctuation in description of $agent_name" \
        "! grep '^description:.*[.!?]\"$' '$agent_file' > /dev/null"
done

# =============================================================================
# CATEGORY 2: Prerequisites Format (44 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 2: Prerequisites Format (44 tests)"
echo "-----------------------------------------------------------------------------"

# Test 2.1: Correct em dash type (U+2014, not hyphen) for standalone (1 test)
echo -e "\n${YELLOW}Test Group 2.1: Correct Em Dash Type${NC}"
run_test "TEST-P2-2.1-em-dash-type" \
    "Standalone agent uses correct em dash (—) not hyphen (-)" \
    "grep 'prerequisites: \"—\"' '$AGENTS_DIR/parallel-executor.md' > /dev/null && \
     ! grep 'prerequisites: \"-\"' '$AGENTS_DIR/parallel-executor.md' > /dev/null"

# Test 2.2: MCP prerequisites have backticks (11 tests - check all agents)
echo -e "\n${YELLOW}Test Group 2.2: MCP Backticks Present When Needed${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    # If prerequisites contains "MCP", it should have backticks
    run_test "TEST-P2-2.2-$agent_name" \
        "If MCP prerequisite, has backticks in $agent_name" \
        "! grep 'prerequisites:.*MCP' '$agent_file' | grep -v '\`' > /dev/null"
done

# Test 2.3: No leading/trailing whitespace in prerequisites (11 tests)
echo -e "\n${YELLOW}Test Group 2.3: No Leading/Trailing Whitespace in Prerequisites${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P2-2.3-$agent_name" \
        "No leading/trailing whitespace in prerequisites of $agent_name" \
        "! grep '^prerequisites: \" ' '$agent_file' > /dev/null && \
         ! grep '^prerequisites:.*\" $' '$agent_file' > /dev/null"
done

# Test 2.4: MCP server names are lowercase (2 tests)
echo -e "\n${YELLOW}Test Group 2.4: MCP Server Names Lowercase${NC}"
run_test "TEST-P2-2.4-pr-workflow-manager" \
    "MCP server name lowercase in pr-workflow-manager" \
    "grep 'prerequisites: \"\`github\` MCP\"' '$AGENTS_DIR/pr-workflow-manager.md' > /dev/null"

run_test "TEST-P2-2.4-digdeep" \
    "MCP server name lowercase in digdeep" \
    "grep 'prerequisites: \"\`perplexity-ask\` MCP\"' '$AGENTS_DIR/digdeep.md' > /dev/null"

# Test 2.5: Project-context prerequisites are descriptive (8 tests)
echo -e "\n${YELLOW}Test Group 2.5: Project-Context Prerequisites Are Descriptive${NC}"
PROJECT_CONTEXT_AGENTS=(
    "unit-test-fixer"
    "api-test-fixer"
    "database-test-fixer"
    "e2e-test-fixer"
    "linting-fixer"
    "type-error-fixer"
    "import-error-fixer"
    "security-scanner"
)

for agent in "${PROJECT_CONTEXT_AGENTS[@]}"; do
    run_test "TEST-P2-2.5-$agent" \
        "Prerequisites descriptive (not just '—' or MCP) in $agent" \
        "! grep 'prerequisites: \"—\"' '$AGENTS_DIR/$agent.md' > /dev/null && \
         ! grep 'prerequisites:.*MCP' '$AGENTS_DIR/$agent.md' > /dev/null"
done

# Test 2.6: Prerequisites don't end with period (11 tests)
echo -e "\n${YELLOW}Test Group 2.6: Prerequisites Don't End With Period${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P2-2.6-$agent_name" \
        "Prerequisites don't end with period in $agent_name" \
        "! grep '^prerequisites:.*\\.\"$' '$agent_file' > /dev/null"
done

# =============================================================================
# CATEGORY 3: Frontmatter Structure (33 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 3: Frontmatter Structure (33 tests)"
echo "-----------------------------------------------------------------------------"

# Test 3.1: No extra blank lines in frontmatter (11 tests)
echo -e "\n${YELLOW}Test Group 3.1: No Extra Blank Lines in Frontmatter${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    # Count blank lines between opening --- and closing ---
    blank_count=$(awk '/^---$/{p++} p==1 && /^$/{blanks++} p==2{exit} END{print blanks+0}' "$agent_file")
    run_test "TEST-P2-3.1-$agent_name" \
        "No blank lines in frontmatter of $agent_name" \
        "[[ $blank_count -eq 0 ]]"
done

# Test 3.2: Correct field order (description before prerequisites) (11 tests)
echo -e "\n${YELLOW}Test Group 3.2: Correct Field Order${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    desc_line=$(grep -n '^description:' "$agent_file" | cut -d: -f1)
    prereq_line=$(grep -n '^prerequisites:' "$agent_file" | cut -d: -f1)
    run_test "TEST-P2-3.2-$agent_name" \
        "Description appears before prerequisites in $agent_name" \
        "[[ $desc_line -lt $prereq_line ]]"
done

# Test 3.3: Clean closing marker (no trailing spaces) (11 tests)
echo -e "\n${YELLOW}Test Group 3.3: Clean Closing Marker${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P2-3.3-$agent_name" \
        "Closing --- has no trailing spaces in $agent_name" \
        "head -20 '$agent_file' | tail -n +2 | grep -E '^---\s+$' > /dev/null; [[ \$? -ne 0 ]]"
done

# =============================================================================
# CATEGORY 4: Cross-File Consistency (3 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 4: Cross-File Consistency (3 tests)"
echo "-----------------------------------------------------------------------------"

# Test 4.1: Standalone agents consistent
echo -e "\n${YELLOW}Test Group 4.1: Standalone Agents Consistent${NC}"
run_test "TEST-P2-4.1-standalone-consistent" \
    "All standalone agents use same em dash format" \
    "grep 'prerequisites: \"—\"' '$AGENTS_DIR/parallel-executor.md' > /dev/null"

# Test 4.2: MCP agents consistent format
echo -e "\n${YELLOW}Test Group 4.2: MCP Agents Consistent Format${NC}"
run_test "TEST-P2-4.2-mcp-consistent" \
    "All MCP agents use backtick format" \
    "grep 'prerequisites: \"\`.*\` MCP\"' '$AGENTS_DIR/pr-workflow-manager.md' > /dev/null && \
     grep 'prerequisites: \"\`.*\` MCP\"' '$AGENTS_DIR/digdeep.md' > /dev/null"

# Test 4.3: Project-context agents all have descriptive text
echo -e "\n${YELLOW}Test Group 4.3: Project-Context Agents Descriptive${NC}"
all_descriptive=true
for agent in "${PROJECT_CONTEXT_AGENTS[@]}"; do
    if ! grep 'prerequisites:' "$AGENTS_DIR/$agent.md" | grep -E '(files|project|config)' > /dev/null; then
        all_descriptive=false
        break
    fi
done

run_test "TEST-P2-4.3-project-context-descriptive" \
    "All project-context agents have descriptive prerequisites" \
    "$all_descriptive"

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "TEST SUMMARY (P2: Edge Cases & Boundary Conditions)"
echo "============================================================================="
echo "Tests Run:    $TOTAL_TESTS"
echo -e "Tests Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Tests Failed: ${RED}$FAILED_TESTS${NC}"
echo "============================================================================="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}GREEN PHASE: All P2 edge case tests passing!${NC}"
    exit 0
else
    echo -e "${YELLOW}YELLOW PHASE: $FAILED_TESTS test(s) failing (edge cases - non-critical).${NC}"
    exit 1
fi
