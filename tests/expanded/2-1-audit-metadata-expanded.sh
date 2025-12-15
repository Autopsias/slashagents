#!/bin/bash
# Expanded Test Suite for Story 2.1: Audit Current Tool Metadata
# Extends ATDD tests with edge cases, error handling, integration, validation, and boundary tests
#
# Priority Tagging:
# [P0] Critical path tests (must pass) - core acceptance criteria validation
# [P1] Important scenarios (should pass) - data accuracy and completeness
# [P2] Edge cases (good to have) - unusual but valid scenarios
# [P3] Future-proofing (optional) - extensibility and maintainability
#
# Usage: ./tests/expanded/2-1-audit-metadata-expanded.sh
# Exit code: 0 = all tests pass, non-zero = number of failed tests

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_FILE="$PROJECT_ROOT/docs/sprint-artifacts/metadata-audit.md"
COMMANDS_DIR="$PROJECT_ROOT/commands"
AGENTS_DIR="$PROJECT_ROOT/agents"
SKILLS_DIR="$PROJECT_ROOT/skills"
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test result tracking
declare -a RESULTS

# Priority counters
P0_PASS=0
P0_FAIL=0
P1_PASS=0
P1_FAIL=0
P2_PASS=0
P2_FAIL=0
P3_PASS=0
P3_FAIL=0

# Test helper function with priority tracking
run_test() {
    local test_id="$1"
    local priority="$2"
    local test_desc="$3"
    local test_cmd="$4"

    echo -n "  [$test_id] $test_desc... "

    if eval "$test_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        RESULTS+=("PASS: $test_id - $test_desc")

        case $priority in
            P0) P0_PASS=$((P0_PASS + 1)) ;;
            P1) P1_PASS=$((P1_PASS + 1)) ;;
            P2) P2_PASS=$((P2_PASS + 1)) ;;
            P3) P3_PASS=$((P3_PASS + 1)) ;;
        esac
    else
        echo -e "${RED}FAIL${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        RESULTS+=("FAIL: $test_id - $test_desc")

        case $priority in
            P0) P0_FAIL=$((P0_FAIL + 1)) ;;
            P1) P1_FAIL=$((P1_FAIL + 1)) ;;
            P2) P2_FAIL=$((P2_FAIL + 1)) ;;
            P3) P3_FAIL=$((P3_FAIL + 1)) ;;
        esac
    fi
}

echo ""
echo "========================================================"
echo "EXPANDED TEST SUITE: Story 2.1 - Audit Metadata"
echo "========================================================"
echo ""
echo "Project Root: $PROJECT_ROOT"
echo "Audit File: $AUDIT_FILE"
echo ""

# =============================================================================
# EDGE CASE TESTS
# =============================================================================
echo -e "${BLUE}EDGE CASE TESTS${NC}"
echo "========================================================"

# Edge Case: Missing Tool Files
run_test "EDGE-1.1" "P1" "Handles missing command file gracefully" \
    "[ ! -f '$COMMANDS_DIR/nonexistent.md' ]"

run_test "EDGE-1.2" "P1" "Handles missing agent file gracefully" \
    "[ ! -f '$AGENTS_DIR/nonexistent.md' ]"

run_test "EDGE-1.3" "P1" "Handles missing skill file gracefully" \
    "[ ! -f '$SKILLS_DIR/nonexistent.md' ]"

# Edge Case: Empty Descriptions
run_test "EDGE-2.1" "P2" "No tools have empty descriptions in audit" \
    "! grep -qE '^\|[^|]*\|[^|]*\|\s*\|' '$AUDIT_FILE'"

# Edge Case: Exactly 60 Character Descriptions
run_test "EDGE-3.1" "P2" "Audit handles exactly 60-char descriptions" \
    "grep -qE 'Char Count.*60[^0-9]' '$AUDIT_FILE' || true"

# Edge Case: Very Short Descriptions (under 20 chars)
run_test "EDGE-4.1" "P2" "Audit identifies very short descriptions" \
    "grep -qE 'epic-dev-init\.md.*38' '$AUDIT_FILE'"

