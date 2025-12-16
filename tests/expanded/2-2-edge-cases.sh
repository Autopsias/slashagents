#!/bin/bash
# =============================================================================
# Expanded Tests for Story 2.2: Edge Cases & Boundary Conditions
# =============================================================================
# Priority: P2 (Edge cases - good to have)
#
# These tests cover scenarios beyond ATDD acceptance criteria:
# - Boundary conditions (exactly 60 chars, em dash vs other dashes)
# - Special characters in descriptions
# - Whitespace handling
# - Format variations
# =============================================================================

set -eo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMANDS_DIR="$PROJECT_ROOT/commands"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Command files
COMMAND_FILES="pr.md ci-orchestrate.md test-orchestrate.md commit-orchestrate.md parallelize.md parallelize-agents.md epic-dev.md epic-dev-full.md epic-dev-init.md nextsession.md usertestgates.md"

# =============================================================================
# Test Helper Functions
# =============================================================================

log_test() {
    echo -e "${YELLOW}TEST [P2]:${NC} $1"
}

log_pass() {
    echo -e "${GREEN}PASS:${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo -e "${RED}FAIL:${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

run_test() {
    local test_name="$1"
    shift
    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "$test_name"

    if "$@"; then
        log_pass "$test_name"
        return 0
    else
        log_fail "$test_name"
        return 1
    fi
}

# Extract frontmatter from a file
get_frontmatter() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | sed '1d;$d'
}

# Extract description field from frontmatter
get_description() {
    local file="$1"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")
    echo "$frontmatter" | grep -E '^description:' | sed 's/description:[[:space:]]*//' | tr -d '"'
}

# Extract prerequisites field from frontmatter
get_prerequisites() {
    local file="$1"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")
    echo "$frontmatter" | grep -E '^prerequisites:' | sed 's/prerequisites:[[:space:]]*//' | tr -d '"'
}

# =============================================================================
# P2 Edge Case Tests: Description Boundaries
# =============================================================================

# Test: Description should not be EXACTLY 60 chars (max is 59)
test_description_not_exactly_60() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    if [[ ${#desc} -eq 60 ]]; then
        echo "  Description is exactly 60 chars (max allowed is 59): '$desc'"
        return 1
    fi

    return 0
}

# Test: Description should not contain special characters that break YAML
test_description_no_yaml_breakers() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    # Check for unescaped quotes, colons at end, etc.
    if echo "$desc" | grep -qE '(^:|:$|^-|^>|^[|])'; then
        echo "  Description contains YAML special chars: '$desc'"
        return 1
    fi

    return 0
}

# Test: Description should not have leading/trailing whitespace
test_description_no_leading_trailing_whitespace() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    # Check for leading whitespace
    if [[ "$desc" =~ ^[[:space:]] ]]; then
        echo "  Description has leading whitespace: '$desc'"
        return 1
    fi

    # Check for trailing whitespace
    if [[ "$desc" =~ [[:space:]]$ ]]; then
        echo "  Description has trailing whitespace: '$desc'"
        return 1
    fi

    return 0
}

# Test: Description should not have multiple consecutive spaces
test_description_no_multiple_spaces() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    if echo "$desc" | grep -qE '[[:space:]]{2,}'; then
        echo "  Description has multiple consecutive spaces: '$desc'"
        return 1
    fi

    return 0
}

# Test: Description should not end with punctuation
test_description_no_ending_punctuation() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    if [[ "$desc" =~ [.!?,:]$ ]]; then
        echo "  Description ends with punctuation: '$desc'"
        return 1
    fi

    return 0
}

# =============================================================================
# P2 Edge Case Tests: Prerequisites Format Validation
# =============================================================================

# Test: Em dash should be EXACTLY "—" (U+2014) not "-" or "--"
test_prerequisites_em_dash_exact() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local prereq
    prereq=$(get_prerequisites "$file")

    # Only test if it looks like a dash
    if [[ "$prereq" == "-" ]] || [[ "$prereq" == "--" ]]; then
        echo "  Prerequisites uses wrong dash type: '$prereq' (should be em dash '—')"
        return 1
    fi

    return 0
}

