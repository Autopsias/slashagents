#!/bin/bash
# =============================================================================
# ATDD Tests for Story 2.5: Document Tier Classifications
# =============================================================================
# These tests verify that the tier classification documentation is complete:
# - Standalone tools (6): Identified and documented
# - MCP-Enhanced tools (5): Documented with MCP server names
# - BMAD-Required tools (3): Identified and documented
# - Project-Context tools (9): Documented with required files
#
# Test Phase: RED (tests should fail until implementation is complete)
# Story: 2-5-document-tier-classifications
# =============================================================================

# Note: NOT using set -e because we want to continue running tests even if some fail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIER_DOC="$PROJECT_ROOT/docs/sprint-artifacts/tier-classifications.md"
METADATA_AUDIT="$PROJECT_ROOT/docs/sprint-artifacts/metadata-audit.md"

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

# Expected Standalone tools (6)
STANDALONE_TOOLS=(
    "test-orchestrate.md"
    "commit-orchestrate.md"
    "parallelize.md"
    "parallelize-agents.md"
    "nextsession.md"
    "parallel-executor.md"
)

# Expected MCP-Enhanced tools (5)
MCP_ENHANCED_TOOLS=(
    "pr.md"
    "ci-orchestrate.md"
    "pr-workflow-manager.md"
    "digdeep.md"
    "pr-workflow.md"
)

# Expected MCP servers to check for (using simple arrays instead of associative)
MCP_SERVERS_LIST="github perplexity-ask"

# Expected BMAD-Required tools (3)
BMAD_REQUIRED_TOOLS=(
    "epic-dev.md"
    "epic-dev-full.md"
    "epic-dev-init.md"
)

# Expected Project-Context tools (9)
PROJECT_CONTEXT_TOOLS=(
    "usertestgates.md"
    "unit-test-fixer.md"
    "api-test-fixer.md"
    "database-test-fixer.md"
    "e2e-test-fixer.md"
    "linting-fixer.md"
    "type-error-fixer.md"
    "import-error-fixer.md"
    "security-scanner.md"
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

# =============================================================================
# AC1: Standalone Tools Identified Tests
# =============================================================================

# TEST-AC-2.5.1.1: tier-classifications.md file exists
test_tier_doc_exists() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  File not found: $TIER_DOC"
        return 1
    fi
    return 0
}

# TEST-AC-2.5.1.2: Standalone section exists in document
test_standalone_section_exists() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    if ! grep -qE "^###? Standalone" "$TIER_DOC"; then
        echo "  Missing 'Standalone' section header"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.1.3: All 6 Standalone tools are listed
test_standalone_tools_count() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    local count=0
    for tool in "${STANDALONE_TOOLS[@]}"; do
        if grep -q "$tool" "$TIER_DOC"; then
            count=$((count + 1))
        else
            echo "  Missing Standalone tool: $tool"
        fi
    done

    if [[ $count -ne 6 ]]; then
        echo "  Expected 6 Standalone tools, found $count"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.1.4: Each Standalone tool is marked with correct tier
test_standalone_tools_verified() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    local failed=0
    for tool in "${STANDALONE_TOOLS[@]}"; do
        # Check if tool appears in Standalone section or with Standalone tier
        if ! grep -A5 "Standalone" "$TIER_DOC" | grep -q "$tool"; then
            # Also check summary table format
            if ! grep -E "^\|.*$tool.*\|.*Standalone" "$TIER_DOC" | grep -q "$tool"; then
                echo "  Tool $tool not verified as Standalone"
                failed=1
            fi
        fi
    done

    return $failed
}

# =============================================================================
# AC2: MCP-Enhanced Tools Identified Tests
# =============================================================================

# TEST-AC-2.5.2.1: MCP-Enhanced section exists
test_mcp_enhanced_section_exists() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    if ! grep -qE "^###? MCP-Enhanced" "$TIER_DOC"; then
        echo "  Missing 'MCP-Enhanced' section header"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.2.2: All 5 MCP-Enhanced tools are listed
test_mcp_enhanced_tools_count() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    local count=0
    for tool in "${MCP_ENHANCED_TOOLS[@]}"; do
        if grep -q "$tool" "$TIER_DOC"; then
            count=$((count + 1))
        else
            echo "  Missing MCP-Enhanced tool: $tool"
        fi
    done

    if [[ $count -ne 5 ]]; then
        echo "  Expected 5 MCP-Enhanced tools, found $count"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.2.3: Each MCP-Enhanced tool has MCP server name documented