# Edge Case: Tools with Multiple MCP Dependencies
run_test "EDGE-5.1" "P2" "Audit handles multiple MCP servers for single tool" \
    "grep -qE 'digdeep\.md.*perplexity-ask.*exa.*ref' '$AUDIT_FILE'"

# Edge Case: Special Characters in Descriptions
run_test "EDGE-6.1" "P2" "Audit handles special characters in descriptions" \
    "grep -qE '\|.*CI/CD.*\|' '$AUDIT_FILE'"

# Edge Case: Hyphenated Tool Names
run_test "EDGE-7.1" "P2" "Audit correctly handles hyphenated tool names" \
    "grep -qE '^\|.*ci-orchestrate\.md.*\|' '$AUDIT_FILE'"

echo ""

# =============================================================================
# ERROR HANDLING & VALIDATION TESTS
# =============================================================================
echo -e "${BLUE}ERROR HANDLING & VALIDATION TESTS${NC}"
echo "========================================================"

# Data Validation: Character Count Accuracy
run_test "VAL-1.1" "P0" "Character counts match actual description lengths" \
    "grep -E 'pr\.md.*Simple PR workflow.*66' '$AUDIT_FILE' > /dev/null"

run_test "VAL-1.2" "P0" "Shortest description count is accurate (epic-dev-init: 38)" \
    "grep -E 'epic-dev-init\.md.*38' '$AUDIT_FILE' > /dev/null"

run_test "VAL-1.3" "P0" "Longest description count is accurate (digdeep: 153)" \
    "grep -E 'digdeep\.md.*153' '$AUDIT_FILE' > /dev/null"

# Data Validation: Verb-First Classification
run_test "VAL-2.1" "P1" "Verb-first 'Yes' count matches actual (18 tools)" \
    "[ \$(grep -cE '^\|[^|]*\|[^|]*\|[^|]*\|[^|]*\| Yes \|' '$AUDIT_FILE') -eq 18 ]"

run_test "VAL-2.2" "P1" "Verb-first 'No' count matches actual (5 tools)" \
    "[ \$(grep -cE '^\|[^|]*\|[^|]*\|[^|]*\|[^|]*\| No \|' '$AUDIT_FILE') -eq 5 ]"

# Data Validation: Tier Classification Completeness
run_test "VAL-3.1" "P0" "All 23 tools appear in tier sections" \
    "[ \$(awk '/## Tier Classification/,/^## [^T]/' '$AUDIT_FILE' | grep -cE '\.md') -ge 23 ]"

run_test "VAL-3.2" "P1" "Standalone tier has expected tools (7 tools)" \
    "[ \$(awk '/### Standalone/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -ge 6 ]"

run_test "VAL-3.3" "P1" "MCP-Enhanced tier has expected tools (4 tools)" \
    "[ \$(awk '/### MCP-Enhanced/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -ge 3 ]"

run_test "VAL-3.4" "P1" "BMAD-Required tier has expected tools (3 tools)" \
    "[ \$(awk '/### BMAD-Required/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -ge 3 ]"

run_test "VAL-3.5" "P1" "Project-Context tier has expected tools (9 tools)" \
    "[ \$(awk '/### Project-Context/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -ge 8 ]"

# Data Validation: MCP Server Name Format
run_test "VAL-4.1" "P1" "MCP server names use correct format (lowercase, hyphens)" \
    "grep -qE 'github|perplexity-ask|exa|ref|grep|semgrep-hosted|ide|browsermcp|bmad-method' '$AUDIT_FILE'"

run_test "VAL-4.2" "P2" "No MCP server names with incorrect casing" \
    "! grep -qE 'GitHub|GITHUB|Github' '$AUDIT_FILE' || true"

# Data Validation: Prerequisites Field
run_test "VAL-5.1" "P0" "Audit correctly identifies missing prerequisites (22 tools)" \
    "grep -qE 'Tools with prerequisites field: 1/23' '$AUDIT_FILE'"

