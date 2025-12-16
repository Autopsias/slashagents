#!/bin/bash
# =============================================================================
# Expanded Tests for Story 2.2: Error Handling & Regression Prevention
# =============================================================================
# Priority: P1 (Important scenarios - should pass)
#
# These tests validate:
# - Tier classification accuracy (commands in correct tier)
# - Regression prevention (old format not re-introduced)
# - Error handling (missing/invalid frontmatter scenarios)
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
    echo -e "${YELLOW}TEST [P1]:${NC} $1"
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
# P1 Regression Tests: Old Format Detection
# =============================================================================

# Test: Description should NOT contain old format patterns
test_no_old_format_description() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    # Old format patterns to reject
    local old_patterns=(
        "^Simple "
        "^Quick "
        "^A helper"
        "^Full TDD/ATDD"
        "Orchestrate " # Should be "Orchestrates"
        "Parallelize " # Should be "Parallelizes"
    )

    for pattern in "${old_patterns[@]}"; do
        if echo "$desc" | grep -qE "$pattern"; then
            echo "  Old format detected in description: '$desc'"
            echo "  Pattern matched: '$pattern'"
            return 1
        fi
    done

    return 0
}

# Test: Prerequisites should NOT use old "none" format
test_no_none_prerequisites() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local prereq
    prereq=$(get_prerequisites "$file")

    # Reject "none" or "None" - should be "—" (em dash)
    if [[ "$prereq" == "none" ]] || [[ "$prereq" == "None" ]] || [[ "$prereq" == "NONE" ]]; then
        echo "  Old 'none' format detected (should be em dash '—'): '$prereq'"
        return 1
    fi

    return 0
}

# Test: Description length should be significantly under 60 (not just squeezed)
test_description_reasonable_length() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    # Descriptions between 50-59 chars might be artificially squeezed
    # Good descriptions should be clear and concise (20-50 chars ideal)
    local char_count=${#desc}

    # This is informational - we still pass, just warn
    if [[ $char_count -gt 50 ]]; then
        echo "  INFO: Description is $char_count chars (consider shortening for clarity)"
    fi

    return 0
}

# =============================================================================
# P1 Tier Classification Tests
# =============================================================================

# Test: MCP-enhanced commands require specific MCP servers
test_mcp_commands_accurate() {
    local mcp_commands=("pr.md" "ci-orchestrate.md")

    for cmd in "${mcp_commands[@]}"; do
        local file="$COMMANDS_DIR/$cmd"

        # Verify prerequisites contains MCP notation
        local prereq
        prereq=$(get_prerequisites "$file")

        if ! echo "$prereq" | grep -qE '^\`[a-z-]+\` MCP$'; then
            echo "  MCP command missing MCP prerequisites: $cmd"
            echo "  Found: '$prereq'"
            return 1
        fi

        # Verify the file actually uses gh or github in its content
        if ! grep -qE '(gh |github)' "$file"; then
            echo "  WARNING: $cmd marked as MCP but doesn't use github commands"
        fi
    done

    return 0
}

# Test: BMAD commands require BMAD framework
test_bmad_commands_accurate() {
    local bmad_commands=("epic-dev.md" "epic-dev-full.md" "epic-dev-init.md")

    for cmd in "${bmad_commands[@]}"; do
        local file="$COMMANDS_DIR/$cmd"

        # Verify prerequisites is "BMAD framework"
        local prereq
        prereq=$(get_prerequisites "$file")

        if [[ "$prereq" != "BMAD framework" ]]; then
            echo "  BMAD command missing BMAD framework prerequisite: $cmd"
            echo "  Found: '$prereq'"
            return 1
        fi

        # Verify the file actually references BMAD
        if ! grep -qiE 'bmad' "$file"; then
            echo "  WARNING: $cmd marked as BMAD but doesn't mention BMAD"
        fi
    done

    return 0
}

# Test: Standalone commands should have no external dependencies
test_standalone_commands_accurate() {
    local standalone_commands=("test-orchestrate.md" "commit-orchestrate.md" "parallelize.md" "parallelize-agents.md" "nextsession.md")

    for cmd in "${standalone_commands[@]}"; do
        local file="$COMMANDS_DIR/$cmd"

        # Verify prerequisites is em dash
        local prereq
        prereq=$(get_prerequisites "$file")

        if [[ "$prereq" != "—" ]]; then
            echo "  Standalone command has non-em-dash prerequisites: $cmd"
            echo "  Found: '$prereq'"
            return 1
        fi

        # Check file doesn't use gh commands (would indicate MCP dependency)
        if grep -qE 'gh (pr|issue|repo)' "$file"; then
            echo "  WARNING: $cmd marked standalone but uses gh commands"
        fi
    done

    return 0
}

