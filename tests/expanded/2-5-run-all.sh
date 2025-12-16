#!/usr/bin/env bash
# ==============================================================================
# Test Runner: All Expanded Tests for Story 2-5
# ==============================================================================
# Description: Runs all expanded test suites for tier classifications
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test suite tracking
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

echo "============================================================================="
echo "Test Runner: All Expanded Tests for Story 2-5"
echo "============================================================================="
echo "Project: CC_Agents_Commands"
echo "Story: 2-5-document-tier-classifications"
echo "============================================================================="
echo ""

# Function to run a test suite
run_suite() {
  local suite_name="$1"
  local suite_script="$2"
  
  TOTAL_SUITES=$((TOTAL_SUITES + 1))
  
  echo -e "${CYAN}=== Running: $suite_name ===${NC}"
  echo ""
  
  if [ ! -f "$suite_script" ]; then
    echo -e "${RED}ERROR: Test suite not found: $suite_script${NC}"
    FAILED_SUITES=$((FAILED_SUITES + 1))
    return 1
  fi
  
  if "$suite_script"; then
    echo -e "${GREEN}✓ $suite_name PASSED${NC}"
    PASSED_SUITES=$((PASSED_SUITES + 1))
    echo ""
    return 0
  else
    echo -e "${RED}✗ $suite_name FAILED${NC}"
    FAILED_SUITES=$((FAILED_SUITES + 1))
    echo ""
    return 1
  fi
}

# Run all test suites
echo -e "${BLUE}Starting expanded test execution...${NC}"
echo ""

run_suite "Error Handling Tests [P1]" "$SCRIPT_DIR/2-5-error-handling.sh" || true
run_suite "Integration Tests [P0]" "$SCRIPT_DIR/2-5-integration.sh" || true
run_suite "Edge Case Tests [P2]" "$SCRIPT_DIR/2-5-edge-cases.sh" || true

echo "============================================================================="
echo "FINAL TEST SUMMARY - Story 2-5 Expanded Tests"
echo "============================================================================="
echo "Test Suites Run:    $TOTAL_SUITES"
echo -e "Test Suites Passed: ${GREEN}${PASSED_SUITES}${NC}"
echo -e "Test Suites Failed: ${RED}${FAILED_SUITES}${NC}"
echo "============================================================================="
echo ""

if [ $FAILED_SUITES -eq 0 ]; then
  echo -e "${GREEN}✓ All expanded test suites passed!${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}✗ Some test suites failed!${NC}"
  echo ""
  exit 1
fi
