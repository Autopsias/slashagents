#!/bin/bash
# =============================================================================
# EXPANDED Tests for Story 2.4: Standardize Skill Metadata
# =============================================================================
# These tests go beyond ATDD to cover edge cases, error handling, integration
# points, and boundary conditions not covered by the basic acceptance tests.
#
# Test Priority Legend:
# - P0: Critical path tests (must pass)
# - P1: Important scenarios (should pass)
# - P2: Edge cases (good to have)
# - P3: Future-proofing (optional)
# =============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"
SKILL_FILE="pr-workflow.md"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Priority counters
P0_TESTS=0
P1_TESTS=0
P2_TESTS=0
P3_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# =============================================================================
# Test Helper Functions
# =============================================================================

log_test() {
    local priority="$1"
    local test_name="$2"
    echo -e "${YELLOW}[${priority}]${NC} TEST: $test_name"
}

log_pass() {
    echo -e "${GREEN}PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    local reason="$1"
    echo -e "${RED}FAIL:${NC} $reason"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

run_test() {
    local priority="$1"
    local test_name="$2"
    shift 2

    TESTS_RUN=$((TESTS_RUN + 1))

    case "$priority" in
        P0) P0_TESTS=$((P0_TESTS + 1)) ;;
        P1) P1_TESTS=$((P1_TESTS + 1)) ;;
        P2) P2_TESTS=$((P2_TESTS + 1)) ;;
        P3) P3_TESTS=$((P3_TESTS + 1)) ;;
    esac

    log_test "$priority" "$test_name"

    if "$@"; then
        log_pass
        return 0
    else
        log_fail "Test assertion failed"
        return 1
    fi
}

get_frontmatter() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | sed '1d;$d'
}

get_description() {
    local file="$1"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")
    echo "$frontmatter" | grep -E '^description:' | head -1 | sed 's/description:[[:space:]]*//' | tr -d '"'
}

get_prerequisites() {
    local file="$1"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")
    echo "$frontmatter" | grep -E '^prerequisites:' | sed 's/prerequisites:[[:space:]]*//' | tr -d '"'
}

# =============================================================================
# P0: Critical Path Tests
# =============================================================================

# P0-1: Verify frontmatter is valid UTF-8 encoded
test_p0_utf8_encoding() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Check file is valid UTF-8 (em dash U+2014 should be properly encoded)
    if ! file "$file" | grep -q "UTF-8"; then
        echo "  File is not UTF-8 encoded"
        return 1
    fi

    # Verify em dash is correctly encoded (UTF-8: E2 80 94)
    local prereq
    prereq=$(get_prerequisites "$file")

    # Get hex representation of prerequisites value
    local hex_value
    hex_value=$(echo -n "$prereq" | xxd -p | tr -d '\n')

    # Em dash UTF-8 encoding is: e28094
    if [[ "$hex_value" != "e28094" ]]; then
        echo "  Em dash not properly UTF-8 encoded. Got: $hex_value, Expected: e28094"
        return 1
    fi

    return 0
}

# P0-2: Verify description doesn't contain special characters that break YAML
test_p0_description_yaml_safe() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    # Check for YAML special characters that require escaping
    # (not within quotes, but good to verify)
    if echo "$desc" | grep -qE '[:|>{}\[\]&*#?!@%`]'; then
        echo "  Description contains YAML special characters: '$desc'"
        echo "  These should be avoided or properly escaped"
        return 1
    fi

    return 0
}

# P0-3: Verify frontmatter doesn't have trailing whitespace
test_p0_no_trailing_whitespace() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Check first 4 lines (frontmatter) for trailing whitespace
    if head -n 4 "$file" | grep -qE '[[:space:]]$'; then
        echo "  Frontmatter has trailing whitespace"
        return 1
    fi

    return 0
}

# P0-4: Verify frontmatter uses Unix line endings (LF not CRLF)
test_p0_unix_line_endings() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Check for Windows line endings (CRLF)
    if file "$file" | grep -q "CRLF"; then
        echo "  File uses Windows line endings (CRLF), should use Unix (LF)"
        return 1
    fi

    # Also verify by checking for carriage return bytes
    if head -n 4 "$file" | od -An -tx1 | grep -q "0d 0a"; then
        echo "  Frontmatter contains CRLF line endings"
        return 1
    fi

    return 0
}