run_test "VAL-5.2" "P1" "pr-workflow.md correctly shows '—' prerequisite" \
    "grep -qE 'pr-workflow\.md.*—' '$AUDIT_FILE'"

# Error Detection: Overlength Descriptions
run_test "VAL-6.1" "P1" "Audit identifies all 18 overlength descriptions" \
    "[ \$(awk '/## Issues Found/,0' '$AUDIT_FILE' | grep -cE 'OVER by') -ge 16 ]"

run_test "VAL-6.2" "P1" "Audit calculates correct overlength amount for digdeep (93 chars over)" \
    "grep -qE 'digdeep\.md.*OVER by 93' '$AUDIT_FILE'"

# Error Detection: Non-Verb-First Descriptions
run_test "VAL-7.1" "P1" "Audit identifies all 5 non-verb-first descriptions" \
    "[ \$(awk '/Non-Verb-First/,/Tools with correct/' '$AUDIT_FILE' | grep -cE '^\s*-.*\.md:') -ge 5 ]"

run_test "VAL-7.2" "P1" "Audit suggests verb-first alternatives for flagged tools" \
    "grep -qE 'Should start with verb like' '$AUDIT_FILE'"

echo ""

# =============================================================================
# INTEGRATION & CROSS-REFERENCE TESTS
# =============================================================================
echo -e "${BLUE}INTEGRATION & CROSS-REFERENCE TESTS${NC}"
echo "========================================================"

# Integration: Inventory Table Consistency
run_test "INT-1.1" "P0" "All tools in inventory also in tier classification" \
    "for tool in \$(grep -oE '[a-z-]+\.md' '$AUDIT_FILE' | head -23 | sort -u); do \
        awk '/## Tier Classification/,0' '$AUDIT_FILE' | grep -q \"\$tool\" || exit 1; \
    done"

run_test "INT-1.2" "P1" "MCP-enhanced tools in inventory match MCP mapping section" \
    "grep -E '^\|.*pr\.md.*\|.*MCP-Enhanced.*\|' '$AUDIT_FILE' > /dev/null && \
     awk '/## MCP Server Mapping/,/^## /' '$AUDIT_FILE' | grep -q 'pr\.md'"

# Integration: Issue Count Matches Inventory
run_test "INT-2.1" "P1" "Missing prerequisites count (22) matches inventory data" \
    "[ \$(grep -cE '^\|[^|]*\|[^|]*\|[^|]*\|[^|]*\|[^|]*\| missing \|' '$AUDIT_FILE') -ge 20 ]"

run_test "INT-2.2" "P1" "Overlength description count matches char count column" \
    "[ \$(grep -cE '^\|[^|]*\|[^|]*\|[^|]*\| [6-9][1-9]|[1-9][0-9]{2,} \|' '$AUDIT_FILE') -ge 15 ]"

# Integration: Cross-Tool Dependencies
run_test "INT-3.1" "P2" "pr.md delegation to pr-workflow-manager is documented" \
    "grep -qE 'pr\.md.*via delegation to pr-workflow-manager' '$AUDIT_FILE'"

run_test "INT-3.2" "P2" "pr-workflow-manager MCP dependency matches pr.md" \
    "grep -qE 'pr-workflow-manager\.md.*github' '$AUDIT_FILE'"

# Integration: Tier Assignment Logic
run_test "INT-4.1" "P1" "Tools with 'github' MCP are in MCP-Enhanced tier" \
    "awk '/## MCP Server Mapping/,/^## /' '$AUDIT_FILE' | grep -E 'github' | while read line; do \
        tool=\$(echo \"\$line\" | grep -oE '[a-z-]+\.md'); \
        awk '/### MCP-Enhanced/,/^### /' '$AUDIT_FILE' | grep -q \"\$tool\" || exit 1; \
    done"

run_test "INT-4.2" "P1" "Tools with 'epic-dev' in name are in BMAD-Required tier" \
    "awk '/### BMAD-Required/,/^### /' '$AUDIT_FILE' | grep -q 'epic-dev'"