# Test: MCP format should have backticks around server name
test_prerequisites_mcp_backticks() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local prereq
    prereq=$(get_prerequisites "$file")

    # If it contains "MCP" but doesn't have backticks, fail
    if echo "$prereq" | grep -qi 'MCP'; then
        if ! echo "$prereq" | grep -qE '^\`[a-z-]+\` MCP$'; then
            echo "  MCP prerequisites missing backticks: '$prereq'"
            echo "  Expected format: \`server-name\` MCP"
            return 1
        fi
    fi

    return 0
}

# Test: Prerequisites should not have leading/trailing whitespace
test_prerequisites_no_leading_trailing_whitespace() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local prereq
    prereq=$(get_prerequisites "$file")

    # Check for leading whitespace
    if [[ "$prereq" =~ ^[[:space:]] ]]; then
        echo "  Prerequisites has leading whitespace: '$prereq'"
        return 1
    fi

    # Check for trailing whitespace
    if [[ "$prereq" =~ [[:space:]]$ ]]; then
        echo "  Prerequisites has trailing whitespace: '$prereq'"
        return 1
    fi

    return 0
}

# Test: "BMAD framework" should be exact case
test_prerequisites_bmad_case() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local prereq
    prereq=$(get_prerequisites "$file")

    # If it contains "bmad", verify exact format
    if echo "$prereq" | grep -qi 'bmad'; then
        if [[ "$prereq" != "BMAD framework" ]]; then
            echo "  BMAD format incorrect: '$prereq' (expected: 'BMAD framework')"
            return 1
        fi
    fi

    return 0
}

# =============================================================================
# P2 Edge Case Tests: Frontmatter Structure
# =============================================================================

# Test: Frontmatter should have no extra blank lines
test_frontmatter_no_extra_blank_lines() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Count blank lines in frontmatter
    local blank_lines
    blank_lines=$(echo "$frontmatter" | grep -c '^$' || true)

    if [[ $blank_lines -gt 0 ]]; then
        echo "  Frontmatter has $blank_lines blank line(s)"
        return 1
    fi

    return 0
}

# Test: Field order should be description then prerequisites
test_frontmatter_field_order() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Get line numbers
    local desc_line
    local prereq_line
    desc_line=$(echo "$frontmatter" | grep -n '^description:' | cut -d: -f1)
    prereq_line=$(echo "$frontmatter" | grep -n '^prerequisites:' | cut -d: -f1)

    if [[ $desc_line -gt $prereq_line ]]; then
        echo "  Field order incorrect: prerequisites before description"
        return 1
    fi

    return 0
}

# Test: Frontmatter closing marker should be on its own line
test_frontmatter_closing_marker_clean() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    # Get the line after the first closing ---
    local closing_line
    closing_line=$(sed -n '2,/^---$/p' "$file" | tail -n 1)

    if [[ "$closing_line" != "---" ]]; then
        echo "  Closing frontmatter marker not clean: '$closing_line'"
        return 1
    fi

    return 0
}

# =============================================================================
# P2 Edge Case Tests: Cross-File Consistency
# =============================================================================

# Test: All standalone commands use same prerequisites format
test_consistency_standalone_prerequisites() {
    local standalone_cmds=("test-orchestrate.md" "commit-orchestrate.md" "parallelize.md" "parallelize-agents.md" "nextsession.md")
    local expected_prereq="—"

    for cmd in "${standalone_cmds[@]}"; do
        local file="$COMMANDS_DIR/$cmd"
        local prereq
        prereq=$(get_prerequisites "$file")

        if [[ "$prereq" != "$expected_prereq" ]]; then
            echo "  Standalone command has inconsistent prerequisites: $cmd"
            echo "  Expected: '$expected_prereq', Got: '$prereq'"
            return 1
        fi
    done

    return 0
}

# Test: All MCP commands use same prerequisites format
test_consistency_mcp_prerequisites() {
    local mcp_cmds=("pr.md" "ci-orchestrate.md")
    local expected_prereq="\`github\` MCP"

    for cmd in "${mcp_cmds[@]}"; do
        local file="$COMMANDS_DIR/$cmd"
        local prereq
        prereq=$(get_prerequisites "$file")

        if [[ "$prereq" != "$expected_prereq" ]]; then
            echo "  MCP command has inconsistent prerequisites: $cmd"
            echo "  Expected: '$expected_prereq', Got: '$prereq'"
            return 1
        fi
    done

    return 0
}