# P0-5: Verify description is not empty after trimming whitespace
test_p0_description_not_empty() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file" | xargs) # trim whitespace

    if [[ -z "$desc" ]]; then
        echo "  Description is empty after trimming whitespace"
        return 1
    fi

    return 0
}

# =============================================================================
# P1: Important Scenarios
# =============================================================================

# P1-1: Verify description uses title case for first word
test_p1_description_title_case() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    local first_word
    first_word=$(echo "$desc" | awk '{print $1}')

    # First character should be uppercase
    local first_char="${first_word:0:1}"
    if [[ "$first_char" != [A-Z] ]]; then
        echo "  First word of description not capitalized: '$first_word'"
        return 1
    fi

    return 0
}

# P1-2: Verify description doesn't end with period (per style guide)
test_p1_description_no_period() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    if [[ "$desc" =~ \.$ ]]; then
        echo "  Description ends with period (should omit): '$desc'"
        return 1
    fi

    return 0
}

# P1-3: Verify prerequisites field exists even if standalone
test_p1_prerequisites_not_omitted() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Even standalone skills must have prerequisites field
    if ! echo "$frontmatter" | grep -qE '^prerequisites:'; then
        echo "  Prerequisites field missing (required even for standalone)"
        return 1
    fi

    return 0
}

# P1-4: Verify frontmatter comes immediately after opening ---
test_p1_frontmatter_no_blank_lines() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Line 2 should be a field, not blank
    local line2
    line2=$(sed -n '2p' "$file")

    if [[ -z "$line2" ]] || [[ "$line2" =~ ^[[:space:]]*$ ]]; then
        echo "  Blank line after opening --- delimiter"
        return 1
    fi

    return 0
}

# P1-5: Verify description word count is reasonable (2-10 words)
test_p1_description_word_count() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    local word_count
    word_count=$(echo "$desc" | wc -w | xargs)

    if [[ $word_count -lt 2 ]]; then
        echo "  Description too short: $word_count words (min: 2)"
        return 1
    fi

    if [[ $word_count -gt 10 ]]; then
        echo "  Description too long: $word_count words (max: 10)"
        return 1
    fi

    return 0
}

# P1-6: Verify em dash is actual em dash, not double hyphen
test_p1_prerequisites_true_em_dash() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local prereq
    prereq=$(get_prerequisites "$file")

    # Check it's not double hyphen "--" or en dash "–"
    if [[ "$prereq" == "--" ]]; then
        echo "  Prerequisites uses double hyphen '--' instead of em dash '—'"
        return 1
    fi

    if [[ "$prereq" == "–" ]]; then
        echo "  Prerequisites uses en dash '–' instead of em dash '—'"
        return 1
    fi

    return 0
}

# =============================================================================
# P2: Edge Cases
# =============================================================================

# P2-1: Verify description doesn't have double spaces
test_p2_description_no_double_spaces() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    if echo "$desc" | grep -q '  '; then
        echo "  Description contains double spaces: '$desc'"
        return 1
    fi

    return 0
}

# P2-2: Verify field names are lowercase
test_p2_field_names_lowercase() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Extract field names (before colon)
    local fields
    fields=$(echo "$frontmatter" | grep -E '^[a-zA-Z_-]+:' | cut -d: -f1)

    # Check each field is lowercase
    while IFS= read -r field; do
        if [[ "$field" =~ [A-Z] ]]; then
            echo "  Field name not lowercase: '$field'"
            return 1
        fi
    done <<< "$fields"

    return 0
}

# P2-3: Verify frontmatter doesn't have leading whitespace
test_p2_no_leading_whitespace() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Check first 4 lines for leading whitespace
    if head -n 4 "$file" | grep -qE '^[[:space:]]+'; then
        echo "  Frontmatter has leading whitespace"
        return 1
    fi

    return 0
}

# P2-4: Verify quotes around values are double quotes (not single)
test_p2_double_quotes_not_single() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    # Check for single quotes
    if echo "$frontmatter" | grep -qE "^(description|prerequisites):[[:space:]]*'"; then
        echo "  Field uses single quotes instead of double quotes"
        return 1
    fi

    return 0
}