# Integration: Recommendation Alignment
run_test "INT-5.1" "P2" "Priority 1 recommendations address critical issues" \
    "awk '/Priority 1: Critical Fixes/,/Priority 2/' '$AUDIT_FILE' | grep -qE 'Add Prerequisites Field|Fix Description Format|Reduce Description Length'"

run_test "INT-5.2" "P2" "Next steps reference correct story numbers" \
    "awk '/## Next Steps/,0' '$AUDIT_FILE' | grep -qE 'Story 2\\.2|Story 2\\.3|Story 2\\.4'"

echo ""

# =============================================================================
# BOUNDARY CONDITION TESTS
# =============================================================================
echo -e "${BLUE}BOUNDARY CONDITION TESTS${NC}"
echo "========================================================"

# Boundary: Exact Tool Count
run_test "BOUND-1.1" "P0" "Inventory table has exactly 23 tool rows" \
    "[ \$(grep -cE '^\|[^-][^|]*\|[^|]*\|[^|]*\|[^|]*\|[^|]*\|[^|]*\|[^|]*\|' '$AUDIT_FILE') -eq 23 ]"

run_test "BOUND-1.2" "P0" "Command count in inventory is exactly 11" \
    "[ \$(grep -cE '^\|[^|]*\| command \|' '$AUDIT_FILE') -eq 11 ]"

run_test "BOUND-1.3" "P0" "Agent count in inventory is exactly 11" \
    "[ \$(grep -cE '^\|[^|]*\| agent \|' '$AUDIT_FILE') -eq 11 ]"

run_test "BOUND-1.4" "P0" "Skill count in inventory is exactly 1" \
    "[ \$(grep -cE '^\|[^|]*\| skill \|' '$AUDIT_FILE') -eq 1 ]"

# Boundary: Character Count Range
run_test "BOUND-2.1" "P2" "Minimum description length is 38 characters" \
    "! grep -qE 'Char Count.*\| [1-3][0-7] \|' '$AUDIT_FILE'"

run_test "BOUND-2.2" "P2" "Maximum description length is 153 characters" \
    "! grep -qE 'Char Count.*\| [2-9][0-9]{2,}|1[6-9][0-9]|15[4-9] \|' '$AUDIT_FILE'"

run_test "BOUND-2.3" "P1" "At least 5 tools under 60 character limit" \
    "[ \$(grep -cE '^\|[^|]*\|[^|]*\|[^|]*\| [1-5][0-9] \|' '$AUDIT_FILE') -ge 5 ]"

# Boundary: Tier Distribution
run_test "BOUND-3.1" "P2" "No tier has zero tools assigned" \
    "awk '/### Standalone/,/^### /' '$AUDIT_FILE' | grep -q '\.md' && \
     awk '/### MCP-Enhanced/,/^### /' '$AUDIT_FILE' | grep -q '\.md' && \
     awk '/### BMAD-Required/,/^### /' '$AUDIT_FILE' | grep -q '\.md' && \
     awk '/### Project-Context/,/^### /' '$AUDIT_FILE' | grep -q '\.md'"

run_test "BOUND-3.2" "P2" "No tier has more than 10 tools assigned" \
    "[ \$(awk '/### Standalone/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -le 10 ] && \
     [ \$(awk '/### MCP-Enhanced/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -le 10 ] && \
     [ \$(awk '/### BMAD-Required/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -le 10 ] && \
     [ \$(awk '/### Project-Context/,/^### /' '$AUDIT_FILE' | grep -cE '\.md') -le 10 ]"

# Boundary: MCP Server Count
run_test "BOUND-4.1" "P2" "At least 2 MCP servers documented" \
    "[ \$(awk '/## MCP Server Mapping/,/^## /' '$AUDIT_FILE' | grep -oE 'github|perplexity-ask|exa|ref|grep|semgrep-hosted|ide|browsermcp|bmad-method' | sort -u | wc -l) -ge 2 ]"

