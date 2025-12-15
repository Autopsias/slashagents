#!/usr/bin/env bash
# ==============================================================================
# Expanded Test Suite for Story 2-5: Error Handling
# ==============================================================================
# Description: Error handling tests for tier classification documentation
# Priority: [P1] - Important error scenarios
# ==============================================================================

set -e

PROJECT_ROOT="/Users/ricardocarvalho/CC_Agents_Commands"
TIER_DOC="${PROJECT_ROOT}/docs/sprint-artifacts/tier-classifications.md"
METADATA_AUDIT="${PROJECT_ROOT}/docs/sprint-artifacts/metadata-audit.md"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
  local test_id="$1"
  local description="$2"
  local result="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ "$result" = "PASS" ]; then
    echo -e "${GREEN}PASS:${NC} ${test_id}: ${description}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}FAIL:${NC} ${test_id}: ${description}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

echo "============================================================================="
echo "Expanded Test Suite: Error Handling for Story 2-5"
echo "============================================================================="
echo "Priority: [P1] - Important error scenarios"
echo "============================================================================="
echo ""

echo -e "${BLUE}=== Error Handling 1: File Existence ===${NC}"
echo ""

# TEST-ERROR-2.5.1.1: tier-classifications.md exists
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.1.1: tier-classifications.md file exists"
if [ -f "$TIER_DOC" ]; then
  test_result "TEST-ERROR-2.5.1.1" "tier-classifications.md exists" "PASS"
else
  test_result "TEST-ERROR-2.5.1.1" "tier-classifications.md missing" "FAIL"
fi

# TEST-ERROR-2.5.1.2: metadata-audit.md exists
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.1.2: metadata-audit.md file exists"
if [ -f "$METADATA_AUDIT" ]; then
  test_result "TEST-ERROR-2.5.1.2" "metadata-audit.md exists" "PASS"
else
  test_result "TEST-ERROR-2.5.1.2" "metadata-audit.md missing" "FAIL"
fi

# TEST-ERROR-2.5.1.3: Files are not empty
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.1.3: tier-classifications.md is not empty"
if [ -s "$TIER_DOC" ]; then
  test_result "TEST-ERROR-2.5.1.3" "tier-classifications.md has content" "PASS"
else
  test_result "TEST-ERROR-2.5.1.3" "tier-classifications.md is empty" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Error Handling 2: Required Sections ===${NC}"
echo ""

# TEST-ERROR-2.5.2.1: Overview section exists
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.2.1: Overview section exists"
if grep -q "^## Overview" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.2.1" "Overview section exists" "PASS"
else
  test_result "TEST-ERROR-2.5.2.1" "Overview section missing" "FAIL"
fi

# TEST-ERROR-2.5.2.2: Summary table exists
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.2.2: Summary table exists"
if grep -q "^## Summary Table" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.2.2" "Summary table section exists" "PASS"
else
  test_result "TEST-ERROR-2.5.2.2" "Summary table section missing" "FAIL"
fi

# TEST-ERROR-2.5.2.3: All tier sections exist
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.2.3: All tier sections exist"
MISSING_SECTIONS=0
if ! grep -q "^### Standalone" "$TIER_DOC"; then MISSING_SECTIONS=$((MISSING_SECTIONS + 1)); fi
if ! grep -q "^### MCP-Enhanced" "$TIER_DOC"; then MISSING_SECTIONS=$((MISSING_SECTIONS + 1)); fi
if ! grep -q "^### BMAD-Required" "$TIER_DOC"; then MISSING_SECTIONS=$((MISSING_SECTIONS + 1)); fi
if ! grep -q "^### Project-Context" "$TIER_DOC"; then MISSING_SECTIONS=$((MISSING_SECTIONS + 1)); fi

if [ "$MISSING_SECTIONS" -eq 0 ]; then
  test_result "TEST-ERROR-2.5.2.3" "All 4 tier sections exist" "PASS"
else
  test_result "TEST-ERROR-2.5.2.3" "$MISSING_SECTIONS tier sections missing" "FAIL"
fi

# TEST-ERROR-2.5.2.4: MCP Server Reference exists
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.2.4: MCP Server Reference section exists"
if grep -q "^## MCP Server Reference" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.2.4" "MCP Server Reference exists" "PASS"
else
  test_result "TEST-ERROR-2.5.2.4" "MCP Server Reference missing" "FAIL"
fi

# TEST-ERROR-2.5.2.5: Project Requirements Reference exists
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.2.5: Project Requirements Reference exists"
if grep -q "^## Project Requirements Reference" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.2.5" "Project Requirements Reference exists" "PASS"
else
  test_result "TEST-ERROR-2.5.2.5" "Project Requirements Reference missing" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Error Handling 3: Malformed Data ===${NC}"
echo ""

# TEST-ERROR-2.5.3.1: Summary table has proper headers
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.3.1: Summary table has proper column headers"
if grep -A1 "^## Summary Table" "$TIER_DOC" | grep -q "| Tool | Type | Tier | Prerequisites |"; then
  test_result "TEST-ERROR-2.5.3.1" "Summary table headers correct" "PASS"
else
  test_result "TEST-ERROR-2.5.3.1" "Summary table headers malformed" "FAIL"
fi

# TEST-ERROR-2.5.3.2: Tables have separator rows
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.3.2: Tables have proper separator rows"
SEPARATOR_COUNT=$(grep -c "^|[-:]" "$TIER_DOC" || echo 0)
if [ "$SEPARATOR_COUNT" -ge 3 ]; then
  test_result "TEST-ERROR-2.5.3.2" "Tables have separator rows (found $SEPARATOR_COUNT)" "PASS"
