#!/bin/bash
# =============================================================================
# ATDD Tests for Story 2.3: Standardize Agent Metadata
# =============================================================================
# These tests verify that all 11 agent files have standardized metadata:
# - Description field: verb-first, under 60 characters
# - Prerequisites field: correct tier notation
# - Frontmatter structure: exact YAML format
#
# Test Phase: RED (tests should fail until implementation is complete)
# Story: 2-3-standardize-agent-metadata
# =============================================================================

# Note: NOT using set -e because we want to continue running tests even if some fail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"

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

# Expected agent files (exactly 11)
AGENT_FILES="unit-test-fixer.md api-test-fixer.md database-test-fixer.md e2e-test-fixer.md linting-fixer.md type-error-fixer.md import-error-fixer.md security-scanner.md pr-workflow-manager.md parallel-executor.md digdeep.md"

# Expected descriptions (standardized format from story)
get_expected_description() {
    case "$1" in
        "unit-test-fixer.md") echo "Fixes Python test failures for pytest and unittest" ;;
        "api-test-fixer.md") echo "Fixes API endpoint test failures" ;;
        "database-test-fixer.md") echo "Fixes database mock and integration test failures" ;;
        "e2e-test-fixer.md") echo "Fixes Playwright E2E test failures" ;;
        "linting-fixer.md") echo "Fixes Python linting and formatting issues" ;;
        "type-error-fixer.md") echo "Fixes Python type errors and annotations" ;;
        "import-error-fixer.md") echo "Fixes Python import and dependency errors" ;;
        "security-scanner.md") echo "Scans code for security vulnerabilities" ;;
        "pr-workflow-manager.md") echo "Manages pull request workflows for any Git project" ;;
        "parallel-executor.md") echo "Executes tasks independently without delegation" ;;
        "digdeep.md") echo "Investigates root causes using Five Whys analysis" ;;
        *) echo "" ;;
    esac
}

# Expected prerequisites (based on tier from story)
get_expected_prerequisites() {
    case "$1" in
        "unit-test-fixer.md") echo "test files in project" ;;
        "api-test-fixer.md") echo "API test files in project" ;;
        "database-test-fixer.md") echo "database test files in project" ;;
        "e2e-test-fixer.md") echo "E2E test files in project" ;;
        "linting-fixer.md") echo "linting config in project" ;;
        "type-error-fixer.md") echo "Python/TypeScript project" ;;
        "import-error-fixer.md") echo "code files in project" ;;
        "security-scanner.md") echo "code files in project" ;;
        "pr-workflow-manager.md") echo "\`github\` MCP" ;;
        "parallel-executor.md") echo "—" ;;
        "digdeep.md") echo "\`perplexity-ask\` MCP" ;;
        *) echo "" ;;
    esac
}

# Present-tense verbs (common starting verbs for descriptions)
VALID_VERBS="Fixes|Scans|Executes|Manages|Investigates|Analyzes|Validates|Handles|Processes|Monitors|Resolves|Checks|Creates|Generates"

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

# Extract description field from frontmatter (handles multi-line YAML)
get_description() {
    local file="$1"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")
    # Get description line, handle both single-line and first line of multi-line
    local desc_line
    desc_line=$(echo "$frontmatter" | grep -E '^description:' | head -1)
    # Extract value - handle quoted and unquoted, single-line only
    echo "$desc_line" | sed 's/description:[[:space:]]*//' | tr -d '"' | sed 's/|[[:space:]]*$//'
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

# TEST-AC-2.3.1a: Description field exists in an agent file
test_description_field_exists() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    if ! echo "$frontmatter" | grep -qE '^description:'; then
        echo "  Missing description field in: $agent"
        return 1
    fi

    return 0
}

