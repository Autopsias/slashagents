#!/bin/bash
# =============================================================================
# ATDD Tests for Story 1.2: Package Slash Commands
# =============================================================================
# These tests verify that all 11 slash commands are properly packaged
# in the commands/ directory with correct naming and valid content.
#
# Test Phase: RED (tests should fail until implementation is complete)
# Story: 1-2-package-slash-commands
# =============================================================================

# Note: NOT using set -e because we want to continue running tests even if some fail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMANDS_DIR="$PROJECT_ROOT/commands"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Expected command files (exactly 11)
EXPECTED_COMMANDS=(
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

run_test() {
    local test_name="$1"
    local test_func="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "$test_name"

    if $test_func; then
        log_pass "$test_name"
    else
        log_fail "$test_name"
    fi
    # Always return 0 to allow script to continue
    return 0
}

# =============================================================================
# AC1: All Commands Present - Tests
# =============================================================================

test_ac1_commands_directory_exists() {
    # Test: commands/ directory exists at project root
    if [[ -d "$COMMANDS_DIR" ]]; then
        return 0
    else
        echo "  Expected: $COMMANDS_DIR to exist"
        return 1
    fi
}

test_ac1_exactly_11_commands() {
    # Test: Exactly 11 command files exist
    local count=$(ls -1 "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -eq 11 ]]; then
        return 0
    else
        echo "  Expected: 11 command files, Found: $count"
        return 1
    fi
}

test_ac1_pr_md_exists() {
    if [[ -f "$COMMANDS_DIR/pr.md" ]]; then
        return 0
    else
        echo "  Missing: commands/pr.md"
        return 1
    fi
}

test_ac1_ci_orchestrate_md_exists() {
    if [[ -f "$COMMANDS_DIR/ci-orchestrate.md" ]]; then
        return 0
    else
        echo "  Missing: commands/ci-orchestrate.md"
        return 1
    fi
}

test_ac1_test_orchestrate_md_exists() {
    if [[ -f "$COMMANDS_DIR/test-orchestrate.md" ]]; then
        return 0
    else
        echo "  Missing: commands/test-orchestrate.md"
        return 1
    fi
}

test_ac1_commit_orchestrate_md_exists() {
    if [[ -f "$COMMANDS_DIR/commit-orchestrate.md" ]]; then
        return 0
    else
        echo "  Missing: commands/commit-orchestrate.md"
        return 1
    fi
}

test_ac1_parallelize_md_exists() {
    if [[ -f "$COMMANDS_DIR/parallelize.md" ]]; then
        return 0
    else
        echo "  Missing: commands/parallelize.md"
        return 1
    fi
}

test_ac1_parallelize_agents_md_exists() {
    if [[ -f "$COMMANDS_DIR/parallelize-agents.md" ]]; then
        return 0
    else
        echo "  Missing: commands/parallelize-agents.md"
        return 1
    fi
}

test_ac1_epic_dev_md_exists() {
    if [[ -f "$COMMANDS_DIR/epic-dev.md" ]]; then
        return 0
    else
        echo "  Missing: commands/epic-dev.md"
        return 1
    fi
}

test_ac1_epic_dev_full_md_exists() {
    if [[ -f "$COMMANDS_DIR/epic-dev-full.md" ]]; then
        return 0
    else
        echo "  Missing: commands/epic-dev-full.md"
        return 1
    fi
}

test_ac1_epic_dev_init_md_exists() {
    if [[ -f "$COMMANDS_DIR/epic-dev-init.md" ]]; then
        return 0
    else
        echo "  Missing: commands/epic-dev-init.md"
        return 1
    fi
}

test_ac1_nextsession_md_exists() {
    if [[ -f "$COMMANDS_DIR/nextsession.md" ]]; then
        return 0
    else
        echo "  Missing: commands/nextsession.md"
        return 1
    fi
}

test_ac1_usertestgates_md_exists() {
    if [[ -f "$COMMANDS_DIR/usertestgates.md" ]]; then
        return 0
    else
        echo "  Missing: commands/usertestgates.md"
        return 1
    fi
}

test_ac1_no_extra_files() {
    # Test: No unexpected files in commands/
    local unexpected_count=0
    for file in "$COMMANDS_DIR"/*.md; do
        local basename=$(basename "$file")
        local found=false
        for expected in "${EXPECTED_COMMANDS[@]}"; do
            if [[ "$basename" == "$expected" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == "false" ]]; then
            echo "  Unexpected file: $basename"
            ((unexpected_count++))
        fi
    done

    if [[ $unexpected_count -eq 0 ]]; then
        return 0
    else
        echo "  Found $unexpected_count unexpected file(s)"
        return 1
    fi
}

# =============================================================================
# AC2: Kebab-Case Naming - Tests
# =============================================================================

test_ac2_no_underscores_in_filenames() {
    # Test: No underscores in any filename
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local basename=$(basename "$file")
        if [[ "$basename" == *"_"* ]]; then
            echo "  Violation: $basename contains underscore"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac2_all_lowercase() {
    # Test: All filenames are lowercase
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local basename=$(basename "$file")
        local lowercase=$(echo "$basename" | tr '[:upper:]' '[:lower:]')
        if [[ "$basename" != "$lowercase" ]]; then
            echo "  Violation: $basename is not lowercase (should be: $lowercase)"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac2_valid_kebab_case_pattern() {
    # Test: All filenames match kebab-case pattern (lowercase letters, numbers, hyphens only)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local basename=$(basename "$file" .md)
        # Pattern: lowercase letters, numbers, and hyphens only
        if ! [[ "$basename" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
            echo "  Violation: $basename does not match kebab-case pattern"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac2_no_camelcase() {
    # Test: No camelCase in filenames
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local basename=$(basename "$file" .md)
        # Check for lowercase followed by uppercase (camelCase indicator)
        if [[ "$basename" =~ [a-z][A-Z] ]]; then
            echo "  Violation: $basename appears to be camelCase"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# AC3: File Content Preserved - Tests
# =============================================================================

test_ac3_all_files_are_valid_markdown() {
    # Test: All files have .md extension and are non-empty text files
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if [[ ! -s "$file" ]]; then
            echo "  Violation: $file is empty"
            ((violations++))
        fi
        # Check if file is text (not binary)
        if file "$file" | grep -q "text"; then
            : # OK
        else
            echo "  Violation: $file is not a text file"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac3_files_contain_markdown_content() {
    # Test: Files contain markdown-like content (headers, lists, etc.)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Check for at least one markdown header (#)
        if ! grep -q "^#" "$file"; then
            echo "  Violation: $(basename "$file") has no markdown headers"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac3_no_hardcoded_paths() {
    # Test: No hardcoded user-specific paths in files
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Check for common hardcoded path patterns (exclude documentation examples)
        if grep -E "/Users/[a-zA-Z]+/" "$file" | grep -v "example" | grep -v "#" > /dev/null 2>&1; then
            echo "  Violation: $(basename "$file") may contain hardcoded user paths"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac3_utf8_encoding() {
    # Test: All files are UTF-8 encoded
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local encoding=$(file -b --mime-encoding "$file")
        if [[ "$encoding" != "utf-8" && "$encoding" != "us-ascii" ]]; then
            echo "  Violation: $(basename "$file") encoding is $encoding (expected utf-8)"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac3_lf_line_endings() {
    # Test: All files use LF line endings (not CRLF)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if file "$file" | grep -q "CRLF"; then
            echo "  Violation: $(basename "$file") uses CRLF line endings"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_ac3_self_contained_no_imports() {
    # Test: Files are self-contained (no external file imports at markdown level)
    # Note: We skip this test because command files may contain example code blocks
    # with import statements - this is expected and not a violation.
    # The key requirement is that markdown files don't have frontmatter imports
    # or external markdown include directives.
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Check for markdown-level imports (like Hugo includes or similar)
        # Skip Python/JS imports inside code blocks - those are examples
        if grep -E "^\{\{<\s*(import|include)" "$file" > /dev/null 2>&1; then
            echo "  Violation: $(basename "$file") has markdown-level imports"
            violations=$((violations + 1))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Cross-Reference Tests (AC3 extended)
# =============================================================================

test_ac3_agent_references_valid() {
    # Test: Any agent references in commands point to valid agent names
    # This test looks for references to this repository's agents/ directory
    # Pattern: agents/agent-name.md (kebab-case agent files in this repo)
    local known_agents=(
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

    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Only look for explicit agent file references like "agents/unit-test-fixer.md"
        # or "agents/unit-test-fixer" - kebab-case names that match our agent naming
        # Skip paths like "src/agents/" which are example project paths
        while IFS= read -r line; do
            # Match patterns like: agents/kebab-name.md or agents/kebab-name (word boundary)
            # Exclude src/agents, app/agents, etc (code example paths)
            if [[ "$line" =~ [^/]agents/([a-z]+(-[a-z]+)+)(\.md)? ]] || \
               [[ "$line" =~ ^agents/([a-z]+(-[a-z]+)+)(\.md)? ]]; then
                local ref="${BASH_REMATCH[1]}"
                ref="${ref%.md}"  # Remove .md if present
                local found=false
                for agent in "${known_agents[@]}"; do
                    if [[ "$ref" == "$agent" ]]; then
                        found=true
                        break
                    fi
                done
                if [[ "$found" == "false" ]]; then
                    echo "  Violation: $(basename "$file") references unknown agent: $ref"
                    violations=$((violations + 1))
                fi
            fi
        done < "$file"
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# EDGE CASE TESTS - File Content Validation
# =============================================================================

test_edge_case_file_not_empty() {
    # [P0] Test: No command files are empty (0 bytes)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [[ "$size" -eq 0 ]]; then
            echo "  Violation: $(basename "$file") is empty (0 bytes)"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_edge_case_file_size_reasonable() {
    # [P2] Test: Files are not excessively large (>100KB)
    local violations=0
    local max_size=102400  # 100KB
    for file in "$COMMANDS_DIR"/*.md; do
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [[ "$size" -gt "$max_size" ]]; then
            echo "  Warning: $(basename "$file") is large ($(($size / 1024))KB, max 100KB)"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_edge_case_no_binary_content() {
    # [P1] Test: Files contain only text (no binary content)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if ! file "$file" | grep -qE "text|ASCII|UTF-8|empty"; then
            echo "  Violation: $(basename "$file") may contain binary content"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_edge_case_no_trailing_whitespace() {
    # [P3] Test: Files don't have excessive trailing whitespace
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Check for lines with trailing spaces (more than 2, since markdown allows 2 for line break)
        if grep -n "   \+$" "$file" > /dev/null 2>&1; then
            echo "  Warning: $(basename "$file") has excessive trailing whitespace"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_edge_case_no_tabs() {
    # [P3] Test: Files use spaces, not tabs
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if grep -q $'\t' "$file"; then
            echo "  Warning: $(basename "$file") contains tab characters"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# METADATA STRUCTURE TESTS
# =============================================================================

test_metadata_frontmatter_present() {
    # [P0] Test: All files have YAML frontmatter (---...---)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" != "---" ]]; then
            echo "  Violation: $(basename "$file") missing YAML frontmatter (doesn't start with ---)"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_metadata_description_present() {
    # [P0] Test: All files have a 'description' field in frontmatter
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if ! grep -q "^description:" "$file"; then
            echo "  Violation: $(basename "$file") missing 'description' field"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_metadata_description_format() {
    # [P1] Test: Description starts with present-tense verb and is under 120 chars
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local desc=$(grep "^description:" "$file" | head -1 | sed 's/description: *"//' | sed 's/"$//')
        if [[ -n "$desc" ]]; then
            local len=${#desc}
            if [[ $len -gt 120 ]]; then
                echo "  Violation: $(basename "$file") description too long ($len chars, max 120)"
                ((violations++))
            fi
            # Check if description starts with uppercase letter (present-tense verb convention)
            if ! [[ "$desc" =~ ^[A-Z] ]]; then
                echo "  Warning: $(basename "$file") description should start with capital letter"
                ((violations++))
            fi
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_metadata_argument_hint_present() {
    # [P2] Test: Files have 'argument-hint' field in frontmatter
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if ! grep -q "^argument-hint:" "$file"; then
            echo "  Warning: $(basename "$file") missing 'argument-hint' field"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_metadata_allowed_tools_valid() {
    # [P2] Test: If allowed-tools exists, it's valid YAML array format
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if grep -q "^allowed-tools:" "$file"; then
            # Check if it's a valid array format: allowed-tools: ["Tool1", "Tool2"]
            local tools_line=$(grep "^allowed-tools:" "$file")
            if ! [[ "$tools_line" =~ allowed-tools:\ \[.*\] ]]; then
                echo "  Warning: $(basename "$file") allowed-tools not in array format"
                ((violations++))
            fi
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# CROSS-REFERENCE VALIDATION TESTS
# =============================================================================

test_cross_ref_slash_commands_exist() {
    # [P1] Test: Any references to other slash commands exist
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Look for /command-name patterns
        while IFS= read -r match; do
            # Extract command name (remove leading /)
            local cmd_name="${match#/}"
            local expected_file="$COMMANDS_DIR/${cmd_name}.md"
            if [[ ! -f "$expected_file" ]]; then
                echo "  Violation: $(basename "$file") references non-existent command: /$cmd_name"
                ((violations++))
            fi
        done < <(grep -oE "/[a-z]+(-[a-z]+)+" "$file" | sort -u)
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_cross_ref_no_broken_markdown_links() {
    # [P2] Test: No obviously broken markdown links (empty URLs or missing closing bracket)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Check for markdown links with empty URLs: [text]()
        if grep -E "\[.+\]\(\)" "$file" > /dev/null 2>&1; then
            echo "  Violation: $(basename "$file") has markdown link(s) with empty URL"
            ((violations++))
        fi
        # Check for unclosed markdown links: [text] not followed by (
        if grep -E "\[.+\][^(\[]" "$file" | grep -v "^#" > /dev/null 2>&1; then
            echo "  Warning: $(basename "$file") may have unclosed markdown link(s)"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# DOCUMENTATION QUALITY TESTS
# =============================================================================

test_quality_has_usage_examples() {
    # [P3] Test: Files contain usage examples or argument descriptions
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        # Check if file has common documentation patterns
        if ! grep -qiE "(example|usage|argument|parameter|option)" "$file"; then
            echo "  Warning: $(basename "$file") may lack usage examples/documentation"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_quality_no_todo_markers() {
    # [P2] Test: No TODO/FIXME/HACK markers in production files
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        if grep -iE "TODO|FIXME|HACK|XXX" "$file" > /dev/null 2>&1; then
            echo "  Warning: $(basename "$file") contains TODO/FIXME markers"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_quality_consistent_heading_levels() {
    # [P3] Test: Markdown headings follow logical hierarchy (no skipped levels)
    local violations=0
    for file in "$COMMANDS_DIR"/*.md; do
        local prev_level=1
        while IFS= read -r line; do
            if [[ "$line" =~ ^(#+)\ .+ ]]; then
                local level=${#BASH_REMATCH[1]}
                # Allow only +1 jump in heading levels
                if [[ $level -gt $((prev_level + 1)) ]]; then
                    echo "  Warning: $(basename "$file") has inconsistent heading levels (jumped from H$prev_level to H$level)"
                    ((violations++))
                    break
                fi
                prev_level=$level
            fi
        done < "$file"
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Main Test Runner
# =============================================================================

echo "============================================================================="
echo "ATDD Tests for Story 1.2: Package Slash Commands"
echo "============================================================================="
echo "Project Root: $PROJECT_ROOT"
echo "Commands Dir: $COMMANDS_DIR"
echo "============================================================================="
echo ""

# AC1: All Commands Present
echo "--- AC1: All Commands Present ---"
run_test "AC1.1 - commands/ directory exists" test_ac1_commands_directory_exists
run_test "AC1.2 - Exactly 11 command files exist" test_ac1_exactly_11_commands
run_test "AC1.3 - pr.md exists" test_ac1_pr_md_exists
run_test "AC1.4 - ci-orchestrate.md exists" test_ac1_ci_orchestrate_md_exists
run_test "AC1.5 - test-orchestrate.md exists" test_ac1_test_orchestrate_md_exists
run_test "AC1.6 - commit-orchestrate.md exists" test_ac1_commit_orchestrate_md_exists
run_test "AC1.7 - parallelize.md exists" test_ac1_parallelize_md_exists
run_test "AC1.8 - parallelize-agents.md exists" test_ac1_parallelize_agents_md_exists
run_test "AC1.9 - epic-dev.md exists" test_ac1_epic_dev_md_exists
run_test "AC1.10 - epic-dev-full.md exists" test_ac1_epic_dev_full_md_exists
run_test "AC1.11 - epic-dev-init.md exists" test_ac1_epic_dev_init_md_exists
run_test "AC1.12 - nextsession.md exists" test_ac1_nextsession_md_exists
run_test "AC1.13 - usertestgates.md exists" test_ac1_usertestgates_md_exists
run_test "AC1.14 - No unexpected files in commands/" test_ac1_no_extra_files
echo ""

# AC2: Kebab-Case Naming
echo "--- AC2: Kebab-Case Naming ---"
run_test "AC2.1 - No underscores in filenames" test_ac2_no_underscores_in_filenames
run_test "AC2.2 - All filenames are lowercase" test_ac2_all_lowercase
run_test "AC2.3 - Valid kebab-case pattern" test_ac2_valid_kebab_case_pattern
run_test "AC2.4 - No camelCase in filenames" test_ac2_no_camelcase
echo ""

# AC3: File Content Preserved
echo "--- AC3: File Content Preserved ---"
run_test "AC3.1 - All files are valid markdown" test_ac3_all_files_are_valid_markdown
run_test "AC3.2 - Files contain markdown content" test_ac3_files_contain_markdown_content
run_test "AC3.3 - No hardcoded user paths" test_ac3_no_hardcoded_paths
run_test "AC3.4 - UTF-8 encoding" test_ac3_utf8_encoding
run_test "AC3.5 - LF line endings" test_ac3_lf_line_endings
run_test "AC3.6 - Self-contained (no imports)" test_ac3_self_contained_no_imports
run_test "AC3.7 - Agent references are valid" test_ac3_agent_references_valid
echo ""

# Edge Case Tests - File Content
echo "--- EDGE CASES: File Content Validation ---"
run_test "[P0] EDGE1.1 - Files are not empty (0 bytes)" test_edge_case_file_not_empty
run_test "[P2] EDGE1.2 - Files are reasonable size (<100KB)" test_edge_case_file_size_reasonable
run_test "[P1] EDGE1.3 - No binary content in files" test_edge_case_no_binary_content
run_test "[P3] EDGE1.4 - No excessive trailing whitespace" test_edge_case_no_trailing_whitespace
run_test "[P3] EDGE1.5 - Files use spaces not tabs" test_edge_case_no_tabs
echo ""

# Metadata Structure Tests
echo "--- METADATA: Structure Validation ---"
run_test "[P0] META2.1 - YAML frontmatter present" test_metadata_frontmatter_present
run_test "[P0] META2.2 - Description field present" test_metadata_description_present
run_test "[P1] META2.3 - Description format valid" test_metadata_description_format
run_test "[P2] META2.4 - Argument-hint field present" test_metadata_argument_hint_present
run_test "[P2] META2.5 - Allowed-tools valid YAML array" test_metadata_allowed_tools_valid
echo ""

# Cross-Reference Tests
echo "--- CROSS-REF: Reference Validation ---"
run_test "[P1] XREF3.1 - Referenced slash commands exist" test_cross_ref_slash_commands_exist
run_test "[P2] XREF3.2 - No broken markdown links" test_cross_ref_no_broken_markdown_links
echo ""

# Documentation Quality Tests
echo "--- QUALITY: Documentation Standards ---"
run_test "[P3] QUAL4.1 - Has usage examples/docs" test_quality_has_usage_examples
run_test "[P2] QUAL4.2 - No TODO/FIXME markers" test_quality_no_todo_markers
run_test "[P3] QUAL4.3 - Consistent heading hierarchy" test_quality_consistent_heading_levels
echo ""

# Summary
echo "============================================================================="
echo "TEST SUMMARY"
echo "============================================================================="
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "============================================================================="

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}ALL TESTS PASSED - Story 1.2 requirements met${NC}"
    exit 0
else
    echo -e "${RED}SOME TESTS FAILED - Story 1.2 implementation incomplete${NC}"
    exit 1
fi
