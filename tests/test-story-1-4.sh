#!/bin/bash
# =============================================================================
# ATDD Tests for Story 1.4: Package Skill
# =============================================================================
# These tests verify that the skill file is properly packaged
# in the skills/ directory with correct naming and valid content.
#
# Test Phase: RED (tests should fail until implementation is complete)
# Story: 1-4-package-skill
# =============================================================================

# Note: NOT using set -e because we want to continue running tests even if some fail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Expected skill files (exactly 1)
EXPECTED_SKILLS=(
    "pr-workflow.md"
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
# AC1: Skill Present - Tests
# =============================================================================

test_ac1_skills_directory_exists() {
    # Test: skills/ directory exists at project root
    if [[ -d "$SKILLS_DIR" ]]; then
        return 0
    else
        echo "  Expected: $SKILLS_DIR to exist"
        return 1
    fi
}

test_ac1_exactly_1_skill() {
    # Test: Exactly 1 skill file exists
    local count=$(ls -1 "$SKILLS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -eq 1 ]]; then
        return 0
    else
        echo "  Expected: 1 skill file, Found: $count"
        return 1
    fi
}

test_ac1_pr_workflow_md_exists() {
    if [[ -f "$SKILLS_DIR/pr-workflow.md" ]]; then
        return 0
    else
        echo "  Missing: skills/pr-workflow.md"
        return 1
    fi
}

test_ac1_no_extra_files() {
    # Test: No unexpected files in skills/
    local unexpected_count=0
    for file in "$SKILLS_DIR"/*.md; do
        local basename=$(basename "$file")
        local found=false
        for expected in "${EXPECTED_SKILLS[@]}"; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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

test_ac2_follows_workflow_pattern() {
    # Test: Skill filename follows {workflow}-workflow.md pattern
    # From architecture.md: Skills pattern: {workflow}-workflow.md
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        local basename=$(basename "$file" .md)
        # Pattern: ends with -workflow
        if ! [[ "$basename" =~ -workflow$ ]]; then
            echo "  Violation: $basename does not follow {name}-workflow pattern"
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check for markdown-level imports (like Hugo includes or similar)
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
# EDGE CASE TESTS - File Content Validation
# =============================================================================

test_edge_case_file_not_empty() {
    # [P0] Test: No skill files are empty (0 bytes)
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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
# SKILL-SPECIFIC CONTENT TESTS
# =============================================================================

test_skill_has_skill_definition() {
    # [P0] Test: Skill file contains skill definition indicators
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check for skill-like content (header with skill name or skill instructions)
        if ! grep -qiE "(skill|workflow|capabilities)" "$file"; then
            echo "  Violation: $(basename "$file") may not contain valid skill definition"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_skill_has_capabilities() {
    # [P1] Test: Skill file contains capabilities or features section
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check for capabilities content
        if ! grep -qiE "(capabilities|features|can do|abilities)" "$file"; then
            echo "  Warning: $(basename "$file") may lack capabilities section"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_skill_workflow_examples() {
    # [P2] Test: Skill file contains workflow examples or triggers
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check for example content
        if ! grep -qiE "(example|trigger|how it works)" "$file"; then
            echo "  Warning: $(basename "$file") may lack workflow examples"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_skill_no_code_blocks() {
    # [P3] Test: Skills should be guidance, not executable code
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check for code fence blocks (``` or ~~~)
        local code_blocks=$(grep -cE '^(```|~~~)' "$file" 2>/dev/null || echo "0")
        code_blocks=$(echo "$code_blocks" | tr -d '\n' | tr -d ' ')
        # More than 10 code blocks might indicate too much code vs guidance
        if [[ "$code_blocks" =~ ^[0-9]+$ ]] && [[ "$code_blocks" -gt 10 ]]; then
            echo "  Warning: $(basename "$file") has many code blocks ($code_blocks), should be guidance-focused"
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
    for file in "$SKILLS_DIR"/*.md; do
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

test_metadata_has_name_field() {
    # [P0] Test: All files have a 'name' field in frontmatter
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        if ! grep -q "^name:" "$file"; then
            echo "  Violation: $(basename "$file") missing 'name' field"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_metadata_has_description_field() {
    # [P0] Test: All files have a 'description' field in frontmatter
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
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

test_metadata_name_matches_filename() {
    # [P1] Test: YAML 'name' field matches filename (without .md)
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        local basename=$(basename "$file" .md)
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            local yaml_name=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^name:" | sed 's/^name:[[:space:]]*//')
            if [[ "$yaml_name" != "$basename" ]]; then
                echo "  Violation: $(basename "$file") name field '$yaml_name' doesn't match filename '$basename'"
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

test_metadata_has_title_header() {
    # [P0] Test: All skill files have a title (H1 header)
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check for H1 header
        if ! grep -qE "^# " "$file"; then
            echo "  Violation: $(basename "$file") missing H1 title header"
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
# PREREQUISITES FIELD VALIDATION TESTS (New Requirement)
# =============================================================================

test_prereq_field_exists() {
    # [P0] Test: All skill files have a 'prerequisites' field in frontmatter
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        if ! grep -q "^prerequisites:" "$file"; then
            echo "  Violation: $(basename "$file") missing 'prerequisites' field"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_prereq_valid_values() {
    # [P0] Test: Prerequisites field contains valid values (—, MCP name, BMAD framework, or text)
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        local prereq=$(grep "^prerequisites:" "$file" | sed 's/^prerequisites:[[:space:]]*//')
        if [[ -n "$prereq" ]]; then
            # Valid patterns: — (standalone), "xyz MCP", "BMAD framework", or descriptive text
            if [[ "$prereq" != "—" ]] && \
               ! [[ "$prereq" =~ MCP$ ]] && \
               [[ "$prereq" != "BMAD framework" ]] && \
               [[ ${#prereq} -lt 3 ]]; then
                echo "  Violation: $(basename "$file") has invalid prerequisites value: '$prereq'"
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

test_prereq_not_empty() {
    # [P1] Test: Prerequisites field is not empty or just whitespace
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        local prereq=$(grep "^prerequisites:" "$file" | sed 's/^prerequisites:[[:space:]]*//')
        if [[ -z "$prereq" ]] || [[ "$prereq" =~ ^[[:space:]]*$ ]]; then
            echo "  Violation: $(basename "$file") has empty prerequisites field"
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
# CROSS-REFERENCE VALIDATION TESTS
# =============================================================================

test_cross_ref_agent_references_valid() {
    # [P1] Test: Any agent references in skill point to valid agent names
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
    for file in "$SKILLS_DIR"/*.md; do
        # Look for explicit agent references
        while IFS= read -r line; do
            if [[ "$line" =~ agents/([a-z]+(-[a-z]+)+)(\.md)? ]] || \
               [[ "$line" =~ ([a-z]+-[a-z]+-[a-z]+)\ (agent|subagent) ]]; then
                local ref="${BASH_REMATCH[1]}"
                ref="${ref%.md}"  # Remove .md if present
                local found=false
                for agent in "${known_agents[@]}"; do
                    if [[ "$ref" == "$agent" ]]; then
                        found=true
                        break
                    fi
                done
                if [[ "$found" == "false" ]] && [[ -n "$ref" ]]; then
                    echo "  Warning: $(basename "$file") may reference unknown agent: $ref"
                    ((violations++))
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

test_cross_ref_command_references_valid() {
    # [P1] Test: Any command references in skill point to valid command names
    local known_commands=(
        "pr"
        "ci-orchestrate"
        "test-orchestrate"
        "commit-orchestrate"
        "parallelize"
        "parallelize-agents"
        "epic-dev"
        "epic-dev-full"
        "epic-dev-init"
        "nextsession"
        "usertestgates"
    )

    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Look for command references (e.g., ci-orchestrate, test-orchestrate)
        while IFS= read -r line; do
            # Match patterns like: commands/xyz.md or "xyz" (command), /xyz, or mentions of known commands
            if [[ "$line" =~ commands/([a-z]+(-[a-z]+)*)(\.md)? ]] || \
               [[ "$line" =~ /([a-z]+(-[a-z]+)+)[[:space:]] ]]; then
                local ref="${BASH_REMATCH[1]}"
                ref="${ref%.md}"  # Remove .md if present
                local found=false
                for cmd in "${known_commands[@]}"; do
                    if [[ "$ref" == "$cmd" ]]; then
                        found=true
                        break
                    fi
                done
                if [[ "$found" == "false" ]] && [[ -n "$ref" ]] && [[ "$ref" =~ - ]]; then
                    echo "  Warning: $(basename "$file") may reference unknown command: $ref"
                    ((violations++))
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

test_cross_ref_pr_workflow_manager_exists() {
    # [P0] Test: pr-workflow skill references pr-workflow-manager agent correctly
    local violations=0
    local file="$SKILLS_DIR/pr-workflow.md"

    if [[ -f "$file" ]]; then
        # Check that it mentions pr-workflow-manager
        if ! grep -q "pr-workflow-manager" "$file"; then
            echo "  Violation: pr-workflow.md should reference pr-workflow-manager agent"
            ((violations++))
        fi
    fi

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_cross_ref_delegation_section_exists() {
    # [P2] Test: pr-workflow skill has delegation section explaining agent usage
    local violations=0
    local file="$SKILLS_DIR/pr-workflow.md"

    if [[ -f "$file" ]]; then
        # Check for delegation section
        if ! grep -qiE "^##? Delegation" "$file"; then
            echo "  Warning: pr-workflow.md should have Delegation section"
            ((violations++))
        fi
    fi

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
    # [P3] Test: Files contain usage examples or trigger descriptions
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check if file has common documentation patterns
        if ! grep -qiE "(example|usage|trigger|when|how)" "$file"; then
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
    for file in "$SKILLS_DIR"/*.md; do
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
    for file in "$SKILLS_DIR"/*.md; do
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

test_quality_no_broken_markdown_links() {
    # [P2] Test: No obviously broken markdown links (empty URLs or missing closing bracket)
    local violations=0
    for file in "$SKILLS_DIR"/*.md; do
        # Check for markdown links with empty URLs: [text]()
        if grep -E "\[.+\]\(\)" "$file" > /dev/null 2>&1; then
            echo "  Violation: $(basename "$file") has markdown link(s) with empty URL"
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
# Main Test Runner
# =============================================================================

echo "============================================================================="
echo "ATDD Tests for Story 1.4: Package Skill"
echo "============================================================================="
echo "Project Root: $PROJECT_ROOT"
echo "Skills Dir:   $SKILLS_DIR"
echo "============================================================================="
echo ""

# AC1: Skill Present
echo "--- AC1: Skill Present ---"
run_test "AC1.1 - skills/ directory exists" test_ac1_skills_directory_exists
run_test "AC1.2 - Exactly 1 skill file exists" test_ac1_exactly_1_skill
run_test "AC1.3 - pr-workflow.md exists" test_ac1_pr_workflow_md_exists
run_test "AC1.4 - No unexpected files in skills/" test_ac1_no_extra_files
echo ""

# AC2: Kebab-Case Naming
echo "--- AC2: Kebab-Case Naming ---"
run_test "AC2.1 - No underscores in filenames" test_ac2_no_underscores_in_filenames
run_test "AC2.2 - All filenames are lowercase" test_ac2_all_lowercase
run_test "AC2.3 - Valid kebab-case pattern" test_ac2_valid_kebab_case_pattern
run_test "AC2.4 - No camelCase in filenames" test_ac2_no_camelcase
run_test "AC2.5 - Follows {name}-workflow pattern" test_ac2_follows_workflow_pattern
echo ""

# AC3: File Content Preserved
echo "--- AC3: File Content Preserved ---"
run_test "AC3.1 - All files are valid markdown" test_ac3_all_files_are_valid_markdown
run_test "AC3.2 - Files contain markdown content" test_ac3_files_contain_markdown_content
run_test "AC3.3 - No hardcoded user paths" test_ac3_no_hardcoded_paths
run_test "AC3.4 - UTF-8 encoding" test_ac3_utf8_encoding
run_test "AC3.5 - LF line endings" test_ac3_lf_line_endings
run_test "AC3.6 - Self-contained (no imports)" test_ac3_self_contained_no_imports
echo ""

# Edge Case Tests - File Content
echo "--- EDGE CASES: File Content Validation ---"
run_test "[P0] EDGE1.1 - Files are not empty (0 bytes)" test_edge_case_file_not_empty
run_test "[P2] EDGE1.2 - Files are reasonable size (<100KB)" test_edge_case_file_size_reasonable
run_test "[P1] EDGE1.3 - No binary content in files" test_edge_case_no_binary_content
run_test "[P3] EDGE1.4 - No excessive trailing whitespace" test_edge_case_no_trailing_whitespace
run_test "[P3] EDGE1.5 - Files use spaces not tabs" test_edge_case_no_tabs
echo ""

# Skill-Specific Tests
echo "--- SKILL: Content Validation ---"
run_test "[P0] SKILL2.1 - Skill file has skill definition" test_skill_has_skill_definition
run_test "[P1] SKILL2.2 - Skill file has capabilities section" test_skill_has_capabilities
run_test "[P2] SKILL2.3 - Skill has workflow examples" test_skill_workflow_examples
run_test "[P3] SKILL2.4 - Skill is guidance-focused (not code-heavy)" test_skill_no_code_blocks
echo ""

# Metadata Structure Tests
echo "--- METADATA: Structure Validation ---"
run_test "[P0] META3.1 - YAML frontmatter present" test_metadata_frontmatter_present
run_test "[P0] META3.2 - Name field present" test_metadata_has_name_field
run_test "[P0] META3.3 - Description field present" test_metadata_has_description_field
run_test "[P1] META3.4 - Name matches filename" test_metadata_name_matches_filename
run_test "[P0] META3.5 - Has H1 title header" test_metadata_has_title_header
echo ""

# Prerequisites Field Tests (NEW)
echo "--- PREREQUISITES: Field Validation ---"
run_test "[P0] PREREQ4.1 - Prerequisites field exists" test_prereq_field_exists
run_test "[P0] PREREQ4.2 - Prerequisites has valid value" test_prereq_valid_values
run_test "[P1] PREREQ4.3 - Prerequisites not empty" test_prereq_not_empty
echo ""

# Cross-Reference Tests
echo "--- CROSS-REF: Reference Validation ---"
run_test "[P1] XREF5.1 - Agent references are valid" test_cross_ref_agent_references_valid
run_test "[P1] XREF5.2 - Command references are valid" test_cross_ref_command_references_valid
run_test "[P0] XREF5.3 - pr-workflow-manager referenced" test_cross_ref_pr_workflow_manager_exists
run_test "[P2] XREF5.4 - Delegation section exists" test_cross_ref_delegation_section_exists
echo ""

# Documentation Quality Tests
echo "--- QUALITY: Documentation Standards ---"
run_test "[P3] QUAL6.1 - Has usage examples/docs" test_quality_has_usage_examples
run_test "[P2] QUAL6.2 - No TODO/FIXME markers" test_quality_no_todo_markers
run_test "[P3] QUAL6.3 - Consistent heading hierarchy" test_quality_consistent_heading_levels
run_test "[P2] QUAL6.4 - No broken markdown links" test_quality_no_broken_markdown_links
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
    echo -e "${GREEN}ALL TESTS PASSED - Story 1.4 requirements met${NC}"
    exit 0
else
    echo -e "${RED}SOME TESTS FAILED - Story 1.4 implementation incomplete${NC}"
    exit 1
fi