# TEST-AC-2.3.1b: Description starts with present-tense verb
test_description_starts_with_verb() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description to verify: $agent"
        return 1
    fi

    # Check if description starts with a valid verb
    if ! echo "$desc" | grep -qE "^($VALID_VERBS)"; then
        echo "  Description does not start with verb: '$desc'"
        echo "  Expected to start with one of: Fixes, Scans, Executes, Manages, Investigates, etc."
        return 1
    fi

    return 0
}

# TEST-AC-2.3.1c: Description is under 60 characters
test_description_under_60_chars() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description to verify: $agent"
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

# TEST-AC-2.3.1d: Description matches expected standardized value
test_description_matches_expected() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"
    local expected_desc
    expected_desc=$(get_expected_description "$agent")

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local actual_desc
    actual_desc=$(get_description "$file")

    if [[ "$actual_desc" != "$expected_desc" ]]; then
        echo "  Description mismatch in: $agent"
        echo "  Expected: '$expected_desc'"
        echo "  Actual:   '$actual_desc'"
        return 1
    fi

    return 0
}

# =============================================================================
# AC2: Prerequisites Field - Individual Tests
# =============================================================================

# TEST-AC-2.3.2a: Prerequisites field exists in an agent file
test_prerequisites_field_exists() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local prereq
    prereq=$(get_prerequisites "$file")

    if [[ -z "$prereq" ]]; then
        echo "  Missing prerequisites field in: $agent"
        return 1
    fi

    return 0
}

# TEST-AC-2.3.2b: Prerequisites matches expected tier notation
test_prerequisites_matches_expected() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"
    local expected_prereq
    expected_prereq=$(get_expected_prerequisites "$agent")

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local actual_prereq
    actual_prereq=$(get_prerequisites "$file")

    # Compare directly (backticks should be preserved in the file)
    if [[ "$actual_prereq" != "$expected_prereq" ]]; then
        echo "  Prerequisites mismatch in: $agent"
        echo "  Expected: '$expected_prereq'"
        echo "  Actual:   '$actual_prereq'"
        return 1
    fi

    return 0
}

# TEST-AC-2.3.2c: Prerequisites uses correct tier format
test_prerequisites_valid_format() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local prereq
    prereq=$(get_prerequisites "$file")

    if [[ -z "$prereq" ]]; then
        echo "  Missing prerequisites field in: $agent"
        return 1
    fi

    # Valid formats per story:
    # - "—" (em dash, U+2014) for standalone
    # - "`server` MCP" for MCP-enhanced (backticks around server name)
    # - descriptive text for Project-Context (lowercase start)

    # Check for valid formats
    if [[ "$prereq" == "—" ]]; then
        return 0
    elif echo "$prereq" | grep -qE '^\`[a-z-]+\` MCP$'; then
        return 0
    elif [[ -n "$prereq" ]] && [[ "$prereq" =~ ^[a-zA-Z] ]]; then
        # Allows descriptive text (Project-Context tier)
        return 0
    fi

    echo "  Invalid prerequisites format: '$prereq'"
    echo "  Expected: '—' | '\`server\` MCP' | descriptive text"
    return 1
}

# =============================================================================
# AC3: Frontmatter Structure - Individual Tests
# =============================================================================

# TEST-AC-2.3.3a: File has valid YAML frontmatter
test_valid_frontmatter() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    if ! has_valid_frontmatter "$file"; then
        echo "  Invalid frontmatter structure in: $agent"
        echo "  Expected: File to start with '---' and have closing '---'"
        return 1
    fi

    return 0
}

# TEST-AC-2.3.3b: Frontmatter has both required fields
test_frontmatter_has_required_fields() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

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
        echo "  Missing required frontmatter fields in: $agent"
        echo "  Has description: $has_desc"
        echo "  Has prerequisites: $has_prereq"
        return 1
    fi

    return 0
}