test_mcp_server_names_documented() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    local failed=0
    for server in $MCP_SERVERS_LIST; do
        if ! grep -q "$server" "$TIER_DOC"; then
            echo "  MCP server '$server' not documented"
            failed=1
        fi
    done

    return $failed
}

# TEST-AC-2.5.2.4: Enhanced functionality documented for MCP tools
test_mcp_enhanced_functionality_documented() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    # Check for presence of "enhanced" or "functionality" keywords in MCP section
    if ! grep -iE "(enhanced|functionality|provides|enables)" "$TIER_DOC" > /dev/null; then
        echo "  Enhanced functionality not documented for MCP-Enhanced tools"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.2.5: Degraded behavior documented for MCP tools
test_mcp_degraded_behavior_documented() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    # Check for presence of degraded/fallback/without keywords
    if ! grep -iE "(degraded|fallback|without|unavailable|fails|error)" "$TIER_DOC" > /dev/null; then
        echo "  Degraded behavior not documented for MCP-Enhanced tools"
        return 1
    fi

    return 0
}

# =============================================================================
# AC3: BMAD-Required Tools Identified Tests
# =============================================================================

# TEST-AC-2.5.3.1: BMAD-Required section exists
test_bmad_required_section_exists() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    if ! grep -qE "^###? BMAD-Required" "$TIER_DOC"; then
        echo "  Missing 'BMAD-Required' section header"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.3.2: All 3 BMAD-Required tools are listed
test_bmad_required_tools_count() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    local count=0
    for tool in "${BMAD_REQUIRED_TOOLS[@]}"; do
        if grep -q "$tool" "$TIER_DOC"; then
            count=$((count + 1))
        else
            echo "  Missing BMAD-Required tool: $tool"
        fi
    done

    if [[ $count -ne 3 ]]; then
        echo "  Expected 3 BMAD-Required tools, found $count"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.3.3: BMAD framework requirement is documented
test_bmad_framework_documented() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    if ! grep -iE "BMAD framework" "$TIER_DOC" > /dev/null; then
        echo "  BMAD framework requirement not documented"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.3.4: No other tools incorrectly marked as BMAD-Required
test_only_three_bmad_tools() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    # Count tools in BMAD-Required section
    local bmad_count
    bmad_count=$(grep -E "^\|.*\|.*BMAD-Required" "$TIER_DOC" 2>/dev/null | wc -l | tr -d ' ')

    # Also check for explicit mentions in BMAD section
    local section_count=0
    for tool in "${BMAD_REQUIRED_TOOLS[@]}"; do
        if grep -q "$tool" "$TIER_DOC"; then
            section_count=$((section_count + 1))
        fi
    done

    # Ensure no extra tools are marked as BMAD-Required
    if [[ "$bmad_count" != "" ]] && [[ $bmad_count -gt 3 ]]; then
        echo "  More than 3 tools marked as BMAD-Required: $bmad_count"
        return 1
    fi

    return 0
}

# =============================================================================
# AC4: Project-Context Tools Identified Tests
# =============================================================================

# TEST-AC-2.5.4.1: Project-Context section exists
test_project_context_section_exists() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    if ! grep -qE "^###? Project-Context" "$TIER_DOC"; then
        echo "  Missing 'Project-Context' section header"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.4.2: All 9 Project-Context tools are listed
test_project_context_tools_count() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    local count=0
    for tool in "${PROJECT_CONTEXT_TOOLS[@]}"; do
        if grep -q "$tool" "$TIER_DOC"; then
            count=$((count + 1))
        else
            echo "  Missing Project-Context tool: $tool"
        fi
    done

    if [[ $count -ne 9 ]]; then
        echo "  Expected 9 Project-Context tools, found $count"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.4.3: Project requirements are documented
test_project_requirements_documented() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    local keywords="test files test gates linting config code files project"
    local found=0
    for keyword in $keywords; do
        if grep -qi "$keyword" "$TIER_DOC"; then
            found=$((found + 1))
        fi
    done

    if [[ $found -lt 3 ]]; then
        echo "  Project requirements not sufficiently documented (found $found keyword matches, expected at least 3)"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.4.4: Project requirements reference table exists
