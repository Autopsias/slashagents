#!/bin/bash
# =============================================================================
# ATDD Tests for Story 2.2: Standardize Command Metadata
# =============================================================================
# These tests verify that all 11 command files have standardized metadata:
# - Description field: verb-first, under 60 characters
# - Prerequisites field: correct tier notation
# - Frontmatter structure: exact YAML format
#
# Test Phase: RED (tests should fail until implementation is complete)
# Story: 2-2-standardize-command-metadata
# =============================================================================

# Note: NOT using set -e because we want to continue running tests even if some fail

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

# Expected command files (exactly 11)
COMMAND_FILES="pr.md ci-orchestrate.md test-orchestrate.md commit-orchestrate.md parallelize.md parallelize-agents.md epic-dev.md epic-dev-full.md epic-dev-init.md nextsession.md usertestgates.md"

# Expected descriptions (standardized format)
get_expected_description() {
    case "$1" in
        "pr.md") echo "Manages pull request workflows" ;;
        "ci-orchestrate.md") echo "Orchestrates CI/CD pipeline fixes" ;;
        "test-orchestrate.md") echo "Orchestrates test failure analysis" ;;
        "commit-orchestrate.md") echo "Orchestrates git commit workflows" ;;
        "parallelize.md") echo "Parallelizes tasks across sub-agents" ;;
        "parallelize-agents.md") echo "Parallelizes tasks with specialized agents" ;;
        "epic-dev.md") echo "Automates BMAD development cycle" ;;
        "epic-dev-full.md") echo "Executes full TDD/ATDD BMAD cycle" ;;
        "epic-dev-init.md") echo "Verifies BMAD project setup" ;;
        "nextsession.md") echo "Generates continuation prompt" ;;
        "usertestgates.md") echo "Finds and runs next test gate" ;;
        *) echo "" ;;
    esac
}

# Expected prerequisites (based on tier)
get_expected_prerequisites() {
    case "$1" in
        "pr.md") echo "\`github\` MCP" ;;
        "ci-orchestrate.md") echo "\`github\` MCP" ;;
        "test-orchestrate.md") echo "—" ;;
        "commit-orchestrate.md") echo "—" ;;
        "parallelize.md") echo "—" ;;
        "parallelize-agents.md") echo "—" ;;
        "epic-dev.md") echo "BMAD framework" ;;
        "epic-dev-full.md") echo "BMAD framework" ;;
        "epic-dev-init.md") echo "BMAD framework" ;;
        "nextsession.md") echo "—" ;;
        "usertestgates.md") echo "test gates in project" ;;
        *) echo "" ;;
    esac
}

# Present-tense verbs (common starting verbs for descriptions)
VALID_VERBS="Manages|Orchestrates|Parallelizes|Automates|Executes|Verifies|Generates|Finds|Creates|Handles|Validates|Runs|Analyzes|Processes|Configures|Deploys|Monitors|Tracks|Reports|Fixes|Resolves|Checks|Tests|Builds|Initializes"

# =============================================================================
# Test Helper Functions
# =============================================================================

log_test() {
    echo -e "${YELLOW}TEST:${NC} $1"
}

log_pass() {
    echo -e "${GREEN}PASS:${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo -e "${RED}FAIL:${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

run_test() {
    local test_name="$1"
    shift
    local test_result

    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "$test_name"

    # Execute the test command/function
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
    # Extract content between --- markers
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

# Check if file has valid YAML frontmatter structure
has_valid_frontmatter() {
    local file="$1"
    # Check for opening and closing ---
    local first_line
    first_line=$(head -n 1 "$file")
    if [[ "$first_line" != "---" ]]; then
        return 1
    fi
    # Check for closing ---
    if ! sed -n '2,/^---$/p' "$file" | tail -n 1 | grep -q '^---$'; then
        return 1
    fi
    return 0
}

# =============================================================================
# AC1: Description Format - Individual Tests
# =============================================================================

# TEST-AC-2.2.1a: Description field exists in a command file
test_description_field_exists() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description field in: $cmd"
        return 1
    fi

    return 0
}

# TEST-AC-2.2.1b: Description starts with present-tense verb
test_description_starts_with_verb() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description to verify: $cmd"
        return 1
    fi

    # Check if description starts with a valid verb
    if ! echo "$desc" | grep -qE "^($VALID_VERBS)"; then
        echo "  Description does not start with verb: '$desc'"
        echo "  Expected to start with one of: Manages, Orchestrates, Parallelizes, etc."
        return 1
    fi

    return 0
}

# TEST-AC-2.2.1c: Description is under 60 characters
test_description_under_60_chars() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description to verify: $cmd"
        return 1
    fi

    local char_count=${#desc}

    if [[ $char_count -ge 60 ]]; then
        echo "  Description too long: $char_count chars (max: 59)"
        echo "  Description: '$desc'"
        return 1
    fi

    return 0
}

# TEST-AC-2.2.1d: Description matches expected standardized value
test_description_matches_expected() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"
    local expected_desc
    expected_desc=$(get_expected_description "$cmd")

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local actual_desc
    actual_desc=$(get_description "$file")

    if [[ "$actual_desc" != "$expected_desc" ]]; then
        echo "  Description mismatch in: $cmd"
        echo "  Expected: '$expected_desc'"
        echo "  Actual:   '$actual_desc'"
        return 1
    fi

    return 0
}