run_test "BOUND-4.2" "P2" "MCP mapping has between 2-10 tool entries" \
    "entries=\$(awk '/## MCP Server Mapping/,/^## /' '$AUDIT_FILE' | grep -cE '^\|[^-]'); \
     [ \$entries -ge 2 ] && [ \$entries -le 10 ]"

# Boundary: Issues Found Section
run_test "BOUND-5.1" "P1" "Issues found section has at least 3 critical issues" \
    "[ \$(awk '/Critical Issues/,/Enhancement Issues/' '$AUDIT_FILE' | grep -cE '^[0-9]+\\.') -ge 3 ]"

run_test "BOUND-5.2" "P2" "Issues are categorized by priority (Critical, Enhancement, Optimization)" \
    "grep -qE 'Critical Issues|Enhancement Issues|Optimization Issues' '$AUDIT_FILE'"

echo ""

# =============================================================================
# STRUCTURAL CONSISTENCY TESTS
# =============================================================================
echo -e "${BLUE}STRUCTURAL CONSISTENCY TESTS${NC}"
echo "========================================================"

# Structure: Section Order
run_test "STRUCT-1.1" "P1" "Sections appear in correct order" \
    "awk '/## Summary/{s=1} /## Inventory Table/{if(s==1)i=2} /## MCP Server Mapping/{if(i==2)m=3} /## Tier Classification/{if(m==3)t=4} /## Issues Found/{if(t==4)f=5} END{exit(f!=5)}' '$AUDIT_FILE'"

# Structure: Markdown Formatting
run_test "STRUCT-2.1" "P2" "All section headers use ## (level 2)" \
    "grep -qE '^## Summary|^## Inventory Table|^## MCP Server Mapping|^## Tier Classification|^## Issues Found' '$AUDIT_FILE'"

run_test "STRUCT-2.2" "P2" "Tier subsections use ### (level 3)" \
    "grep -qE '^### Standalone|^### MCP-Enhanced|^### BMAD-Required|^### Project-Context' '$AUDIT_FILE'"

# Structure: Table Formatting
run_test "STRUCT-3.1" "P1" "Inventory table has proper markdown table structure" \
    "grep -qE '^\|.*\|$' '$AUDIT_FILE' && grep -qE '^\|[-:]+\|[-:]+\|' '$AUDIT_FILE'"

run_test "STRUCT-3.2" "P2" "MCP mapping table has proper structure" \
    "awk '/## MCP Server Mapping/,/^## /' '$AUDIT_FILE' | grep -qE '^\|.*Tool.*\|.*MCP Server'"

# Structure: Validation Checklist
run_test "STRUCT-4.1" "P2" "Validation checklist exists and has checkboxes" \
    "grep -qE '## Validation Checklist' '$AUDIT_FILE' && grep -qE '^\- \[x\]' '$AUDIT_FILE'"

run_test "STRUCT-4.2" "P2" "All validation checklist items are checked" \
    "[ \$(awk '/## Validation Checklist/,/^## /' '$AUDIT_FILE' | grep -cE '^\- \[ \]') -eq 0 ]"

# Structure: Metadata Footer
run_test "STRUCT-5.1" "P2" "Audit includes audit date" \
    "grep -qE '\*\*Audit Date\*\*:' '$AUDIT_FILE'"

run_test "STRUCT-5.2" "P2" "Audit includes compliance rate" \
    "grep -qE '\*\*Compliance Rate\*\*:' '$AUDIT_FILE'"

echo ""

# =============================================================================
# DOCUMENTATION QUALITY TESTS
# =============================================================================
echo -e "${BLUE}DOCUMENTATION QUALITY TESTS${NC}"
echo "========================================================"

# Quality: Clear Issue Descriptions
run_test "QUAL-1.1" "P2" "Issues include tool names and specific problems" \
    "awk '/## Issues Found/,0' '$AUDIT_FILE' | grep -qE '\.md:.*→'"

# Quality: Actionable Recommendations
run_test "QUAL-2.1" "P2" "Recommendations include specific actions" \
    "awk '/Metadata Standardization Recommendations/,0' '$AUDIT_FILE' | grep -qE 'Add|Fix|Reduce|Standardize'"

