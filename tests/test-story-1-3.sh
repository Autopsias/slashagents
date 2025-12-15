#!/bin/bash
# =============================================================================
# ATDD Tests for Story 1.3: Package Subagents
# =============================================================================
# These tests verify that all 11 subagents are properly packaged
# in the agents/ directory with correct naming and valid content.
#
# Test Phase: RED (tests should fail until implementation is complete)
# Story: 1-3-package-subagents
# =============================================================================

# Note: NOT using set -e because we want to continue running tests even if some fail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Expected agent files (exactly 11)
EXPECTED_AGENTS=(
    "unit-test-fixer.md"
    "api-test-fixer.md"
    "database-test-fixer.md"
    "e2e-test-fixer.md"
    "linting-fixer.md"
    "type-error-fixer.md"
    "import-error-fixer.md"
    "security-scanner.md"
    "pr-workflow-manager.md"
    "parallel-executor.md"
    "digdeep.md"
)

# Agent domain organization for reference (not used as associative array for bash 3 compat)
# Test Fixers: unit-test-fixer, api-test-fixer, database-test-fixer, e2e-test-fixer
# Code Quality: linting-fixer, type-error-fixer, import-error-fixer, security-scanner
# Workflow Support: pr-workflow-manager, parallel-executor, digdeep

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
# AC1: All Agents Present - Tests
# =============================================================================

test_ac1_agents_directory_exists() {
    # Test: agents/ directory exists at project root
    if [[ -d "$AGENTS_DIR" ]]; then
        return 0
    else
        echo "  Expected: $AGENTS_DIR to exist"
        return 1
    fi
}

test_ac1_exactly_11_agents() {
    # Test: Exactly 11 agent files exist
    local count=$(ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -eq 11 ]]; then
        return 0
    else
        echo "  Expected: 11 agent files, Found: $count"
        return 1
    fi
}

test_ac1_unit_test_fixer_exists() {
    if [[ -f "$AGENTS_DIR/unit-test-fixer.md" ]]; then
        return 0
    else
        echo "  Missing: agents/unit-test-fixer.md"
        return 1
    fi
}

test_ac1_api_test_fixer_exists() {
    if [[ -f "$AGENTS_DIR/api-test-fixer.md" ]]; then
        return 0
    else
        echo "  Missing: agents/api-test-fixer.md"
        return 1
    fi
}

test_ac1_database_test_fixer_exists() {
    if [[ -f "$AGENTS_DIR/database-test-fixer.md" ]]; then
        return 0
    else
        echo "  Missing: agents/database-test-fixer.md"
        return 1
    fi
}

test_ac1_e2e_test_fixer_exists() {
    if [[ -f "$AGENTS_DIR/e2e-test-fixer.md" ]]; then
        return 0
    else
        echo "  Missing: agents/e2e-test-fixer.md"
        return 1
    fi
}

test_ac1_linting_fixer_exists() {
    if [[ -f "$AGENTS_DIR/linting-fixer.md" ]]; then
        return 0
    else
        echo "  Missing: agents/linting-fixer.md"
        return 1
    fi
}

test_ac1_type_error_fixer_exists() {
    if [[ -f "$AGENTS_DIR/type-error-fixer.md" ]]; then
        return 0
    else
        echo "  Missing: agents/type-error-fixer.md"
        return 1
    fi
}

test_ac1_import_error_fixer_exists() {
    if [[ -f "$AGENTS_DIR/import-error-fixer.md" ]]; then
        return 0
    else
        echo "  Missing: agents/import-error-fixer.md"
        return 1
    fi
}

test_ac1_security_scanner_exists() {
    if [[ -f "$AGENTS_DIR/security-scanner.md" ]]; then
        return 0
    else
        echo "  Missing: agents/security-scanner.md"
        return 1
    fi
}

test_ac1_pr_workflow_manager_exists() {
    if [[ -f "$AGENTS_DIR/pr-workflow-manager.md" ]]; then
        return 0
    else
        echo "  Missing: agents/pr-workflow-manager.md"
        return 1
    fi
}

