#!/bin/bash
# =============================================================================
# ATDD Tests for Story 2.4: Standardize Skill Metadata
# =============================================================================
# These tests verify that the skill file (pr-workflow.md) has standardized metadata:
# - Description field: verb-first, under 60 characters
# - Prerequisites field: correct tier notation (em dash for standalone)
# - Frontmatter structure: exact YAML format
#
# Test Phase: RED (tests should fail until implementation is complete)
# Story: 2-4-standardize-skill-metadata
# =============================================================================

# Note: NOT using set -e because we want to continue running tests even if some fail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"

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

# Expected skill file (exactly 1)
SKILL_FILE="pr-workflow.md"

# Expected description (standardized format from story)
EXPECTED_DESCRIPTION="Manages PR workflows - create, status, merge, sync"

# Expected prerequisites (Standalone tier uses em dash U+2014)
EXPECTED_PREREQUISITES="—"

# Present-tense verbs (common starting verbs for descriptions)
VALID_VERBS="Manages|Handles|Provides|Fixes|Scans|Executes|Investigates|Analyzes|Validates|Processes|Monitors|Resolves|Checks|Creates|Generates"

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

# Count fields in frontmatter
count_frontmatter_fields() {
    local file="$1"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")
    echo "$frontmatter" | grep -cE '^[a-zA-Z_-]+:'
}

# =============================================================================
# AC1: Description Format Tests
# =============================================================================

# TEST-AC-2.4.1.1: Description field exists in skill file
test_description_field_exists() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    if ! echo "$frontmatter" | grep -qE '^description:'; then
        echo "  Missing description field in: $SKILL_FILE"
        return 1
    fi

    return 0
}

# TEST-AC-2.4.1.2: Description starts with present-tense verb
test_description_starts_with_verb() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description to verify: $SKILL_FILE"
        return 1
    fi

    # Check if description starts with a valid verb
    if ! echo "$desc" | grep -qE "^($VALID_VERBS)"; then
        echo "  Description does not start with verb: '$desc'"
        echo "  Expected to start with one of: Manages, Handles, Provides, etc."
        return 1
    fi

    return 0
}

# TEST-AC-2.4.1.3: Description is under 60 characters
test_description_under_60_chars() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description to verify: $SKILL_FILE"
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

# TEST-AC-2.4.1.4: Description matches expected standardized value
test_description_matches_expected() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local actual_desc
    actual_desc=$(get_description "$file")

    if [[ "$actual_desc" != "$EXPECTED_DESCRIPTION" ]]; then
        echo "  Description mismatch in: $SKILL_FILE"
        echo "  Expected: '$EXPECTED_DESCRIPTION'"
        echo "  Actual:   '$actual_desc'"
        return 1
    fi

    return 0
}

# TEST-AC-2.4.1.5: Description focuses on WHAT (not HOW)
test_description_focuses_on_what() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local desc
    desc=$(get_description "$file")

    if [[ -z "$desc" ]]; then
        echo "  Missing description to verify: $SKILL_FILE"
        return 1
    fi

    # Check for HOW indicators (implementation details)
    local how_indicators="Use when|Use this|when user mentions|trigger words|Git workflow terms"
    if echo "$desc" | grep -qiE "$how_indicators"; then
        echo "  Description contains HOW details (should focus on WHAT)"
        echo "  Description: '$desc'"
        return 1
    fi

    return 0
}

# =============================================================================
# AC2: Prerequisites Field Tests
# =============================================================================

# TEST-AC-2.4.2.1: Prerequisites field exists in skill file
test_prerequisites_field_exists() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local prereq
    prereq=$(get_prerequisites "$file")

    if [[ -z "$prereq" ]]; then
        echo "  Missing prerequisites field in: $SKILL_FILE"
        return 1
    fi

    return 0
}

# TEST-AC-2.4.2.2: Prerequisites uses em dash for standalone skill
test_prerequisites_uses_em_dash() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local prereq
    prereq=$(get_prerequisites "$file")

    # Per architecture.md: standalone skills use "—" (em dash U+2014)
    if [[ "$prereq" != "$EXPECTED_PREREQUISITES" ]]; then
        echo "  Prerequisites mismatch in: $SKILL_FILE"
        echo "  Expected: '$EXPECTED_PREREQUISITES' (em dash U+2014 for standalone)"
        echo "  Actual:   '$prereq'"
        return 1
    fi

    return 0
}