# P2-5: Verify description field is on single line in source
test_p2_description_single_line() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Verify the description field in the file is on a single line
    # by checking that the line immediately after "description:" starts with "prerequisites:"
    local desc_line_num
    desc_line_num=$(grep -n '^description:' "$file" | cut -d: -f1)

    local next_line_num=$((desc_line_num + 1))
    local next_line
    next_line=$(sed -n "${next_line_num}p" "$file")

    if ! echo "$next_line" | grep -qE '^prerequisites:'; then
        echo "  Description field does not appear to be on a single line"
        echo "  Line after description: '$next_line'"
        return 1
    fi

    return 0
}

# P2-6: Verify prerequisites doesn't have extra content after em dash
test_p2_prerequisites_only_em_dash() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local prereq
    prereq=$(get_prerequisites "$file")

    # For standalone, should be EXACTLY em dash, nothing more
    if [[ ${#prereq} -ne 1 ]]; then
        # em dash is 1 character (multi-byte UTF-8, but wc counts as 1)
        local char_count
        char_count=$(echo -n "$prereq" | wc -m | xargs)
        if [[ $char_count -ne 1 ]]; then
            echo "  Prerequisites has extra content beyond em dash: '$prereq'"
            return 1
        fi
    fi

    return 0
}

# P2-7: Verify description doesn't start with article (a, an, the)
test_p2_description_no_leading_article() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    local first_word
    first_word=$(echo "$desc" | awk '{print tolower($1)}')

    if [[ "$first_word" == "a" ]] || [[ "$first_word" == "an" ]] || [[ "$first_word" == "the" ]]; then
        echo "  Description starts with article (should start with verb): '$desc'"
        return 1
    fi

    return 0
}

# =============================================================================
# P3: Future-Proofing
# =============================================================================

# P3-1: Verify file size is reasonable (< 10KB for frontmatter + content)
test_p3_file_size_reasonable() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    local file_size
    file_size=$(wc -c < "$file")

    # 10KB = 10240 bytes
    if [[ $file_size -gt 10240 ]]; then
        echo "  File size unusually large: $file_size bytes (max recommended: 10KB)"
        return 1
    fi

    return 0
}

# P3-2: Verify frontmatter is within first 10 lines of file
test_p3_frontmatter_at_top() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Closing --- should be within first 10 lines
    local closing_line
    closing_line=$(grep -n '^---$' "$file" | sed -n '2p' | cut -d: -f1)

    if [[ $closing_line -gt 10 ]]; then
        echo "  Frontmatter closes at line $closing_line (should be within first 10 lines)"
        return 1
    fi

    return 0
}

# P3-3: Verify description uses hyphens for lists, not commas (style preference)
test_p3_description_hyphen_separators() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    # If description has list, should use hyphens not commas per examples
    # This is a soft check (P3) as both are acceptable
    if echo "$desc" | grep -q ","; then
        # Check if it follows pattern like "create, status, merge"
        if echo "$desc" | grep -qE '[a-z], [a-z]'; then
            # Has comma-separated list - suggest hyphen format
            echo "  INFO: Description uses comma-separated list. Consider hyphen format for consistency."
            # Don't fail, just informational for future reference
        fi
    fi

    return 0
}

# P3-4: Verify description matches verb tense across all tools (consistency check)
test_p3_consistent_verb_tense() {
    local file="$SKILLS_DIR/$SKILL_FILE"
    local desc
    desc=$(get_description "$file")

    local first_word
    first_word=$(echo "$desc" | awk '{print $1}')

    # Check for third-person singular present tense
    # Most verbs in this form end in 's' (Manages, Handles, Fixes, etc.)
    if [[ ! "$first_word" =~ s$ ]] && [[ "$first_word" != "Provides" ]]; then
        echo "  INFO: Verb may not be third-person singular present: '$first_word'"
        echo "  Expected forms like: Manages, Handles, Fixes, Provides"
        # Don't fail, just advisory
    fi

    return 0
}

# P3-5: Verify content exists after frontmatter
test_p3_has_content_after_frontmatter() {
    local file="$SKILLS_DIR/$SKILL_FILE"

    # Count total lines
    local total_lines
    total_lines=$(wc -l < "$file")

    # Frontmatter should end by line 4, content should exist after
    if [[ $total_lines -le 5 ]]; then
        echo "  File has no substantial content after frontmatter"
        return 1
    fi

    return 0
}

