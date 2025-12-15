#!/bin/bash
# =============================================================================
# Expanded Tests for Story 2.2: Integration & Future-Proofing
# =============================================================================
# Priority: P3 (Future-proofing - optional)
#
# These tests validate:
# - Integration with other metadata fields
# - Future-proofing against common mistakes
# - Documentation consistency
# =============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMANDS_DIR="$PROJECT_ROOT/commands"
AGENTS_DIR="$PROJECT_ROOT/agents"
README_FILE="$PROJECT_ROOT/README.md"

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
    echo -e "${YELLOW}TEST [P3]:${NC} $1"
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
# P3 Integration Tests: Other Frontmatter Fields
# =============================================================================

# Test: Commands with argument-hint should still have correct metadata
test_integration_with_argument_hint() {
    # Commands that likely have argument-hint
    local cmd="pr.md"
    local file="$COMMANDS_DIR/$cmd"

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Should have both description and argument-hint
    if ! echo "$frontmatter" | grep -qE '^description:'; then
        echo "  Description missing in command with argument-hint"
        return 1
    fi

    if echo "$frontmatter" | grep -qE '^argument-hint:'; then
        # Verify description comes before argument-hint (logical order)
        local desc_line
        local arg_line
        desc_line=$(echo "$frontmatter" | grep -n '^description:' | cut -d: -f1)
        arg_line=$(echo "$frontmatter" | grep -n '^argument-hint:' | cut -d: -f1)

        if [[ $desc_line -gt $arg_line ]]; then
            echo "  Description should come before argument-hint"
            return 1
        fi
    fi

    return 0
}

# Test: Commands with allowed-tools should still have correct metadata
test_integration_with_allowed_tools() {
    local cmd="pr.md"
    local file="$COMMANDS_DIR/$cmd"

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Should have both required fields
    if ! echo "$frontmatter" | grep -qE '^description:'; then
        echo "  Description missing in command with allowed-tools"
        return 1
    fi

    if ! echo "$frontmatter" | grep -qE '^prerequisites:'; then
        echo "  Prerequisites missing in command with allowed-tools"
        return 1
    fi

    return 0
}

# Test: Frontmatter field count is reasonable (not bloated)
test_frontmatter_field_count() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Count fields (lines with colons)
    local field_count
    field_count=$(echo "$frontmatter" | grep -cE '^[a-z-]+:' || true)

    # Should have at least 2 (description, prerequisites), max reasonable is 5-6
    if [[ $field_count -lt 2 ]]; then
        echo "  Too few frontmatter fields: $field_count (expected at least 2)"
        return 1
    fi

    if [[ $field_count -gt 6 ]]; then
        echo "  Too many frontmatter fields: $field_count (consider simplifying)"
        # This is a warning, not a hard failure
    fi

    return 0
}

# =============================================================================
# P3 Future-Proofing Tests: Common Mistakes
# =============================================================================

# Test: Description doesn't duplicate command name
test_description_not_redundant() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"
    local cmd_name="${cmd%%.md}"

    local desc
    desc=$(get_description "$file")

    # Convert kebab-case to words
    local cmd_words
    cmd_words=$(echo "$cmd_name" | tr '-' ' ')

    # Description should not be just the command name
    if echo "$desc" | grep -qiE "^$cmd_words$"; then
        echo "  Description is redundant with command name: '$desc'"
        return 1
    fi

    return 0
}

# Test: Prerequisites doesn't duplicate description
test_prerequisites_not_redundant() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    local prereq
    desc=$(get_description "$file")
    prereq=$(get_prerequisites "$file")

    # Prerequisites should be dependency info, not description
    if [[ "$desc" == "$prereq" ]]; then
        echo "  Prerequisites duplicates description"
        return 1
    fi

    return 0
}

# Test: Description uses active voice (not passive)
test_description_active_voice() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local desc
    desc=$(get_description "$file")

    # Passive voice indicators
    local passive_patterns=("is used" "are used" "is executed" "are executed" "is run" "are run")

    for pattern in "${passive_patterns[@]}"; do
        if echo "$desc" | grep -qiE "$pattern"; then
            echo "  Description uses passive voice: '$desc'"
            echo "  Consider active voice instead"
            return 1
        fi
    done

    return 0
}

# Test: Prerequisites doesn't include version numbers
test_prerequisites_no_versions() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    local prereq
    prereq=$(get_prerequisites "$file")

    # Version numbers make prerequisites brittle
    if echo "$prereq" | grep -qE '[0-9]+\.[0-9]+'; then
        echo "  Prerequisites includes version number: '$prereq'"
        echo "  Version numbers make prerequisites brittle"
        return 1
    fi

    return 0
}