# Quality: Examples Provided
run_test "QUAL-3.1" "P3" "Verb-first suggestions include examples" \
    "awk '/Non-Verb-First/,/Tools with correct/' '$AUDIT_FILE' | grep -qE 'Example:|→'"

# Quality: Notes and Clarifications
run_test "QUAL-4.1" "P3" "Multi-line description handling is documented" \
    "grep -qE '\*\*Note on multi-line descriptions\*\*:' '$AUDIT_FILE'"

run_test "QUAL-4.2" "P3" "Verb-first classification is clarified" \
    "grep -qE '\*\*Note on verb-first classification\*\*:' '$AUDIT_FILE'"

# Quality: Cross-References
run_test "QUAL-5.1" "P3" "Next steps reference upcoming stories" \
    "grep -qE 'Story 2\\.2.*Story 2\\.3.*Story 2\\.4' '$AUDIT_FILE'"

echo ""

# =============================================================================
# REGRESSION PREVENTION TESTS
# =============================================================================
echo -e "${BLUE}REGRESSION PREVENTION TESTS${NC}"
echo "========================================================"

# Regression: Tool File Changes
run_test "REG-1.1" "P3" "Audit timestamp indicates recent generation" \
    "grep -qE '2025-12-1[0-9]' '$AUDIT_FILE'"

# Regression: No Duplicate Entries
run_test "REG-2.1" "P1" "No tool appears twice in inventory table" \
    "[ \$(grep -oE '^\|[^|]+\|' '$AUDIT_FILE' | sort | uniq -d | wc -l) -eq 0 ]"

run_test "REG-2.2" "P2" "No MCP server appears with inconsistent naming" \
    "! grep -qE 'github|Github|GITHUB' '$AUDIT_FILE' | uniq | [ \$(wc -l) -ne 1 ]"

# Regression: File Completeness
run_test "REG-3.1" "P0" "Audit file is not truncated (has closing metadata)" \
    "tail -5 '$AUDIT_FILE' | grep -qE '\*\*Audit Date\*\*:|\*\*Tools Audited\*\*:|\*\*Compliance Rate\*\*:'"

# Regression: No Placeholder Text
run_test "REG-4.1" "P2" "No TODO or placeholder text in audit" \
    "! grep -qE 'TODO|FIXME|XXX|TBD|\?\?\?' '$AUDIT_FILE'"

run_test "REG-4.2" "P2" "No 'missing' or 'unknown' data in key fields" \
    "! grep -qE '^\|[^|]*\|[^|]*\| missing \|[^|]*\|[^|]*\|[^|]*\|[^|]*\|' '$AUDIT_FILE'"

echo ""

# =============================================================================
# SUMMARY
# =============================================================================
echo "========================================================"
echo "EXPANDED TEST SUMMARY"
echo "========================================================"
echo ""
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo "Total Tests: $TOTAL"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""
echo "By Priority:"
echo -e "  P0 (Critical):     ${GREEN}$P0_PASS pass${NC} / ${RED}$P0_FAIL fail${NC}"
echo -e "  P1 (Important):    ${GREEN}$P1_PASS pass${NC} / ${RED}$P1_FAIL fail${NC}"
echo -e "  P2 (Edge Cases):   ${GREEN}$P2_PASS pass${NC} / ${RED}$P2_FAIL fail${NC}"
echo -e "  P3 (Future-proof): ${GREEN}$P3_PASS pass${NC} / ${RED}$P3_FAIL fail${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}STATUS: ALL EXPANDED TESTS PASS!${NC}"
    exit 0
else
    echo -e "${RED}STATUS: $FAIL_COUNT test(s) failing${NC}"
    echo ""
    echo "Failed Tests:"
    for result in "${RESULTS[@]}"; do
        if [[ $result == FAIL* ]]; then
            echo "  - ${result#FAIL: }"
        fi
    done
    exit $FAIL_COUNT
fi