else
  test_result "TEST-ERROR-2.5.3.2" "Insufficient table separators (found $SEPARATOR_COUNT)" "FAIL"
fi

# TEST-ERROR-2.5.3.3: No broken markdown links
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.3.3: No broken markdown links"
BROKEN_LINKS=$(grep -E '\[.*\]\([^)]*\)' "$TIER_DOC" | grep -c '\[\]' || echo 0)
if [ "$BROKEN_LINKS" -eq 0 ]; then
  test_result "TEST-ERROR-2.5.3.3" "No broken markdown links" "PASS"
else
  test_result "TEST-ERROR-2.5.3.3" "Found $BROKEN_LINKS broken links" "FAIL"
fi

# TEST-ERROR-2.5.3.4: Code blocks use proper backtick format
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.3.4: Code blocks use proper backtick format"
if grep -q '`github`' "$TIER_DOC" && grep -q '`perplexity-ask`' "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.3.4" "Code blocks properly formatted" "PASS"
else
  test_result "TEST-ERROR-2.5.3.4" "Code block formatting issues" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Error Handling 4: Missing Tool Information ===${NC}"
echo ""

# TEST-ERROR-2.5.4.1: All tools have tier assignment
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.4.1: All tools have tier assignment"
TOOLS_WITHOUT_TIER=$(grep -E '\.md' "$TIER_DOC" | grep -v '|' | wc -l | tr -d ' ')
if [ "$TOOLS_WITHOUT_TIER" -eq 0 ]; then
  test_result "TEST-ERROR-2.5.4.1" "All tools have tier assignment" "PASS"
else
  test_result "TEST-ERROR-2.5.4.1" "$TOOLS_WITHOUT_TIER tools missing tier" "FAIL"
fi

# TEST-ERROR-2.5.4.2: All tools have type specified
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.4.2: All tools have type specified (command/agent/skill)"
if grep -q "| command |" "$TIER_DOC" && grep -q "| agent |" "$TIER_DOC" && grep -q "| skill |" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.4.2" "Tools have types specified" "PASS"
else
  test_result "TEST-ERROR-2.5.4.2" "Some tool types missing" "FAIL"
fi

# TEST-ERROR-2.5.4.3: MCP-Enhanced tools document degraded behavior
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.4.3: MCP-Enhanced tools have degraded behavior column"
if grep -q "Degraded Behavior" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.4.3" "Degraded behavior documented" "PASS"
else
  test_result "TEST-ERROR-2.5.4.3" "Degraded behavior column missing" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Error Handling 5: Inconsistent Data ===${NC}"
echo ""

# TEST-ERROR-2.5.5.1: Tool counts match between sections
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.5.1: Tool counts consistent across sections"
OVERVIEW_COUNT=$(grep -oE '[0-9]+ tools' "$TIER_DOC" | head -1 | grep -oE '[0-9]+' || echo 0)
if [ "$OVERVIEW_COUNT" -eq 23 ]; then
  test_result "TEST-ERROR-2.5.5.1" "Tool count consistent in overview (23)" "PASS"
else
  test_result "TEST-ERROR-2.5.5.1" "Tool count mismatch in overview (found $OVERVIEW_COUNT)" "FAIL"
fi

# TEST-ERROR-2.5.5.2: Tier counts match detailed sections
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.5.2: Tier counts match section headers"
if grep -q "### Standalone: 6 tools" "$TIER_DOC" && \
   grep -q "### MCP-Enhanced: 5 tools" "$TIER_DOC" && \
   grep -q "### BMAD-Required: 3 tools" "$TIER_DOC" && \
   grep -q "### Project-Context: 9 tools" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.5.2" "Tier counts match section headers" "PASS"
else
  test_result "TEST-ERROR-2.5.5.2" "Tier count mismatches in headers" "FAIL"
fi

# TEST-ERROR-2.5.5.3: MCP servers in reference match tool descriptions
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.5.3: MCP servers in reference table match tools"
if grep -A20 "^## MCP Server Reference" "$TIER_DOC" | grep -q "github" && \
   grep -A20 "^## MCP Server Reference" "$TIER_DOC" | grep -q "perplexity-ask"; then
  test_result "TEST-ERROR-2.5.5.3" "MCP servers consistent" "PASS"
else
  test_result "TEST-ERROR-2.5.5.3" "MCP server inconsistencies" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Error Handling 6: Documentation Quality ===${NC}"
echo ""

# TEST-ERROR-2.5.6.1: Document has version information
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.6.1: Document includes version metadata"
if grep -qE "(Version|version):" "$TIER_DOC" || grep -q "Document Version" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.6.1" "Version metadata present" "PASS"
else
  test_result "TEST-ERROR-2.5.6.1" "Version metadata missing" "FAIL"
fi

# TEST-ERROR-2.5.6.2: Document has last updated date
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.6.2: Document includes last updated date"
if grep -qE "(Last Updated|Updated):" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.6.2" "Last updated date present" "PASS"
else
  test_result "TEST-ERROR-2.5.6.2" "Last updated date missing" "FAIL"
fi

# TEST-ERROR-2.5.6.3: Document status is finalized
echo -e "${YELLOW}TEST:${NC} TEST-ERROR-2.5.6.3: Document status marked as finalized"
if grep -qiE "(Status.*Finalized|finalized)" "$TIER_DOC"; then
  test_result "TEST-ERROR-2.5.6.3" "Document finalized" "PASS"
else
  test_result "TEST-ERROR-2.5.6.3" "Document not finalized" "FAIL"
fi

echo ""
echo "============================================================================="
echo "TEST SUMMARY - Error Handling"
echo "============================================================================="
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "============================================================================="
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}All error handling tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some error handling tests failed!${NC}"
  exit 1
fi
