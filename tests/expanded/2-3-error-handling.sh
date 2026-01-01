#!/bin/bash

# Test Expansion: Story 2.3 - Agent Metadata Error Handling & Regression Prevention
# Priority: P1 (Important - Should Pass)
# Focus: Regression prevention, tier classification accuracy, error handling

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Project root (dynamically resolved - works from anywhere)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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
echo "Priority: P1 (Error Handling & Regression Prevention)"
echo "============================================================================="
echo ""

# =============================================================================
# CATEGORY 1: Regression Prevention (33 tests)
# =============================================================================

echo "-----------------------------------------------------------------------------"
echo "CATEGORY 1: Regression Prevention (33 tests)"
echo "-----------------------------------------------------------------------------"

# Test 1.1: No old format multi-line YAML descriptions (11 tests)
echo -e "\n${YELLOW}Test Group 1.1: No Old Format Multi-line YAML Descriptions${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P1-1.1-$agent_name" \
        "No multi-line YAML description in $agent_name" \
        "! grep -Pzo '(?s)description:.*\n.*\n.*\n.*---' '$agent_file' > /dev/null"
done

# Test 1.2: No deprecated "none" or "N/A" prerequisites (11 tests)
echo -e "\n${YELLOW}Test Group 1.2: No Deprecated Prerequisites Values${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P1-1.2-$agent_name" \
        "No deprecated prerequisites values in $agent_name" \
        "! grep -E 'prerequisites:.*\"(none|N/A|null)\"' '$agent_file' > /dev/null"
done

# Test 1.3: Description length is reasonable (not just 1-2 chars) (11 tests)
echo -e "\n${YELLOW}Test Group 1.3: Description Length Reasonableness${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P1-1.3-$agent_name" \
        "Description is reasonably long (>20 chars) in $agent_name" \
        "[[ \$(grep '^description:' '$agent_file' | sed 's/description: \"\(.*\)\"/\1/' | wc -c) -gt 20 ]]"
done

# =============================================================================
# CATEGORY 2: Tier Classification Accuracy (4 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 2: Tier Classification Accuracy (4 tests)"
echo "-----------------------------------------------------------------------------"

# Test 2.1: MCP-enhanced agents correctly classified
echo -e "\n${YELLOW}Test Group 2.1: MCP-Enhanced Agents${NC}"
run_test "TEST-P1-2.1-mcp-agents" \
    "MCP-enhanced agents have MCP prerequisites" \
    "grep -E 'prerequisites:.*\`.*\` MCP' '$AGENTS_DIR/pr-workflow-manager.md' > /dev/null && \
     grep -E 'prerequisites:.*\`.*\` MCP' '$AGENTS_DIR/digdeep.md' > /dev/null"

# Test 2.2: Standalone agents correctly classified
echo -e "\n${YELLOW}Test Group 2.2: Standalone Agents${NC}"
run_test "TEST-P1-2.2-standalone-agents" \
    "Standalone agents use em dash (—)" \
    "grep 'prerequisites: \"—\"' '$AGENTS_DIR/parallel-executor.md' > /dev/null"

# Test 2.3: Project-context agents correctly classified
echo -e "\n${YELLOW}Test Group 2.3: Project-Context Agents${NC}"
run_test "TEST-P1-2.3-project-context-agents" \
    "Project-context agents have descriptive text prerequisites" \
    "grep 'prerequisites:.*files.*project' '$AGENTS_DIR/unit-test-fixer.md' > /dev/null && \
     grep 'prerequisites:.*files.*project' '$AGENTS_DIR/api-test-fixer.md' > /dev/null"

# Test 2.4: No misclassified tiers
echo -e "\n${YELLOW}Test Group 2.4: No Misclassified Tiers${NC}"
run_test "TEST-P1-2.4-no-misclassifications" \
    "No standalone agents have MCP prerequisites" \
    "! grep 'prerequisites: \"—\"' '$AGENTS_DIR/pr-workflow-manager.md' > /dev/null && \
     ! grep 'prerequisites: \"—\"' '$AGENTS_DIR/digdeep.md' > /dev/null"