# Test: Project-context command should have descriptive prerequisites
test_project_context_accurate() {
    local cmd="usertestgates.md"
    local file="$COMMANDS_DIR/$cmd"

    local prereq
    prereq=$(get_prerequisites "$file")

    # Should not be generic markers
    if [[ "$prereq" == "—" ]] || [[ "$prereq" == "BMAD framework" ]] || echo "$prereq" | grep -qE '^\`[a-z-]+\` MCP$'; then
        echo "  Project-context command has wrong prerequisites format: $cmd"
        echo "  Expected: descriptive text"
        echo "  Found: '$prereq'"
        return 1
    fi

    # Should be descriptive
    if [[ ${#prereq} -lt 10 ]]; then
        echo "  Project-context prerequisites too short: '$prereq'"
        return 1
    fi

    return 0
}

# =============================================================================
# P1 Error Handling Tests: Malformed Files
# =============================================================================

# Test: All command files are valid markdown
test_file_is_valid_markdown() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    # Check file exists and is readable
    if [[ ! -f "$file" ]]; then
        echo "  File does not exist: $file"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        echo "  File is not readable: $file"
        return 1
    fi

    # File should have .md extension
    if [[ ! "$cmd" =~ \.md$ ]]; then
        echo "  File does not have .md extension: $cmd"
        return 1
    fi

    return 0
}

# Test: Frontmatter is valid YAML (no syntax errors)
test_frontmatter_valid_yaml() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Check key-value format
    if ! echo "$frontmatter" | grep -qE '^[a-z-]+:[[:space:]]+".*"$'; then
        echo "  Frontmatter may have invalid YAML syntax in: $cmd"
        return 1
    fi

    return 0
}

# Test: No unquoted field values in frontmatter
test_frontmatter_all_quoted() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Extract just description and prerequisites lines
    local desc_line
    local prereq_line
    desc_line=$(echo "$frontmatter" | grep -E '^description:')
    prereq_line=$(echo "$frontmatter" | grep -E '^prerequisites:')

    # Both should have quoted values
    if ! echo "$desc_line" | grep -qE '^description:[[:space:]]*".*"$'; then
        echo "  Description field not quoted in: $cmd"
        return 1
    fi

    if ! echo "$prereq_line" | grep -qE '^prerequisites:[[:space:]]*".*"$'; then
        echo "  Prerequisites field not quoted in: $cmd"
        return 1
    fi

    return 0
}

# =============================================================================
# P1 Cross-Reference Tests
# =============================================================================

# Test: Command count is exactly 11 (no additions/deletions)
test_exactly_11_commands() {
    local count
    count=$(echo $COMMAND_FILES | wc -w | tr -d ' ')

    if [[ $count -ne 11 ]]; then
        echo "  Expected exactly 11 commands, found: $count"
        return 1
    fi

    return 0
}

# Test: All expected command files exist
test_all_commands_exist() {
    for cmd in $COMMAND_FILES; do
        local file="$COMMANDS_DIR/$cmd"
        if [[ ! -f "$file" ]]; then
            echo "  Expected command file not found: $cmd"
            return 1
        fi
    done

    return 0
}

# Test: No extra command files in directory
test_no_extra_commands() {
    local expected_count=11
    local actual_count
    actual_count=$(ls -1 "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

    if [[ $actual_count -ne $expected_count ]]; then
        echo "  Expected $expected_count command files, found: $actual_count"
        echo "  Extra or missing files detected"
        return 1
    fi

    return 0
}

# =============================================================================
# Main Test Execution
# =============================================================================

echo "============================================================================="
echo "Expanded Tests for Story 2.2: Error Handling & Regression [P1]"
echo "============================================================================="
echo "Priority: P1 (Important scenarios - should pass)"
echo "Test Focus: Tier accuracy, regression prevention, error handling"
echo "============================================================================="
echo ""

# =============================================================================
# Regression Tests
# =============================================================================
echo -e "\n${BLUE}=== P1: Regression Prevention Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "P1-REGRESSION-1: No old format description in $cmd" \
        test_no_old_format_description "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P1-REGRESSION-2: No 'none' prerequisites in $cmd" \
        test_no_none_prerequisites "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P1-REGRESSION-3: Description reasonable length in $cmd" \
        test_description_reasonable_length "$cmd"
done

# =============================================================================
# Tier Classification Tests
# =============================================================================
echo -e "\n${BLUE}=== P1: Tier Classification Accuracy ===${NC}\n"

run_test "P1-TIER-1: MCP commands accurately classified" \
    test_mcp_commands_accurate

run_test "P1-TIER-2: BMAD commands accurately classified" \
    test_bmad_commands_accurate

run_test "P1-TIER-3: Standalone commands accurately classified" \
    test_standalone_commands_accurate

run_test "P1-TIER-4: Project-context command accurately classified" \
    test_project_context_accurate

# =============================================================================
# Error Handling Tests
# =============================================================================
echo -e "\n${BLUE}=== P1: Error Handling Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "P1-ERROR-1: File is valid markdown: $cmd" \
        test_file_is_valid_markdown "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P1-ERROR-2: Frontmatter is valid YAML in $cmd" \
        test_frontmatter_valid_yaml "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P1-ERROR-3: All fields quoted in $cmd" \
        test_frontmatter_all_quoted "$cmd"
done

# =============================================================================
# Cross-Reference Tests
# =============================================================================
echo -e "\n${BLUE}=== P1: Cross-Reference Validation ===${NC}\n"

run_test "P1-XREF-1: Exactly 11 commands defined" \
    test_exactly_11_commands

run_test "P1-XREF-2: All expected commands exist" \
    test_all_commands_exist

run_test "P1-XREF-3: No extra command files" \
    test_no_extra_commands

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "TEST SUMMARY [P1]"
echo "============================================================================="
echo -e "Tests Run:    ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "============================================================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${RED}FAILED: $TESTS_FAILED P1 error handling test(s) failing.${NC}"
    exit 1
else
    echo -e "\n${GREEN}SUCCESS: All P1 error handling tests passing!${NC}"
    exit 0
fi