test_project_requirements_table_exists() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    # Check for reference table header
    if ! grep -qE "^##? Project Requirements Reference" "$TIER_DOC"; then
        if ! grep -qE "Requirements.*Reference|Project.*Requirements" "$TIER_DOC"; then
            echo "  Missing 'Project Requirements Reference' section"
            return 1
        fi
    fi

    return 0
}

# =============================================================================
# Document Structure Tests
# =============================================================================

# TEST-AC-2.5.5.1: Summary table includes all 23 tools
test_summary_table_all_tools() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    # Check for Summary Table section
    if ! grep -qE "^##? Summary Table" "$TIER_DOC"; then
        echo "  Missing 'Summary Table' section"
        return 1
    fi

    # Count total tools mentioned in document
    local tool_count=0
    local all_tools=("${STANDALONE_TOOLS[@]}" "${MCP_ENHANCED_TOOLS[@]}" "${BMAD_REQUIRED_TOOLS[@]}" "${PROJECT_CONTEXT_TOOLS[@]}")

    for tool in "${all_tools[@]}"; do
        if grep -q "$tool" "$TIER_DOC"; then
            tool_count=$((tool_count + 1))
        fi
    done

    if [[ $tool_count -ne 23 ]]; then
        echo "  Expected 23 tools in summary, found $tool_count"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.5.2: MCP server reference table exists
test_mcp_server_reference_exists() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    if ! grep -qE "^##? MCP Server Reference" "$TIER_DOC"; then
        echo "  Missing 'MCP Server Reference' section"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.5.3: Document has proper markdown structure
test_document_structure() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    # Check for main title
    if ! head -1 "$TIER_DOC" | grep -qE "^# "; then
        echo "  Missing main title (# heading)"
        return 1
    fi

    # Check for Overview section
    if ! grep -qE "^##? Overview" "$TIER_DOC"; then
        echo "  Missing 'Overview' section"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.5.4: Total tools count is documented
test_total_count_documented() {
    if [[ ! -f "$TIER_DOC" ]]; then
        echo "  tier-classifications.md not found"
        return 1
    fi

    # Check for "23 tools" or "Total: 23" mention
    if ! grep -qE "(23 tools|Total.*23|Total: 23)" "$TIER_DOC"; then
        echo "  Total tool count (23) not documented"
        return 1
    fi

    return 0
}

# =============================================================================
# Metadata Audit Consistency Tests
# =============================================================================

# TEST-AC-2.5.6.1: Tier classifications marked as finalized in metadata-audit
test_metadata_audit_finalized() {
    if [[ ! -f "$METADATA_AUDIT" ]]; then
        echo "  metadata-audit.md not found"
        return 1
    fi

    # Check for "finalized" keyword (as opposed to "draft")
    if ! grep -qi "finalized" "$METADATA_AUDIT"; then
        if grep -qi "draft" "$METADATA_AUDIT"; then
            echo "  metadata-audit.md still shows 'draft' status, expected 'finalized'"
            return 1
        fi
        echo "  metadata-audit.md does not indicate finalized tier classifications"
        return 1
    fi

    return 0
}

# TEST-AC-2.5.6.2: Consistency between tier-classifications.md and metadata-audit.md
test_tier_consistency() {
    if [[ ! -f "$TIER_DOC" ]] || [[ ! -f "$METADATA_AUDIT" ]]; then
        echo "  Required files not found"
        return 1
    fi

    # Sample check: verify same tools appear in both documents
    local inconsistent=0
    for tool in "${STANDALONE_TOOLS[@]}"; do
        if ! grep -q "$tool" "$TIER_DOC" || ! grep -q "$tool" "$METADATA_AUDIT"; then
            echo "  Inconsistency found for: $tool"
            inconsistent=1
        fi
    done

    return $inconsistent
}

# =============================================================================
# Main Test Execution
# =============================================================================

echo "============================================================================="
echo "ATDD Tests for Story 2.5: Document Tier Classifications"
echo "============================================================================="
echo "Test Phase: RED (expecting failures - documentation not yet created)"
echo "Story: 2-5-document-tier-classifications"
echo "Project Root: $PROJECT_ROOT"
echo "Tier Doc: $TIER_DOC"
echo "============================================================================="
echo ""

# =============================================================================
# AC1: Standalone Tools Tests
# =============================================================================
echo -e "\n${BLUE}=== AC1: Standalone Tools Identified ===${NC}\n"