# Test: All BMAD commands use same prerequisites format
test_consistency_bmad_prerequisites() {
    local bmad_cmds=("epic-dev.md" "epic-dev-full.md" "epic-dev-init.md")
    local expected_prereq="BMAD framework"

    for cmd in "${bmad_cmds[@]}"; do
        local file="$COMMANDS_DIR/$cmd"
        local prereq
        prereq=$(get_prerequisites "$file")

        if [[ "$prereq" != "$expected_prereq" ]]; then
            echo "  BMAD command has inconsistent prerequisites: $cmd"
            echo "  Expected: '$expected_prereq', Got: '$prereq'"
            return 1
        fi
    done

    return 0
}

# =============================================================================
# Main Test Execution
# =============================================================================

echo "============================================================================="
echo "Expanded Tests for Story 2.2: Edge Cases & Boundary Conditions [P2]"
echo "============================================================================="
echo "Priority: P2 (Edge cases - good to have)"
echo "Test Focus: Boundary conditions, special characters, consistency"
echo "============================================================================="
echo ""

# =============================================================================
# Description Boundary Tests
# =============================================================================
echo -e "\n${BLUE}=== P2: Description Boundary Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "P2-DESC-BOUNDARY-1: Not exactly 60 chars in $cmd" \
        test_description_not_exactly_60 "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-DESC-BOUNDARY-2: No YAML-breaking chars in $cmd" \
        test_description_no_yaml_breakers "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-DESC-BOUNDARY-3: No leading/trailing whitespace in $cmd" \
        test_description_no_leading_trailing_whitespace "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-DESC-BOUNDARY-4: No multiple consecutive spaces in $cmd" \
        test_description_no_multiple_spaces "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-DESC-BOUNDARY-5: No ending punctuation in $cmd" \
        test_description_no_ending_punctuation "$cmd"
done

# =============================================================================
# Prerequisites Format Tests
# =============================================================================
echo -e "\n${BLUE}=== P2: Prerequisites Format Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "P2-PREREQ-FORMAT-1: Correct em dash type in $cmd" \
        test_prerequisites_em_dash_exact "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-PREREQ-FORMAT-2: MCP backticks correct in $cmd" \
        test_prerequisites_mcp_backticks "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-PREREQ-FORMAT-3: No leading/trailing whitespace in $cmd" \
        test_prerequisites_no_leading_trailing_whitespace "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-PREREQ-FORMAT-4: BMAD framework exact case in $cmd" \
        test_prerequisites_bmad_case "$cmd"
done

# =============================================================================
# Frontmatter Structure Tests
# =============================================================================
echo -e "\n${BLUE}=== P2: Frontmatter Structure Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "P2-FRONTMATTER-1: No extra blank lines in $cmd" \
        test_frontmatter_no_extra_blank_lines "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-FRONTMATTER-2: Correct field order in $cmd" \
        test_frontmatter_field_order "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P2-FRONTMATTER-3: Clean closing marker in $cmd" \
        test_frontmatter_closing_marker_clean "$cmd"
done

# =============================================================================
# Cross-File Consistency Tests
# =============================================================================
echo -e "\n${BLUE}=== P2: Cross-File Consistency Tests ===${NC}\n"

run_test "P2-CONSISTENCY-1: Standalone commands consistent" \
    test_consistency_standalone_prerequisites

run_test "P2-CONSISTENCY-2: MCP commands consistent" \
    test_consistency_mcp_prerequisites

run_test "P2-CONSISTENCY-3: BMAD commands consistent" \
    test_consistency_bmad_prerequisites

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "TEST SUMMARY [P2]"
echo "============================================================================="
echo -e "Tests Run:    ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "============================================================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${RED}FAILED: $TESTS_FAILED P2 edge case test(s) failing.${NC}"
    exit 1
else
    echo -e "\n${GREEN}SUCCESS: All P2 edge case tests passing!${NC}"
    exit 0
fi