# =============================================================================
# AC2: Prerequisites Field - Individual Tests
# =============================================================================

# TEST-AC-2.2.2a: Prerequisites field exists in a command file
test_prerequisites_field_exists() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local prereq
    prereq=$(get_prerequisites "$file")

    if [[ -z "$prereq" ]]; then
        echo "  Missing prerequisites field in: $cmd"
        return 1
    fi

    return 0
}

# TEST-AC-2.2.2b: Prerequisites matches expected tier notation
test_prerequisites_matches_expected() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"
    local expected_prereq
    expected_prereq=$(get_expected_prerequisites "$cmd")

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local actual_prereq
    actual_prereq=$(get_prerequisites "$file")

    # Compare directly (backticks should be preserved in the file)
    if [[ "$actual_prereq" != "$expected_prereq" ]]; then
        echo "  Prerequisites mismatch in: $cmd"
        echo "  Expected: '$expected_prereq'"
        echo "  Actual:   '$actual_prereq'"
        return 1
    fi

    return 0
}

# TEST-AC-2.2.2c: Prerequisites uses correct tier format
test_prerequisites_valid_format() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local prereq
    prereq=$(get_prerequisites "$file")

    if [[ -z "$prereq" ]]; then
        echo "  Missing prerequisites field in: $cmd"
        return 1
    fi

    # Valid formats:
    # - "—" (em dash) for standalone
    # - "`server` MCP" for MCP-enhanced (backticks around server name)
    # - "BMAD framework" for BMAD-required
    # - descriptive text for Project-Context

    # Check for valid formats
    if [[ "$prereq" == "—" ]]; then
        return 0
    elif [[ "$prereq" == "BMAD framework" ]]; then
        return 0
    elif echo "$prereq" | grep -qE '^\`[a-z-]+\` MCP$'; then
        return 0
    elif [[ -n "$prereq" ]] && [[ "$prereq" =~ ^[a-z] ]]; then
        # Allows descriptive text (Project-Context tier)
        return 0
    fi

    echo "  Invalid prerequisites format: '$prereq'"
    echo "  Expected: '—' | '\`server\` MCP' | 'BMAD framework' | descriptive text"
    return 1
}

# =============================================================================
# AC3: Frontmatter Structure - Individual Tests
# =============================================================================

# TEST-AC-2.2.3a: File has valid YAML frontmatter
test_valid_frontmatter() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    if ! has_valid_frontmatter "$file"; then
        echo "  Invalid frontmatter structure in: $cmd"
        echo "  Expected: File to start with '---' and have closing '---'"
        return 1
    fi

    return 0
}

# TEST-AC-2.2.3b: Frontmatter has both required fields
test_frontmatter_has_required_fields() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    local has_desc=false
    local has_prereq=false

    if echo "$frontmatter" | grep -qE '^description:'; then
        has_desc=true
    fi

    if echo "$frontmatter" | grep -qE '^prerequisites:'; then
        has_prereq=true
    fi

    if [[ "$has_desc" != "true" ]] || [[ "$has_prereq" != "true" ]]; then
        echo "  Missing required frontmatter fields in: $cmd"
        echo "  Has description: $has_desc"
        echo "  Has prerequisites: $has_prereq"
        return 1
    fi

    return 0
}