# TEST-AC-2.3.3c: Frontmatter fields are properly quoted
test_frontmatter_fields_quoted() {
    local agent="$1"
    local file="$AGENTS_DIR/$agent"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Check description is quoted (single line format)
    local desc_line
    desc_line=$(echo "$frontmatter" | grep -E '^description:')
    if ! echo "$desc_line" | grep -qE '^description:[[:space:]]*".*"$'; then
        echo "  Description not properly quoted in: $agent"
        echo "  Found: $desc_line"
        echo "  Expected format: description: \"value\""
        return 1
    fi

    # Check prerequisites is quoted
    local prereq_line
    prereq_line=$(echo "$frontmatter" | grep -E '^prerequisites:')
    if ! echo "$prereq_line" | grep -qE '^prerequisites:[[:space:]]*".*"$'; then
        echo "  Prerequisites not properly quoted in: $agent"
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
echo "ATDD Tests for Story 2.3: Standardize Agent Metadata"
echo "============================================================================="
echo "Test Phase: RED (expecting failures - metadata not yet standardized)"
echo "Story: 2-3-standardize-agent-metadata"
echo "Project Root: $PROJECT_ROOT"
echo "Agents Dir: $AGENTS_DIR"
echo "============================================================================="
echo ""

# =============================================================================
# AC1: Description Format Tests
# =============================================================================
echo -e "\n${BLUE}=== AC1: Description Format Tests ===${NC}\n"

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.1a-${agent%%.md}: Description field exists in $agent" \
        test_description_field_exists "$agent"
done

echo ""

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.1b-${agent%%.md}: Description starts with verb in $agent" \
        test_description_starts_with_verb "$agent"
done

echo ""

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.1c-${agent%%.md}: Description under 60 chars in $agent" \
        test_description_under_60_chars "$agent"
done

echo ""

for agent in $AGENT_FILES; do
    expected_desc=$(get_expected_description "$agent")
    run_test "TEST-AC-2.3.1d-${agent%%.md}: Description matches expected ('$expected_desc')" \
        test_description_matches_expected "$agent"
done

# =============================================================================
# AC2: Prerequisites Field Tests
# =============================================================================
echo -e "\n${BLUE}=== AC2: Prerequisites Field Tests ===${NC}\n"

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.2a-${agent%%.md}: Prerequisites field exists in $agent" \
        test_prerequisites_field_exists "$agent"
done

echo ""

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.2b-${agent%%.md}: Prerequisites has valid format in $agent" \
        test_prerequisites_valid_format "$agent"
done

echo ""

for agent in $AGENT_FILES; do
    expected_prereq=$(get_expected_prerequisites "$agent")
    run_test "TEST-AC-2.3.2c-${agent%%.md}: Prerequisites matches expected ('$expected_prereq')" \
        test_prerequisites_matches_expected "$agent"
done

# =============================================================================
# AC3: Frontmatter Structure Tests
# =============================================================================
echo -e "\n${BLUE}=== AC3: Frontmatter Structure Tests ===${NC}\n"

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.3a-${agent%%.md}: Valid YAML frontmatter in $agent" \
        test_valid_frontmatter "$agent"
done

echo ""

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.3b-${agent%%.md}: Has required fields (description, prerequisites) in $agent" \
        test_frontmatter_has_required_fields "$agent"
done

echo ""

for agent in $AGENT_FILES; do
    run_test "TEST-AC-2.3.3c-${agent%%.md}: Frontmatter fields properly quoted in $agent" \
        test_frontmatter_fields_quoted "$agent"
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
    echo "This is the expected state before implementing Story 2.3."
    echo ""
    echo "To proceed to GREEN phase:"
    echo "1. Update each agent file with standardized frontmatter"
    echo "2. Ensure description field starts with verb and is under 60 chars"
    echo "3. Ensure prerequisites field uses correct tier notation"
    echo "4. Re-run this test script to verify all tests pass"
    exit 1
else
    echo -e "\n${GREEN}GREEN PHASE: All tests passing!${NC}"
    echo "Story 2.3 implementation is complete."
    exit 0
fi