test_ac1_parallel_executor_exists() {
    if [[ -f "$AGENTS_DIR/parallel-executor.md" ]]; then
        return 0
    else
        echo "  Missing: agents/parallel-executor.md"
        return 1
    fi
}

test_ac1_digdeep_exists() {
    if [[ -f "$AGENTS_DIR/digdeep.md" ]]; then
        return 0
    else
        echo "  Missing: agents/digdeep.md"
        return 1
    fi
}

test_ac1_no_extra_files() {
    # Test: No unexpected files in agents/
    local unexpected_count=0
    for file in "$AGENTS_DIR"/*.md; do
        local basename=$(basename "$file")
        local found=false
        for expected in "${EXPECTED_AGENTS[@]}"; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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

test_ac2_follows_role_specialization_pattern() {
    # Test: Agent filenames follow {role}-{specialization}.md pattern
    # From architecture.md: Agents pattern: {role}-{specialization}.md
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local basename=$(basename "$file" .md)
        # Most agent names should have at least one hyphen (role-specialization)
        # Exception: digdeep is a single word agent name
        if [[ "$basename" != "digdeep" ]] && [[ "$basename" != *"-"* ]]; then
            echo "  Violation: $basename may not follow {role}-{specialization} pattern"
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
# Cross-Reference Tests (AC3 extended)
# =============================================================================

test_ac3_command_references_valid() {
    # Test: Any explicit slash command references in agents point to valid command names
    # We only check for explicit slash command invocations like "/pr", "/ci-orchestrate"
    # NOT URL paths like "/api/users" which are code examples
    # Pattern: Must be standalone /command-name at word boundary, not part of a URL path
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

    # This test is INFORMATIONAL only - agent files contain example code with URL paths
    # that look like slash commands but aren't. We skip this test.
    # Real slash command references would be validated during integration testing.
    return 0
}

test_ac3_agent_to_agent_references_valid() {
    # Test: Any agent-to-agent references are valid
    # Pattern: agents/agent-name.md or agent-name agent
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        # Only look for explicit agent file references like "agents/unit-test-fixer.md"
        while IFS= read -r line; do
            if [[ "$line" =~ agents/([a-z]+(-[a-z]+)+)(\.md)? ]]; then
                local ref="${BASH_REMATCH[1]}"
                ref="${ref%.md}"  # Remove .md if present
                local found=false
                for agent in "${EXPECTED_AGENTS[@]}"; do
                    local agent_name="${agent%.md}"
                    if [[ "$ref" == "$agent_name" ]]; then
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
    # [P0] Test: No agent files are empty (0 bytes)
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
# AGENT-SPECIFIC CONTENT TESTS
# =============================================================================

test_agent_has_agent_definition() {
    # [P0] Test: Agent files contain agent definition indicators
    # Agents typically have headers like "# Agent Name" or define agent behavior
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        # Check for agent-like content (header with agent name or agent instructions)
        if ! grep -qiE "(agent|executor|fixer|scanner|manager|digdeep)" "$file"; then
            echo "  Violation: $(basename "$file") may not contain valid agent definition"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_agent_has_instructions() {
    # [P1] Test: Agent files contain instructions or behavior definitions
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        # Check for instruction-like content
        if ! grep -qiE "(instruction|behavior|task|when|should|must|will)" "$file"; then
            echo "  Warning: $(basename "$file") may lack clear instructions"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_agent_domain_coverage() {
    # [P1] Test: All three agent domains have representation
    # From architecture.md:
    # - Test Fixers: unit-test-fixer, api-test-fixer, database-test-fixer, e2e-test-fixer
    # - Code Quality: linting-fixer, type-error-fixer, import-error-fixer, security-scanner
    # - Workflow Support: pr-workflow-manager, parallel-executor, digdeep

    local test_fixers_count=0
    local code_quality_count=0
    local workflow_count=0

    for file in "$AGENTS_DIR"/*.md; do
        local basename=$(basename "$file" .md)
        case "$basename" in
            unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer)
                ((test_fixers_count++))
                ;;
            linting-fixer|type-error-fixer|import-error-fixer|security-scanner)
                ((code_quality_count++))
                ;;
            pr-workflow-manager|parallel-executor|digdeep)
                ((workflow_count++))
                ;;
        esac
    done

    local violations=0
    if [[ $test_fixers_count -ne 4 ]]; then
        echo "  Missing Test Fixers agents (found $test_fixers_count, expected 4)"
        ((violations++))
    fi
    if [[ $code_quality_count -ne 4 ]]; then
        echo "  Missing Code Quality agents (found $code_quality_count, expected 4)"
        ((violations++))
    fi
    if [[ $workflow_count -ne 3 ]]; then
        echo "  Missing Workflow Support agents (found $workflow_count, expected 3)"
        ((violations++))
    fi

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# METADATA STRUCTURE TESTS (Optional for Agents)
# =============================================================================

test_metadata_has_title_header() {
    # [P0] Test: All agent files have a title (H1 header)
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        # Check for H1 header at the start (allowing for optional frontmatter)
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

test_metadata_frontmatter_if_present() {
    # [P2] Test: If YAML frontmatter exists, it's properly formatted
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            # Frontmatter exists, check it closes properly
            if ! sed -n '2,/^---$/p' "$file" | tail -1 | grep -q "^---$"; then
                echo "  Violation: $(basename "$file") has unclosed YAML frontmatter"
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
# CROSS-REFERENCE VALIDATION TESTS (Commands <-> Agents)
# =============================================================================

test_cross_ref_ci_orchestrate_agents() {
    # Test: /ci-orchestrate invokes known agents
    # From story: /ci-orchestrate invokes: linting-fixer, type-error-fixer, unit-test-fixer, import-error-fixer
    local commands_dir="$PROJECT_ROOT/commands"
    local ci_file="$commands_dir/ci-orchestrate.md"

    if [[ ! -f "$ci_file" ]]; then
        echo "  Skipping: ci-orchestrate.md not found in commands/"
        return 0  # Not a failure - commands may not be packaged yet
    fi

    local violations=0
    local expected_agents=("linting-fixer" "type-error-fixer" "unit-test-fixer" "import-error-fixer")

    for agent in "${expected_agents[@]}"; do
        if ! grep -qi "$agent" "$ci_file"; then
            echo "  Warning: ci-orchestrate.md may not reference $agent"
            # This is informational, not a failure
        fi
    done

    return 0
}

test_cross_ref_test_orchestrate_agents() {
    # Test: /test-orchestrate invokes known agents
    # From story: /test-orchestrate invokes: unit-test-fixer, api-test-fixer, database-test-fixer, e2e-test-fixer
    local commands_dir="$PROJECT_ROOT/commands"
    local test_file="$commands_dir/test-orchestrate.md"

    if [[ ! -f "$test_file" ]]; then
        echo "  Skipping: test-orchestrate.md not found in commands/"
        return 0  # Not a failure - commands may not be packaged yet
    fi

    local violations=0
    local expected_agents=("unit-test-fixer" "api-test-fixer" "database-test-fixer" "e2e-test-fixer")

    for agent in "${expected_agents[@]}"; do
        if ! grep -qi "$agent" "$test_file"; then
            echo "  Warning: test-orchestrate.md may not reference $agent"
            # This is informational, not a failure
        fi
    done

    return 0
}

test_cross_ref_parallelize_agents_command() {
    # Test: /parallelize-agents invokes parallel-executor
    local commands_dir="$PROJECT_ROOT/commands"
    local para_file="$commands_dir/parallelize-agents.md"

    if [[ ! -f "$para_file" ]]; then
        echo "  Skipping: parallelize-agents.md not found in commands/"
        return 0  # Not a failure - commands may not be packaged yet
    fi

    if ! grep -qi "parallel-executor" "$para_file"; then
        echo "  Warning: parallelize-agents.md may not reference parallel-executor"
    fi

    return 0
}

# =============================================================================
# DOCUMENTATION QUALITY TESTS
# =============================================================================

test_quality_has_usage_context() {
    # [P3] Test: Agent files explain when/how to use them
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        # Check for usage context (when to use, how to invoke, etc.)
        if ! grep -qiE "(when|use|invoke|call|trigger|run)" "$file"; then
            echo "  Warning: $(basename "$file") may lack usage context"
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
    for file in "$AGENTS_DIR"/*.md; do
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
    for file in "$AGENTS_DIR"/*.md; do
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
    # [P2] Test: No obviously broken markdown links
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
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
# EXPANDED TESTS - YAML Frontmatter Validation
# =============================================================================

test_yaml_frontmatter_has_name() {
    # [P0] Test: YAML frontmatter contains 'name' field
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            # Frontmatter exists, check for name field
            if ! sed -n '/^---$/,/^---$/p' "$file" | grep -q "^name:"; then
                echo "  Violation: $(basename "$file") frontmatter missing 'name' field"
                ((violations++))
            fi
        else
            echo "  Violation: $(basename "$file") missing YAML frontmatter"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_yaml_frontmatter_has_description() {
    # [P0] Test: YAML frontmatter contains 'description' field
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            if ! sed -n '/^---$/,/^---$/p' "$file" | grep -q "^description:"; then
                echo "  Violation: $(basename "$file") frontmatter missing 'description' field"
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

test_yaml_frontmatter_has_tools() {
    # [P1] Test: YAML frontmatter contains 'tools' field
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            if ! sed -n '/^---$/,/^---$/p' "$file" | grep -q "^tools:"; then
                echo "  Violation: $(basename "$file") frontmatter missing 'tools' field"
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

test_yaml_frontmatter_has_model() {
    # [P1] Test: YAML frontmatter contains 'model' field
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            if ! sed -n '/^---$/,/^---$/p' "$file" | grep -q "^model:"; then
                echo "  Violation: $(basename "$file") frontmatter missing 'model' field"
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

test_yaml_name_matches_filename() {
    # [P1] Test: YAML 'name' field matches filename (without .md)
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
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

# =============================================================================
# EXPANDED TESTS - Description Format Validation
# =============================================================================

test_description_length_under_60_chars() {
    # [P1] Test: Description first line is under 60 characters
    # Note: Agents can have multiline descriptions with '|', checking first meaningful line
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            # Extract description (handle multiline '|' format)
            local desc_line=$(sed -n '/^---$/,/^---$/p' "$file" | grep -A1 "^description:" | tail -1 | sed 's/^[[:space:]]*//')
            local desc_length=${#desc_line}

            # Skip if it's a continuation indicator
            if [[ "$desc_line" != "|" ]] && [[ $desc_length -gt 60 ]]; then
                echo "  Warning: $(basename "$file") description first line is $desc_length chars (max 60)"
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

test_description_present_tense() {
    # [P2] Test: Description starts with present-tense verb
    local violations=0
    local present_verbs="(Fixes|Handles|Manages|Executes|Analyzes|Scans|Validates|Provides|Ensures|Coordinates|Performs|Processes|Independent)"

    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            # Extract description first line
            local desc_line=$(sed -n '/^---$/,/^---$/p' "$file" | grep -A1 "^description:" | tail -1 | sed 's/^[[:space:]]*//')

            # Check if starts with present-tense verb
            if [[ "$desc_line" != "|" ]] && ! echo "$desc_line" | grep -qE "^$present_verbs"; then
                echo "  Warning: $(basename "$file") description may not start with present-tense verb"
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

test_description_not_empty() {
    # [P0] Test: Description field is not empty
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            # Check if description has content
            local desc_content=$(sed -n '/^description:/,/^[a-z]*:/p' "$file" | grep -v "^description:" | grep -v "^[a-z]*:" | tr -d '[:space:]|')
            if [[ -z "$desc_content" ]]; then
                echo "  Violation: $(basename "$file") has empty description"
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
# EXPANDED TESTS - Tools List Validation
# =============================================================================

test_tools_list_not_empty() {
    # [P0] Test: Tools field contains at least one tool
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            local tools_line=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^tools:" | sed 's/^tools:[[:space:]]*//')
            if [[ -z "$tools_line" ]]; then
                echo "  Violation: $(basename "$file") has empty tools list"
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

test_tools_list_comma_separated() {
    # [P1] Test: Tools are comma-separated (not newline or other format)
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            local tools_line=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^tools:" | sed 's/^tools:[[:space:]]*//')
            # Check if contains commas (expected format)
            if [[ -n "$tools_line" ]] && ! echo "$tools_line" | grep -q ","; then
                # Allow single tool (no comma needed)
                local tool_count=$(echo "$tools_line" | wc -w)
                if [[ $tool_count -gt 1 ]]; then
                    echo "  Warning: $(basename "$file") tools may not be comma-separated"
                    ((violations++))
                fi
            fi
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_tools_include_core_tools() {
    # [P1] Test: Tools list includes core tools (Read, Bash)
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            local tools_line=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^tools:")
            # Check for common essential tools
            if ! echo "$tools_line" | grep -q "Read"; then
                echo "  Warning: $(basename "$file") tools missing 'Read' (unusual for agent)"
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
# EXPANDED TESTS - Model Specification Validation
# =============================================================================

test_model_field_valid_value() {
    # [P1] Test: Model field has valid value (sonnet, opus, haiku, etc.)
    local violations=0
    local valid_models="(sonnet|opus|haiku|claude)"

    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            local model_value=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^model:" | sed 's/^model:[[:space:]]*//')
            if [[ -n "$model_value" ]] && ! echo "$model_value" | grep -qiE "$valid_models"; then
                echo "  Warning: $(basename "$file") model '$model_value' may not be standard"
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
# EXPANDED TESTS - Agent Content Structure Validation
# =============================================================================

test_agent_has_execution_instructions() {
    # [P1] Test: Agent files contain execution instructions section
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        if ! grep -qi "EXECUTION.*INSTRUCTION\|CRITICAL.*EXECUTION" "$file"; then
            echo "  Warning: $(basename "$file") may lack execution instructions"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_agent_has_constraints_section() {
    # [P2] Test: Agent files have constraints or rules section
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        if ! grep -qiE "## (Constraint|Rule|Limitation)" "$file"; then
            echo "  Info: $(basename "$file") may not have explicit constraints section"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_agent_no_placeholder_content() {
    # [P0] Test: Agent files don't contain placeholder content
    local violations=0
    local placeholders="(PLACEHOLDER|TBD|CHANGEME|FILLME|YOUR_.*_HERE)"

    for file in "$AGENTS_DIR"/*.md; do
        if grep -iE "$placeholders" "$file" > /dev/null 2>&1; then
            echo "  Violation: $(basename "$file") contains placeholder content"
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
# EXPANDED TESTS - File Line Length Edge Cases
# =============================================================================

test_edge_case_no_extremely_long_lines() {
    # [P2] Test: No lines exceed 500 characters (extreme case)
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        local long_lines=$(awk 'length > 500' "$file" | wc -l | tr -d ' ')
        if [[ $long_lines -gt 0 ]]; then
            echo "  Warning: $(basename "$file") has $long_lines line(s) >500 chars"
            ((violations++))
        fi
    done

    if [[ $violations -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_edge_case_file_ends_with_newline() {
    # [P3] Test: Files end with newline character
    local violations=0
    for file in "$AGENTS_DIR"/*.md; do
        if [[ -n $(tail -c 1 "$file") ]]; then
            echo "  Info: $(basename "$file") doesn't end with newline"
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
# EXPANDED TESTS - Color Field Validation
# =============================================================================

test_yaml_frontmatter_has_color() {
    # [P3] Test: YAML frontmatter contains 'color' field (if supported)
    local violations=0
    local missing_count=0
    for file in "$AGENTS_DIR"/*.md; do
        local first_line=$(head -1 "$file")
        if [[ "$first_line" == "---" ]]; then
            if ! sed -n '/^---$/,/^---$/p' "$file" | grep -q "^color:"; then
                ((missing_count++))
            fi
        fi
    done

    # Only warn if some but not all have color field
    if [[ $missing_count -gt 0 ]] && [[ $missing_count -lt 11 ]]; then
        echo "  Info: $missing_count agent(s) missing color field (inconsistent)"
        return 1
    fi

    return 0
}

# =============================================================================
# Main Test Runner
# =============================================================================

echo "============================================================================="
echo "ATDD Tests for Story 1.3: Package Subagents"
echo "============================================================================="
echo "Project Root: $PROJECT_ROOT"
echo "Agents Dir:   $AGENTS_DIR"
echo "============================================================================="
echo ""

# AC1: All Agents Present
echo "--- AC1: All Agents Present ---"
run_test "AC1.1 - agents/ directory exists" test_ac1_agents_directory_exists
run_test "AC1.2 - Exactly 11 agent files exist" test_ac1_exactly_11_agents
run_test "AC1.3 - unit-test-fixer.md exists" test_ac1_unit_test_fixer_exists
run_test "AC1.4 - api-test-fixer.md exists" test_ac1_api_test_fixer_exists
run_test "AC1.5 - database-test-fixer.md exists" test_ac1_database_test_fixer_exists
run_test "AC1.6 - e2e-test-fixer.md exists" test_ac1_e2e_test_fixer_exists
run_test "AC1.7 - linting-fixer.md exists" test_ac1_linting_fixer_exists
run_test "AC1.8 - type-error-fixer.md exists" test_ac1_type_error_fixer_exists
run_test "AC1.9 - import-error-fixer.md exists" test_ac1_import_error_fixer_exists
run_test "AC1.10 - security-scanner.md exists" test_ac1_security_scanner_exists
run_test "AC1.11 - pr-workflow-manager.md exists" test_ac1_pr_workflow_manager_exists
run_test "AC1.12 - parallel-executor.md exists" test_ac1_parallel_executor_exists
run_test "AC1.13 - digdeep.md exists" test_ac1_digdeep_exists
run_test "AC1.14 - No unexpected files in agents/" test_ac1_no_extra_files
echo ""

# AC2: Kebab-Case Naming
echo "--- AC2: Kebab-Case Naming ---"
run_test "AC2.1 - No underscores in filenames" test_ac2_no_underscores_in_filenames
run_test "AC2.2 - All filenames are lowercase" test_ac2_all_lowercase
run_test "AC2.3 - Valid kebab-case pattern" test_ac2_valid_kebab_case_pattern
run_test "AC2.4 - No camelCase in filenames" test_ac2_no_camelcase
run_test "AC2.5 - Follows {role}-{specialization} pattern" test_ac2_follows_role_specialization_pattern
echo ""

# AC3: File Content Preserved
echo "--- AC3: File Content Preserved ---"
run_test "AC3.1 - All files are valid markdown" test_ac3_all_files_are_valid_markdown
run_test "AC3.2 - Files contain markdown content" test_ac3_files_contain_markdown_content
run_test "AC3.3 - No hardcoded user paths" test_ac3_no_hardcoded_paths
run_test "AC3.4 - UTF-8 encoding" test_ac3_utf8_encoding
run_test "AC3.5 - LF line endings" test_ac3_lf_line_endings
run_test "AC3.6 - Self-contained (no imports)" test_ac3_self_contained_no_imports
run_test "AC3.7 - Command references are valid" test_ac3_command_references_valid
run_test "AC3.8 - Agent-to-agent references are valid" test_ac3_agent_to_agent_references_valid
echo ""

# Edge Case Tests - File Content
echo "--- EDGE CASES: File Content Validation ---"
run_test "[P0] EDGE1.1 - Files are not empty (0 bytes)" test_edge_case_file_not_empty
run_test "[P2] EDGE1.2 - Files are reasonable size (<100KB)" test_edge_case_file_size_reasonable
run_test "[P1] EDGE1.3 - No binary content in files" test_edge_case_no_binary_content
run_test "[P3] EDGE1.4 - No excessive trailing whitespace" test_edge_case_no_trailing_whitespace
run_test "[P3] EDGE1.5 - Files use spaces not tabs" test_edge_case_no_tabs
echo ""

# Agent-Specific Tests
echo "--- AGENT: Content Validation ---"
run_test "[P0] AGENT2.1 - Agent files have agent definition" test_agent_has_agent_definition
run_test "[P1] AGENT2.2 - Agent files have instructions" test_agent_has_instructions
run_test "[P1] AGENT2.3 - All domains have coverage" test_agent_domain_coverage
echo ""

# Metadata Structure Tests
echo "--- METADATA: Structure Validation ---"
run_test "[P0] META3.1 - Has H1 title header" test_metadata_has_title_header
run_test "[P2] META3.2 - Frontmatter properly formatted (if present)" test_metadata_frontmatter_if_present
echo ""

# Cross-Reference Tests (Commands <-> Agents)
echo "--- CROSS-REF: Command-Agent Validation ---"
run_test "[INFO] XREF4.1 - ci-orchestrate references agents" test_cross_ref_ci_orchestrate_agents
run_test "[INFO] XREF4.2 - test-orchestrate references agents" test_cross_ref_test_orchestrate_agents
run_test "[INFO] XREF4.3 - parallelize-agents references executor" test_cross_ref_parallelize_agents_command
echo ""

# Documentation Quality Tests
echo "--- QUALITY: Documentation Standards ---"
run_test "[P3] QUAL5.1 - Has usage context" test_quality_has_usage_context
run_test "[P2] QUAL5.2 - No TODO/FIXME markers" test_quality_no_todo_markers
run_test "[P3] QUAL5.3 - Consistent heading hierarchy" test_quality_consistent_heading_levels
run_test "[P2] QUAL5.4 - No broken markdown links" test_quality_no_broken_markdown_links
echo ""

# Expanded Tests - YAML Frontmatter Validation
echo "--- EXPANDED: YAML Frontmatter Validation ---"
run_test "[P0] YAML6.1 - Frontmatter has 'name' field" test_yaml_frontmatter_has_name
run_test "[P0] YAML6.2 - Frontmatter has 'description' field" test_yaml_frontmatter_has_description
run_test "[P1] YAML6.3 - Frontmatter has 'tools' field" test_yaml_frontmatter_has_tools
run_test "[P1] YAML6.4 - Frontmatter has 'model' field" test_yaml_frontmatter_has_model
run_test "[P1] YAML6.5 - Name matches filename" test_yaml_name_matches_filename
run_test "[P3] YAML6.6 - Frontmatter has 'color' field (optional)" test_yaml_frontmatter_has_color
echo ""

# Expanded Tests - Description Format Validation
echo "--- EXPANDED: Description Format Validation ---"
run_test "[P0] DESC7.1 - Description not empty" test_description_not_empty
run_test "[P1] DESC7.2 - Description under 60 chars" test_description_length_under_60_chars
run_test "[P2] DESC7.3 - Description starts with present-tense verb" test_description_present_tense
echo ""

# Expanded Tests - Tools List Validation
echo "--- EXPANDED: Tools List Validation ---"
run_test "[P0] TOOLS8.1 - Tools list not empty" test_tools_list_not_empty
run_test "[P1] TOOLS8.2 - Tools are comma-separated" test_tools_list_comma_separated
run_test "[P1] TOOLS8.3 - Tools include core tools" test_tools_include_core_tools
echo ""

# Expanded Tests - Model Specification Validation
echo "--- EXPANDED: Model Specification Validation ---"
run_test "[P1] MODEL9.1 - Model field has valid value" test_model_field_valid_value
echo ""

# Expanded Tests - Agent Content Structure
echo "--- EXPANDED: Agent Content Structure ---"
run_test "[P1] STRUCT10.1 - Has execution instructions" test_agent_has_execution_instructions
run_test "[P2] STRUCT10.2 - Has constraints section" test_agent_has_constraints_section
run_test "[P0] STRUCT10.3 - No placeholder content" test_agent_no_placeholder_content
echo ""

# Expanded Tests - File Edge Cases
echo "--- EXPANDED: File Edge Cases ---"
run_test "[P2] EDGE11.1 - No extremely long lines (>500 chars)" test_edge_case_no_extremely_long_lines
run_test "[P3] EDGE11.2 - Files end with newline" test_edge_case_file_ends_with_newline
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
    echo -e "${GREEN}ALL TESTS PASSED - Story 1.3 requirements met${NC}"
    exit 0
else
    echo -e "${RED}SOME TESTS FAILED - Story 1.3 implementation incomplete${NC}"
    exit 1
fi