# TEST-AC-2.2.3c: Frontmatter fields are properly quoted
test_frontmatter_fields_quoted() {
    local cmd="$1"
    local file="$COMMANDS_DIR/$cmd"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Check description is quoted
    local desc_line
    desc_line=$(echo "$frontmatter" | grep -E '^description:')
    if ! echo "$desc_line" | grep -qE '^description:[[:space:]]*".*"$'; then
        echo "  Description not properly quoted in: $cmd"
        echo "  Found: $desc_line"
        echo "  Expected format: description: \"value\""
        return 1
    fi

    # Check prerequisites is quoted
    local prereq_line
    prereq_line=$(echo "$frontmatter" | grep -E '^prerequisites:')
    if ! echo "$prereq_line" | grep -qE '^prerequisites:[[:space:]]*".*"$'; then
        echo "  Prerequisites not properly quoted in: $cmd"
        echo "  Found: $prereq_line"
        echo "  Expected format: prerequisites: \"value\""
        return 1
    fi

    return 0
}

# =============================================================================
# Main Test Execution
# =============================================================================

echo "============================================================================="
echo "ATDD Tests for Story 2.2: Standardize Command Metadata"
echo "============================================================================="
echo "Test Phase: RED (expecting failures - metadata not yet standardized)"
echo "Story: 2-2-standardize-command-metadata"
echo "Project Root: $PROJECT_ROOT"
echo "Commands Dir: $COMMANDS_DIR"
echo "============================================================================="
echo ""

# =============================================================================
# AC1: Description Format Tests
# =============================================================================
echo -e "\n${BLUE}=== AC1: Description Format Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.1a-${cmd%%.md}: Description field exists in $cmd" \
        test_description_field_exists "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.1b-${cmd%%.md}: Description starts with verb in $cmd" \
        test_description_starts_with_verb "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.1c-${cmd%%.md}: Description under 60 chars in $cmd" \
        test_description_under_60_chars "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    expected_desc=$(get_expected_description "$cmd")
    run_test "TEST-AC-2.2.1d-${cmd%%.md}: Description matches expected ('$expected_desc')" \
        test_description_matches_expected "$cmd"
done

# =============================================================================
# AC2: Prerequisites Field Tests
# =============================================================================
echo -e "\n${BLUE}=== AC2: Prerequisites Field Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.2a-${cmd%%.md}: Prerequisites field exists in $cmd" \
        test_prerequisites_field_exists "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.2b-${cmd%%.md}: Prerequisites has valid format in $cmd" \
        test_prerequisites_valid_format "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    expected_prereq=$(get_expected_prerequisites "$cmd")
    run_test "TEST-AC-2.2.2c-${cmd%%.md}: Prerequisites matches expected ('$expected_prereq')" \
        test_prerequisites_matches_expected "$cmd"
done

# =============================================================================
# AC3: Frontmatter Structure Tests
# =============================================================================
echo -e "\n${BLUE}=== AC3: Frontmatter Structure Tests ===${NC}\n"

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.3a-${cmd%%.md}: Valid YAML frontmatter in $cmd" \
        test_valid_frontmatter "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.3b-${cmd%%.md}: Has required fields (description, prerequisites) in $cmd" \
        test_frontmatter_has_required_fields "$cmd"
done

echo ""

for cmd in $COMMAND_FILES; do
    run_test "TEST-AC-2.2.3c-${cmd%%.md}: Frontmatter fields properly quoted in $cmd" \
        test_frontmatter_fields_quoted "$cmd"
done

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "TEST SUMMARY"
echo "============================================================================="
echo -e "Tests Run:    ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "============================================================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${RED}RED PHASE: $TESTS_FAILED test(s) failing as expected.${NC}"
    echo "This is the expected state before implementing Story 2.2."
    echo ""
    echo "To proceed to GREEN phase:"
    echo "1. Update each command file with standardized frontmatter"
    echo "2. Ensure description field starts with verb and is under 60 chars"
    echo "3. Ensure prerequisites field uses correct tier notation"
    echo "4. Re-run this test script to verify all tests pass"
    exit 1
else
    echo -e "\n${GREEN}GREEN PHASE: All tests passing!${NC}"
    echo "Story 2.2 implementation is complete."
    exit 0
fi