# =============================================================================
# P3 Documentation Consistency Tests
# =============================================================================

# Test: Command descriptions match README documentation
test_readme_consistency() {
    if [[ ! -f "$README_FILE" ]]; then
        echo "  README.md not found, skipping consistency check"
        return 0 # Not a failure, just not applicable yet
    fi

    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"
    local cmd_name="${cmd%%.md}"

    local desc
    desc=$(get_description "$file")

    # Check if README mentions this command with consistent description
    if grep -qE "/$cmd_name" "$README_FILE"; then
        # README should have similar description (not exact match required)
        local readme_context
        readme_context=$(grep -A2 "/$cmd_name" "$README_FILE" || true)

        # Extract key words from description
        local key_words
        key_words=$(echo "$desc" | grep -oE '[A-Z][a-z]+' | head -2)

        # Check if key words appear in README context
        for word in $key_words; do
            if ! echo "$readme_context" | grep -qiE "$word"; then
                echo "  INFO: README description may differ from frontmatter for $cmd"
                break
            fi
        done
    fi

    return 0
}

# Test: No orphaned command files (all in README)
test_all_commands_documented() {
    if [[ ! -f "$README_FILE" ]]; then
        echo "  README.md not found, skipping documentation check"
        return 0
    fi

    for cmd in $COMMAND_FILES; do
        local cmd_name="${cmd%%.md}"

        if ! grep -qE "/$cmd_name" "$README_FILE"; then
            echo "  Command not documented in README: $cmd_name"
            return 1
        fi
    done

    return 0
}

# =============================================================================
# P3 Agent Consistency Tests (if agents exist)
# =============================================================================

# Test: Agents use similar metadata format
test_agent_metadata_consistency() {
    if [[ ! -d "$AGENTS_DIR" ]]; then
        echo "  Agents directory not found, skipping agent consistency check"
        return 0
    fi

    local agent_files
    agent_files=$(ls "$AGENTS_DIR"/*.md 2>/dev/null || true)

    if [[ -z "$agent_files" ]]; then
        return 0 # No agents yet
    fi

    # Check agents have frontmatter
    for agent_file in $agent_files; do
        if ! head -1 "$agent_file" | grep -q '^---$'; then
            echo "  INFO: Agent missing frontmatter: $(basename $agent_file)"
        fi
    done

    return 0
}

# =============================================================================
# Main Test Execution
# =============================================================================

echo "============================================================================="
echo "Expanded Tests for Story 2.2: Integration & Future-Proofing [P3]"
echo "============================================================================="
echo "Priority: P3 (Future-proofing - optional)"
echo "Test Focus: Integration, common mistakes, documentation consistency"
echo "============================================================================="
echo ""

# =============================================================================
# Integration Tests
# =============================================================================
echo -e "\n${BLUE}=== P3: Integration Tests ===${NC}\n"

run_test "P3-INTEGRATION-1: Works with argument-hint field" \
    test_integration_with_argument_hint

run_test "P3-INTEGRATION-2: Works with allowed-tools field" \
    test_integration_with_allowed_tools

for cmd in $COMMAND_FILES; do
    run_test "P3-INTEGRATION-3: Reasonable field count in $cmd" \
        test_frontmatter_field_count "$cmd"
done

# =============================================================================
# Future-Proofing Tests
# =============================================================================
echo -e "\n${BLUE}=== P3: Future-Proofing Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "P3-FUTURE-1: Description not redundant in $cmd" \
        test_description_not_redundant "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P3-FUTURE-2: Prerequisites not redundant in $cmd" \
        test_prerequisites_not_redundant "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P3-FUTURE-3: Description uses active voice in $cmd" \
        test_description_active_voice "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "P3-FUTURE-4: Prerequisites no version numbers in $cmd" \
        test_prerequisites_no_versions "$cmd"
done

# =============================================================================
# Documentation Consistency Tests
# =============================================================================
echo -e "\n${BLUE}=== P3: Documentation Consistency ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "P3-DOC-1: README consistency for $cmd" \
        test_readme_consistency "$cmd"
done

echo ""

run_test "P3-DOC-2: All commands documented in README" \
    test_all_commands_documented

run_test "P3-DOC-3: Agent metadata consistency" \
    test_agent_metadata_consistency

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "TEST SUMMARY [P3]"
echo "============================================================================="
echo -e "Tests Run:    ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "============================================================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${YELLOW}WARNING: $TESTS_FAILED P3 future-proofing test(s) failing.${NC}"
    echo "These are optional tests - consider addressing for long-term quality."
    exit 0 # P3 failures don't fail the build
else
    echo -e "\n${GREEN}SUCCESS: All P3 future-proofing tests passing!${NC}"
    exit 0
fi