# TEST-AC-2.4.2.3: Prerequisites follows same notation as commands/agents
test_prerequisites_valid_format() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local prereq
    prereq=$(get_prerequisites "$file")

    if [[ -z "$prereq" ]]; then
        echo "  Missing prerequisites field in: $SKILL_FILE"
        return 1
    fi

    # Valid formats per architecture:
    # - "—" (em dash U+2014) for standalone
    # - "`server` MCP" for MCP-enhanced (backticks around server name)
    # - descriptive text for Project-Context

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
# AC3: Frontmatter Structure Tests
# =============================================================================

# TEST-AC-2.4.3.1: File has valid YAML frontmatter
test_valid_frontmatter() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    if ! has_valid_frontmatter "$file"; then
        echo "  Invalid frontmatter structure in: $SKILL_FILE"
        echo "  Expected: File to start with '---' and have closing '---'"
        return 1
    fi

    return 0
}

# TEST-AC-2.4.3.2: Frontmatter has exactly two required fields
test_frontmatter_has_required_fields() {
    local file="$SKILLS_DIR/$SKILL_FILE"

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
        echo "  Missing required frontmatter fields in: $SKILL_FILE"
        echo "  Has description: $has_desc"
        echo "  Has prerequisites: $has_prereq"
        return 1
    fi

    return 0
}

# TEST-AC-2.4.3.3: Frontmatter has no extra fields (like name:)
test_frontmatter_no_extra_fields() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Check specifically for 'name:' field which should NOT exist
    if echo "$frontmatter" | grep -qE '^name:'; then
        echo "  Extra 'name:' field found in frontmatter: $SKILL_FILE"
        echo "  The 'name:' field should be removed (not in standard template)"
        echo "  Fields found:"
        echo "$frontmatter" | grep -E '^[a-zA-Z_-]+:'
        return 1
    fi

    # Also check for any other unexpected fields
    local field_count
    field_count=$(echo "$frontmatter" | grep -cE '^[a-zA-Z_-]+:')

    # Only 2 fields expected: description and prerequisites
    if [[ $field_count -gt 2 ]]; then
        echo "  Extra fields found in frontmatter: $SKILL_FILE"
        echo "  Field count: $field_count (expected: 2)"
        echo "  Fields found:"
        echo "$frontmatter" | grep -E '^[a-zA-Z_-]+:'
        return 1
    fi

    return 0
}

# TEST-AC-2.4.3.4: Frontmatter description field is properly quoted
test_description_field_quoted() {
    local file="$SKILLS_DIR/$SKILL_FILE"

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
        echo "  Description not properly quoted in: $SKILL_FILE"
        echo "  Found: $desc_line"
        echo "  Expected format: description: \"value\""
        return 1
    fi

    return 0
}

# TEST-AC-2.4.3.5: Frontmatter prerequisites field is properly quoted
test_prerequisites_field_quoted() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Check prerequisites is quoted
    local prereq_line
    prereq_line=$(echo "$frontmatter" | grep -E '^prerequisites:')
    if ! echo "$prereq_line" | grep -qE '^prerequisites:[[:space:]]*".*"$'; then
        echo "  Prerequisites not properly quoted in: $SKILL_FILE"
        echo "  Found: $prereq_line"
        echo "  Expected format: prerequisites: \"value\""
        return 1
    fi

    return 0
}

# TEST-AC-2.4.3.6: Frontmatter matches exact target structure
test_frontmatter_exact_structure() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        return 1
    fi

    # Expected exact frontmatter (4 lines)
    local expected_frontmatter='---