# =============================================================================
# Main Test Execution
# =============================================================================

echo "============================================================================="
echo "EXPANDED Tests for Story 2.4: Standardize Skill Metadata"
echo "============================================================================="
echo "These tests cover edge cases, error handling, and boundary conditions"
echo "beyond the basic ATDD acceptance criteria tests."
echo ""
echo "Test Priority Legend:"
echo "  P0: Critical path tests (must pass)"
echo "  P1: Important scenarios (should pass)"
echo "  P2: Edge cases (good to have)"
echo "  P3: Future-proofing (optional)"
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
# P0: Critical Path Tests
# =============================================================================
echo -e "\n${MAGENTA}=== P0: Critical Path Tests ===${NC}\n"

run_test "P0" "UTF-8 encoding with proper em dash bytes" \
    test_p0_utf8_encoding

run_test "P0" "Description is YAML-safe (no special chars)" \
    test_p0_description_yaml_safe

run_test "P0" "No trailing whitespace in frontmatter" \
    test_p0_no_trailing_whitespace

run_test "P0" "Unix line endings (LF not CRLF)" \
    test_p0_unix_line_endings

run_test "P0" "Description not empty after trimming" \
    test_p0_description_not_empty

# =============================================================================
# P1: Important Scenarios
# =============================================================================
echo -e "\n${MAGENTA}=== P1: Important Scenarios ===${NC}\n"

run_test "P1" "Description uses title case for first word" \
    test_p1_description_title_case

run_test "P1" "Description doesn't end with period" \
    test_p1_description_no_period

run_test "P1" "Prerequisites field not omitted (required)" \
    test_p1_prerequisites_not_omitted

run_test "P1" "No blank lines after opening delimiter" \
    test_p1_frontmatter_no_blank_lines

run_test "P1" "Description word count is reasonable (2-10)" \
    test_p1_description_word_count

run_test "P1" "Prerequisites uses true em dash (not --)" \
    test_p1_prerequisites_true_em_dash

# =============================================================================
# P2: Edge Cases
# =============================================================================
echo -e "\n${MAGENTA}=== P2: Edge Cases ===${NC}\n"

run_test "P2" "Description has no double spaces" \
    test_p2_description_no_double_spaces

run_test "P2" "Field names are lowercase" \
    test_p2_field_names_lowercase

run_test "P2" "No leading whitespace in frontmatter" \
    test_p2_no_leading_whitespace

run_test "P2" "Values use double quotes (not single)" \
    test_p2_double_quotes_not_single

run_test "P2" "Description is single-line (no newlines)" \
    test_p2_description_single_line

run_test "P2" "Prerequisites only em dash (no extra content)" \
    test_p2_prerequisites_only_em_dash

run_test "P2" "Description doesn't start with article" \
    test_p2_description_no_leading_article

# =============================================================================
# P3: Future-Proofing
# =============================================================================
echo -e "\n${MAGENTA}=== P3: Future-Proofing ===${NC}\n"

run_test "P3" "File size is reasonable (< 10KB)" \
    test_p3_file_size_reasonable

run_test "P3" "Frontmatter is at top of file (< 10 lines)" \
    test_p3_frontmatter_at_top

run_test "P3" "Description uses consistent separator style" \
    test_p3_description_hyphen_separators

run_test "P3" "Verb tense is consistent (3rd person singular)" \
    test_p3_consistent_verb_tense

run_test "P3" "File has content after frontmatter" \
    test_p3_has_content_after_frontmatter

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
echo ""
echo "By Priority:"
echo -e "  P0 (Critical):      ${P0_TESTS} tests"
echo -e "  P1 (Important):     ${P1_TESTS} tests"
echo -e "  P2 (Edge Cases):    ${P2_TESTS} tests"
echo -e "  P3 (Future-proof):  ${P3_TESTS} tests"
echo "============================================================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${RED}FAILURE: $TESTS_FAILED test(s) failed.${NC}"
    exit 1
else
    echo -e "\n${GREEN}SUCCESS: All expanded tests passing!${NC}"
    exit 0
fi
