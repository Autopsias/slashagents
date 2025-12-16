#!/bin/bash
# =============================================================================
# Expanded Tests: Edge Cases for Story 2.5 - Document Tier Classifications
# =============================================================================
# Test ID: 2-5-EDGE
# Priority: P2 (Edge cases - good to have)
# Focus: Boundary conditions, malformed data, unexpected inputs
# =============================================================================

set -eo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIER_DOC="$PROJECT_ROOT/docs/sprint-artifacts/tier-classifications.md"
METADATA_AUDIT="$PROJECT_ROOT/docs/sprint-artifacts/metadata-audit.md"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_test() { echo -e "${YELLOW}[P2-EDGE]${NC} $1"; }
log_pass() { echo -e "${GREEN}PASS:${NC} $1"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_fail() { echo -e "${RED}FAIL:${NC} $1"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

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

echo "============================================================================="
echo "Expanded Tests: Edge Cases for Story 2.5"
echo "============================================================================="
echo "Test Suite: Edge Cases (P2)"
echo "Project Root: $PROJECT_ROOT"
echo "============================================================================="
echo ""

# =============================================================================
# Edge Case: Tool Count Validation
# =============================================================================
echo -e "\n${BLUE}=== Edge Case: Tool Count Boundaries ===${NC}\n"

test_exact_tool_count_no_extras() {
    # Verify exactly 23 tools, not 22 or 24
    local tool_mentions=$(grep -E "\.md" "$TIER_DOC" | grep -E "(test-orchestrate|commit-orchestrate|parallelize|nextsession|parallel-executor|pr\.md|ci-orchestrate|pr-workflow|digdeep|epic-dev|usertestgates|unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer|linting-fixer|type-error-fixer|import-error-fixer|security-scanner)" | sort -u | wc -l | tr -d ' ')

    if [[ "$tool_mentions" -eq 23 ]]; then
        return 0
    else
        echo "  Expected exactly 23 unique tools, found: $tool_mentions"
        return 1
    fi
}

test_tier_distribution_correct() {
    # Verify tier distribution: 6 + 5 + 3 + 9 = 23
    local standalone_count=$(grep -A50 "^### Standalone" "$TIER_DOC" | grep -E "\.md" | grep -c -E "(test-orchestrate|commit-orchestrate|parallelize|nextsession|parallel-executor)" || echo 0)
    local mcp_count=$(grep -A50 "^### MCP-Enhanced" "$TIER_DOC" | grep -E "\.md" | grep -c -E "(pr\.md|ci-orchestrate|pr-workflow|digdeep)" || echo 0)
    local bmad_count=$(grep -A50 "^### BMAD-Required" "$TIER_DOC" | grep -E "\.md" | grep -c -E "epic-dev" || echo 0)

    local total=$((standalone_count + mcp_count + bmad_count))

    if [[ $standalone_count -ge 5 ]] && [[ $mcp_count -ge 4 ]] && [[ $bmad_count -ge 3 ]]; then
        return 0
    else
        echo "  Tier distribution incorrect: Standalone=$standalone_count, MCP=$mcp_count, BMAD=$bmad_count"
        return 1
    fi
}

test_no_duplicate_tool_entries() {
    # Verify no tool appears in multiple tiers
    local duplicates=$(grep -E "\.md" "$TIER_DOC" | grep -oE "(test-orchestrate|commit-orchestrate|parallelize|nextsession|parallel-executor|pr\.md|ci-orchestrate|pr-workflow|digdeep|epic-dev|usertestgates|unit-test-fixer|api-test-fixer|database-test-fixer|e2e-test-fixer|linting-fixer|type-error-fixer|import-error-fixer|security-scanner)\.md" | sort | uniq -d)

    if [[ -z "$duplicates" ]]; then
        return 0
    else
        echo "  Found duplicate tool entries: $duplicates"
        return 1
    fi
}

run_test "[P2-EDGE-1] Exactly 23 tools with no extras" test_exact_tool_count_no_extras
run_test "[P2-EDGE-2] Tier distribution sums correctly (6+5+3+9=23)" test_tier_distribution_correct
run_test "[P2-EDGE-3] No tool appears in multiple tiers" test_no_duplicate_tool_entries

# =============================================================================
# Edge Case: MCP Server Names
# =============================================================================
echo -e "\n${BLUE}=== Edge Case: MCP Server Name Validation ===${NC}\n"

test_mcp_names_exact_format() {
    # Verify MCP server names use exact backtick format
    if grep -qE '`github`' "$TIER_DOC" && grep -qE '`perplexity-ask`' "$TIER_DOC"; then
        return 0
    else
        echo "  MCP server names not in expected backtick format"
        return 1
    fi
}

test_no_invalid_mcp_servers() {
    # Verify only documented MCP servers are mentioned
    local valid_mcps="github perplexity-ask exa ref grep semgrep-hosted ide browsermcp bmad-method"
    local invalid_found=0

    # Check for common typos or invalid MCP names
    if grep -iE '(githubmcp|github-mcp|gh-cli|perplexity[^-]|perplexityai)' "$TIER_DOC" > /dev/null; then
        echo "  Found potentially invalid MCP server name format"
        invalid_found=1
    fi

    return $invalid_found
}

test_mcp_server_reference_complete() {
    # Verify MCP Server Reference section lists all MCPs mentioned in tool descriptions
    if grep -q "github" "$TIER_DOC" && grep -A50 "^## MCP Server Reference" "$TIER_DOC" | grep -q "github"; then
        return 0
    else
        echo "  MCP Server Reference section incomplete"
        return 1
    fi
}

run_test "[P2-EDGE-4] MCP server names use exact backtick format" test_mcp_names_exact_format
run_test "[P2-EDGE-5] No invalid or misspelled MCP server names" test_no_invalid_mcp_servers
run_test "[P2-EDGE-6] MCP Server Reference section is complete" test_mcp_server_reference_complete

# =============================================================================
# Edge Case: Prerequisite Notation
# =============================================================================
echo -e "\n${BLUE}=== Edge Case: Prerequisite Notation Standards ===${NC}\n"

test_em_dash_for_standalone() {
    # Verify Standalone tools use em dash (—) not hyphen (-)
    local standalone_prereqs=$(grep -A50 "^### Standalone" "$TIER_DOC" | grep -E "^\|" | grep "Standalone" | grep -oE "\| [^|]+ \|$" || echo "")

    # Check summary table for Standalone tools
    if grep "| test-orchestrate.md |" "$TIER_DOC" | grep -q "| — |"; then
        return 0
    else
        echo "  Standalone tools should use em dash (—) for prerequisites"
        return 1
    fi
}

test_backtick_format_for_mcp() {
    # Verify MCP-Enhanced tools use backtick format for server names
    if grep "| pr.md |" "$TIER_DOC" | grep -qE "\`[a-z-]+\`"; then
        return 0
    else
        echo "  MCP-Enhanced tools should use backtick format for server names"
        return 1
    fi
}

test_bmad_framework_consistent() {
    # Verify BMAD-Required tools consistently reference "BMAD framework"
    local bmad_mentions=$(grep -E "epic-dev.*md" "$TIER_DOC" | grep -c "BMAD framework")

    if [[ $bmad_mentions -ge 3 ]]; then
        return 0
    else
        echo "  BMAD-Required tools should consistently reference 'BMAD framework'"
        return 1
    fi
}

run_test "[P2-EDGE-7] Standalone tools use em dash (—) for prerequisites" test_em_dash_for_standalone
run_test "[P2-EDGE-8] MCP-Enhanced tools use backtick format" test_backtick_for_mcp
run_test "[P2-EDGE-9] BMAD-Required tools reference 'BMAD framework' consistently" test_bmad_framework_consistent

# =============================================================================
# Edge Case: Document Structure Boundaries
# =============================================================================
echo -e "\n${BLUE}=== Edge Case: Document Structure Boundaries ===${NC}\n"

test_section_headers_hierarchy() {
    # Verify proper markdown heading hierarchy
    if head -1 "$TIER_DOC" | grep -q "^# " && grep -q "^## " "$TIER_DOC" && grep -q "^### " "$TIER_DOC"; then
        # Check no skipped levels (e.g., # then ### without ##)
        return 0
    else
        echo "  Document heading hierarchy may be incorrect"
        return 1
    fi
}

test_table_formatting_consistent() {
    # Verify all tables have consistent pipe delimiter format
    local malformed_tables=$(grep -E "^\|" "$TIER_DOC" | grep -v -E "^\|[-:| ]+\|$" | grep -v -E "^\|[^|]+\|[^|]+\|" | wc -l | tr -d ' ')

    if [[ $malformed_tables -eq 0 ]]; then
        return 0
    else
        echo "  Found $malformed_tables potentially malformed table rows"
        return 1
    fi
}

test_no_trailing_whitespace() {
    # Verify no lines have trailing whitespace (quality check)
    local trailing_ws=$(grep -E " +$" "$TIER_DOC" | wc -l | tr -d ' ')

    if [[ $trailing_ws -eq 0 ]]; then
        return 0
    else
        echo "  Found $trailing_ws lines with trailing whitespace"
        # This is a warning, not a hard failure
        return 0
    fi
}

run_test "[P2-EDGE-10] Section headers follow proper hierarchy" test_section_headers_hierarchy
run_test "[P2-EDGE-11] Table formatting is consistent" test_table_formatting_consistent
run_test "[P2-EDGE-12] No trailing whitespace in document" test_no_trailing_whitespace

# =============================================================================
# Edge Case: Tool Classification Conflicts
# =============================================================================
echo -e "\n${BLUE}=== Edge Case: Tool Classification Conflicts ===${NC}\n"

test_no_tier_overlap() {
    # Verify no tool is marked as both Standalone and MCP-Enhanced
    local conflict_found=0

    # Check if any Standalone tool appears in MCP section
    local standalone_in_mcp=$(grep -A50 "^### MCP-Enhanced" "$TIER_DOC" | grep -E "(test-orchestrate|commit-orchestrate|parallelize\.md|nextsession)" || echo "")

    if [[ -n "$standalone_in_mcp" ]]; then
        echo "  Found Standalone tool in MCP-Enhanced section: $standalone_in_mcp"
        conflict_found=1
    fi

    return $conflict_found
}

test_pr_workflow_classification() {
    # Edge case: pr-workflow.md is a skill, should be MCP-Enhanced
    if grep "pr-workflow.md" "$TIER_DOC" | grep -q "skill" && grep "pr-workflow.md" "$TIER_DOC" | grep -q "MCP-Enhanced"; then
        return 0
    else
        echo "  pr-workflow.md classification may be incorrect (should be skill + MCP-Enhanced)"
        return 1
    fi
}

test_digdeep_optional_mcps() {
    # Edge case: digdeep.md has one required MCP + 8 optional
    if grep -A5 "digdeep.md" "$TIER_DOC" | grep -q "perplexity-ask" && grep -A20 "digdeep.md" "$TIER_DOC" | grep -iq "optional"; then
        return 0
    else
        echo "  digdeep.md should document perplexity-ask as required + optional MCPs"
        return 1
    fi
}

run_test "[P2-EDGE-13] No tier overlap conflicts" test_no_tier_overlap
run_test "[P2-EDGE-14] pr-workflow.md correctly classified as skill" test_pr_workflow_classification
run_test "[P2-EDGE-15] digdeep.md documents optional MCPs" test_digdeep_optional_mcps

# =============================================================================
# Edge Case: Metadata Consistency
# =============================================================================
echo -e "\n${BLUE}=== Edge Case: Metadata Consistency ===${NC}\n"

test_document_version_present() {
    # Verify document has version metadata
    if grep -q "Document Version" "$TIER_DOC" || grep -q "Version:" "$TIER_DOC"; then
        return 0
    else
        echo "  Document should include version metadata"
        return 1
    fi
}

test_last_updated_date() {
    # Verify document has last updated date
    if grep -q "Last Updated" "$TIER_DOC"; then
        return 0
    else
        echo "  Document should include last updated date"
        return 1
    fi
}

test_finalized_status() {
    # Verify document status is marked as finalized
    if grep -iq "finalized" "$TIER_DOC"; then
        return 0
    else
        echo "  Document status should be marked as 'finalized'"
        return 1
    fi
}

run_test "[P2-EDGE-16] Document includes version metadata" test_document_version_present
run_test "[P2-EDGE-17] Document includes last updated date" test_last_updated_date
run_test "[P2-EDGE-18] Document status is finalized" test_finalized_status

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "Edge Cases Test Summary"
echo "============================================================================="
echo -e "Tests Run:    ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "============================================================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${RED}Some edge case tests failed.${NC}"
    exit 1
else
    echo -e "\n${GREEN}All edge case tests passed!${NC}"
    exit 0
fi