run_test "TEST-AC-2.5.1.1: tier-classifications.md file exists" \
    test_tier_doc_exists

run_test "TEST-AC-2.5.1.2: Standalone section exists in document" \
    test_standalone_section_exists

run_test "TEST-AC-2.5.1.3: All 6 Standalone tools are listed" \
    test_standalone_tools_count

run_test "TEST-AC-2.5.1.4: Each Standalone tool verified with correct tier" \
    test_standalone_tools_verified

# =============================================================================
# AC2: MCP-Enhanced Tools Tests
# =============================================================================
echo -e "\n${BLUE}=== AC2: MCP-Enhanced Tools Identified ===${NC}\n"

run_test "TEST-AC-2.5.2.1: MCP-Enhanced section exists" \
    test_mcp_enhanced_section_exists

run_test "TEST-AC-2.5.2.2: All 5 MCP-Enhanced tools are listed" \
    test_mcp_enhanced_tools_count

run_test "TEST-AC-2.5.2.3: Each MCP tool has server name documented" \
    test_mcp_server_names_documented

run_test "TEST-AC-2.5.2.4: Enhanced functionality documented" \
    test_mcp_enhanced_functionality_documented

run_test "TEST-AC-2.5.2.5: Degraded behavior documented" \
    test_mcp_degraded_behavior_documented

# =============================================================================
# AC3: BMAD-Required Tools Tests
# =============================================================================
echo -e "\n${BLUE}=== AC3: BMAD-Required Tools Identified ===${NC}\n"

run_test "TEST-AC-2.5.3.1: BMAD-Required section exists" \
    test_bmad_required_section_exists

run_test "TEST-AC-2.5.3.2: All 3 BMAD-Required tools are listed" \
    test_bmad_required_tools_count

run_test "TEST-AC-2.5.3.3: BMAD framework requirement documented" \
    test_bmad_framework_documented

run_test "TEST-AC-2.5.3.4: Only 3 tools marked as BMAD-Required" \
    test_only_three_bmad_tools

# =============================================================================
# AC4: Project-Context Tools Tests
# =============================================================================
echo -e "\n${BLUE}=== AC4: Project-Context Tools Identified ===${NC}\n"

run_test "TEST-AC-2.5.4.1: Project-Context section exists" \
    test_project_context_section_exists

run_test "TEST-AC-2.5.4.2: All 9 Project-Context tools are listed" \
    test_project_context_tools_count

run_test "TEST-AC-2.5.4.3: Project requirements documented" \
    test_project_requirements_documented

run_test "TEST-AC-2.5.4.4: Project requirements reference table exists" \
    test_project_requirements_table_exists

# =============================================================================
# Document Structure Tests
# =============================================================================
echo -e "\n${BLUE}=== Document Structure Tests ===${NC}\n"

run_test "TEST-AC-2.5.5.1: Summary table includes all 23 tools" \
    test_summary_table_all_tools

run_test "TEST-AC-2.5.5.2: MCP server reference table exists" \
    test_mcp_server_reference_exists

run_test "TEST-AC-2.5.5.3: Document has proper markdown structure" \
    test_document_structure

run_test "TEST-AC-2.5.5.4: Total tool count (23) is documented" \
    test_total_count_documented

# =============================================================================
# Metadata Audit Consistency Tests
# =============================================================================
echo -e "\n${BLUE}=== Metadata Audit Consistency Tests ===${NC}\n"

run_test "TEST-AC-2.5.6.1: Tier classifications marked as finalized" \
    test_metadata_audit_finalized

run_test "TEST-AC-2.5.6.2: Consistency between tier-classifications.md and metadata-audit.md" \
    test_tier_consistency

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
    echo "This is the expected state before implementing Story 2.5."
    echo ""
    echo "To proceed to GREEN phase:"
    echo "1. Create docs/sprint-artifacts/tier-classifications.md"
    echo "2. Include Summary Table with all 23 tools"
    echo "3. Document each tier section (Standalone, MCP-Enhanced, BMAD-Required, Project-Context)"
    echo "4. Add MCP Server Reference table"
    echo "5. Add Project Requirements Reference table"
    echo "6. Update metadata-audit.md to mark tiers as 'finalized'"
    echo "7. Re-run this test script to verify all tests pass"
    exit 1
else
    echo -e "\n${GREEN}GREEN PHASE: All tests passing!${NC}"
    echo "Story 2.5 implementation is complete."
    exit 0
fi