# =============================================================================
# CATEGORY 3: YAML & Markdown Validation (33 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 3: YAML & Markdown Validation (33 tests)"
echo "-----------------------------------------------------------------------------"

# Test 3.1: Valid Markdown files (11 tests)
echo -e "\n${YELLOW}Test Group 3.1: Valid Markdown Files${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P1-3.1-$agent_name" \
        "Valid markdown file: $agent_name" \
        "[[ -f '$agent_file' && -r '$agent_file' ]]"
done

# Test 3.2: Valid YAML frontmatter (11 tests)
echo -e "\n${YELLOW}Test Group 3.2: Valid YAML Frontmatter${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P1-3.2-$agent_name" \
        "Valid YAML frontmatter in $agent_name" \
        "head -1 '$agent_file' | grep '^---$' > /dev/null && \
         head -20 '$agent_file' | tail -n +2 | grep '^---$' > /dev/null"
done

# Test 3.3: All fields properly quoted (11 tests)
echo -e "\n${YELLOW}Test Group 3.3: Fields Properly Quoted${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P1-3.3-$agent_name" \
        "Description and prerequisites quoted in $agent_name" \
        "grep '^description: \"' '$agent_file' > /dev/null && \
         grep '^prerequisites: \"' '$agent_file' > /dev/null"
done

# =============================================================================
# CATEGORY 4: Cross-Reference Validation (3 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 4: Cross-Reference Validation (3 tests)"
echo "-----------------------------------------------------------------------------"

# Test 4.1: Exactly 11 agent files
echo -e "\n${YELLOW}Test Group 4.1: File Count Validation${NC}"
run_test "TEST-P1-4.1-file-count" \
    "Exactly 11 agent files exist" \
    "[[ \$(ls '$AGENTS_DIR'/*.md | wc -l) -eq 11 ]]"

# Test 4.2: All expected agents present
echo -e "\n${YELLOW}Test Group 4.2: Expected Agents Present${NC}"
EXPECTED_AGENTS=(
    "unit-test-fixer"
    "api-test-fixer"
    "database-test-fixer"
    "e2e-test-fixer"
    "linting-fixer"
    "type-error-fixer"
    "import-error-fixer"
    "security-scanner"
    "pr-workflow-manager"
    "parallel-executor"
    "digdeep"
)

all_present=true
for agent in "${EXPECTED_AGENTS[@]}"; do
    if [[ ! -f "$AGENTS_DIR/$agent.md" ]]; then
        all_present=false
        break
    fi
done

run_test "TEST-P1-4.2-all-expected-present" \
    "All 11 expected agents present" \
    "$all_present"

# Test 4.3: No extra agent files
echo -e "\n${YELLOW}Test Group 4.3: No Extra Files${NC}"
extra_files=$(ls "$AGENTS_DIR"/*.md 2>/dev/null | while read -r file; do
    basename=$(basename "$file" .md)
    found=false
    for expected in "${EXPECTED_AGENTS[@]}"; do
        if [[ "$basename" == "$expected" ]]; then
            found=true
            break
        fi
    done
    if [[ "$found" == "false" ]]; then
        echo "$basename"
    fi
done)

run_test "TEST-P1-4.3-no-extra-files" \
    "No extra agent files beyond expected 11" \
    "[[ -z '$extra_files' ]]"

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "TEST SUMMARY (P1: Error Handling & Regression Prevention)"
echo "============================================================================="
echo "Tests Run:    $TOTAL_TESTS"
echo -e "Tests Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Tests Failed: ${RED}$FAILED_TESTS${NC}"
echo "============================================================================="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}GREEN PHASE: All P1 error handling tests passing!${NC}"
    exit 0
else
    echo -e "${RED}RED PHASE: $FAILED_TESTS test(s) failing.${NC}"
    exit 1
fi