description: "Manages PR workflows - create, status, merge, sync"
prerequisites: "—"
---'

    # Get actual first 4 lines of file
    local actual_frontmatter
    actual_frontmatter=$(head -n 4 "$file")

    if [[ "$actual_frontmatter" != "$expected_frontmatter" ]]; then
        echo "  Frontmatter structure mismatch in: $SKILL_FILE"
        echo ""
        echo "  Expected:"
        echo "$expected_frontmatter"
        echo ""
        echo "  Actual:"
        echo "$actual_frontmatter"
        return 1
    fi

    return 0
}

# =============================================================================
# Main Test Execution
# =============================================================================

echo "============================================================================="
echo "ATDD Tests for Story 2.4: Standardize Skill Metadata"
echo "============================================================================="
echo "Test Phase: RED (expecting failures - metadata not yet standardized)"
echo "Story: 2-4-standardize-skill-metadata"
echo "Project Root: $PROJECT_ROOT"
echo "Skills Dir: $SKILLS_DIR"
echo "============================================================================="
echo ""

# Verify skill file exists
if [[ ! -f "$SKILLS_DIR/$SKILL_FILE" ]]; then
    echo -e "${RED}CRITICAL:${NC} Skill file not found: $SKILLS_DIR/$SKILL_FILE"
    exit 1
fi

echo -e "${BLUE}Target File:${NC} $SKILL_FILE"
echo ""

# =============================================================================
# AC1: Description Format Tests
# =============================================================================
echo -e "\n${BLUE}=== AC1: Description Format Tests ===${NC}\n"

run_test "TEST-AC-2.4.1.1: Description field exists in $SKILL_FILE" \
    test_description_field_exists

run_test "TEST-AC-2.4.1.2: Description starts with present-tense verb" \
    test_description_starts_with_verb

run_test "TEST-AC-2.4.1.3: Description is under 60 characters" \
    test_description_under_60_chars

run_test "TEST-AC-2.4.1.4: Description matches expected ('$EXPECTED_DESCRIPTION')" \
    test_description_matches_expected

run_test "TEST-AC-2.4.1.5: Description focuses on WHAT (not HOW)" \
    test_description_focuses_on_what

# =============================================================================
# AC2: Prerequisites Field Tests
# =============================================================================
echo -e "\n${BLUE}=== AC2: Prerequisites Field Tests ===${NC}\n"

run_test "TEST-AC-2.4.2.1: Prerequisites field exists in $SKILL_FILE" \
    test_prerequisites_field_exists

run_test "TEST-AC-2.4.2.2: Prerequisites uses em dash for standalone skill" \
    test_prerequisites_uses_em_dash

run_test "TEST-AC-2.4.2.3: Prerequisites follows valid tier notation format" \
    test_prerequisites_valid_format

# =============================================================================
# AC3: Frontmatter Structure Tests
# =============================================================================
echo -e "\n${BLUE}=== AC3: Frontmatter Structure Tests ===${NC}\n"

run_test "TEST-AC-2.4.3.1: Valid YAML frontmatter structure in $SKILL_FILE" \
    test_valid_frontmatter

run_test "TEST-AC-2.4.3.2: Has required fields (description, prerequisites)" \
    test_frontmatter_has_required_fields

run_test "TEST-AC-2.4.3.3: No extra fields (like name:) in frontmatter" \
    test_frontmatter_no_extra_fields

run_test "TEST-AC-2.4.3.4: Description field is properly quoted" \
    test_description_field_quoted

run_test "TEST-AC-2.4.3.5: Prerequisites field is properly quoted" \
    test_prerequisites_field_quoted

run_test "TEST-AC-2.4.3.6: Frontmatter matches exact target structure" \
    test_frontmatter_exact_structure

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
    echo "This is the expected state before implementing Story 2.4."
    echo ""
    echo "To proceed to GREEN phase:"
    echo "1. Remove the 'name:' field from pr-workflow.md frontmatter"
    echo "2. Add 'prerequisites: \"---\"' field"
    echo "3. Update description to: '$EXPECTED_DESCRIPTION'"
    echo "4. Ensure both fields use double quotes"
    echo "5. Re-run this test script to verify all tests pass"
    exit 1
else
    echo -e "\n${GREEN}GREEN PHASE: All tests passing!${NC}"
    echo "Story 2.4 implementation is complete."
    exit 0
fi
