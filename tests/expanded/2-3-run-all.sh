#!/bin/bash

# Master Test Runner: Story 2.3 - Agent Metadata Standardization
# Runs all test suites (P0, P1, P2, P3) and generates comprehensive report

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project root (computed dynamically, not hardcoded)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ATDD_DIR="$PROJECT_ROOT/tests/atdd"
EXPANDED_DIR="$PROJECT_ROOT/tests/expanded"

# Test suite files
P0_SUITE="$ATDD_DIR/2-3-standardize-agent-metadata.sh"
P1_SUITE="$EXPANDED_DIR/2-3-error-handling.sh"
P2_SUITE="$EXPANDED_DIR/2-3-edge-cases.sh"
P3_SUITE="$EXPANDED_DIR/2-3-integration.sh"

# Results
declare -A SUITE_RESULTS
declare -A SUITE_TESTS
declare -A SUITE_PASSED
declare -A SUITE_FAILED

echo "============================================================================="
echo -e "${CYAN}COMPREHENSIVE TEST SUITE: Story 2.3 - Agent Metadata Standardization${NC}"
echo "============================================================================="
echo ""
echo "Running all test priorities: P0 (Critical), P1 (Important), P2 (Edge), P3 (Optional)"
echo ""

# =============================================================================
# Run P0: ATDD Acceptance Criteria (Critical Path - Must Pass)
# =============================================================================

echo "============================================================================="
echo -e "${MAGENTA}P0: ATDD ACCEPTANCE CRITERIA (Critical Path - Must Pass)${NC}"
echo "============================================================================="
echo ""

if [[ -f "$P0_SUITE" ]]; then
    P0_OUTPUT=$("$P0_SUITE" 2>&1)
    P0_EXIT_CODE=$?
    echo "$P0_OUTPUT"

    # Extract test counts from output
    SUITE_TESTS["P0"]=$(echo "$P0_OUTPUT" | grep "Tests Run:" | awk '{print $3}')
    SUITE_PASSED["P0"]=$(echo "$P0_OUTPUT" | grep "Tests Passed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')
    SUITE_FAILED["P0"]=$(echo "$P0_OUTPUT" | grep "Tests Failed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')

    if [[ $P0_EXIT_CODE -eq 0 ]]; then
        SUITE_RESULTS["P0"]="PASS"
    else
        SUITE_RESULTS["P0"]="FAIL"
    fi
else
    echo -e "${RED}ERROR: P0 test suite not found at $P0_SUITE${NC}"
    SUITE_RESULTS["P0"]="MISSING"
fi

echo ""

# =============================================================================
# Run P1: Error Handling & Regression Prevention (Important - Should Pass)
# =============================================================================

echo "============================================================================="
echo -e "${MAGENTA}P1: ERROR HANDLING & REGRESSION PREVENTION (Important - Should Pass)${NC}"
echo "============================================================================="
echo ""

if [[ -f "$P1_SUITE" ]]; then
    P1_OUTPUT=$("$P1_SUITE" 2>&1)
    P1_EXIT_CODE=$?
    echo "$P1_OUTPUT"

    SUITE_TESTS["P1"]=$(echo "$P1_OUTPUT" | grep "Tests Run:" | awk '{print $3}')
    SUITE_PASSED["P1"]=$(echo "$P1_OUTPUT" | grep "Tests Passed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')
    SUITE_FAILED["P1"]=$(echo "$P1_OUTPUT" | grep "Tests Failed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')

    if [[ $P1_EXIT_CODE -eq 0 ]]; then
        SUITE_RESULTS["P1"]="PASS"
    else
        SUITE_RESULTS["P1"]="FAIL"
    fi
else
    echo -e "${RED}ERROR: P1 test suite not found at $P1_SUITE${NC}"
    SUITE_RESULTS["P1"]="MISSING"
fi

echo ""

# =============================================================================
# Run P2: Edge Cases & Boundary Conditions (Good to Have)
# =============================================================================

echo "============================================================================="
echo -e "${MAGENTA}P2: EDGE CASES & BOUNDARY CONDITIONS (Good to Have)${NC}"
echo "============================================================================="
echo ""

if [[ -f "$P2_SUITE" ]]; then
    P2_OUTPUT=$("$P2_SUITE" 2>&1)
    P2_EXIT_CODE=$?
    echo "$P2_OUTPUT"

    SUITE_TESTS["P2"]=$(echo "$P2_OUTPUT" | grep "Tests Run:" | awk '{print $3}')
    SUITE_PASSED["P2"]=$(echo "$P2_OUTPUT" | grep "Tests Passed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')
    SUITE_FAILED["P2"]=$(echo "$P2_OUTPUT" | grep "Tests Failed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')

    if [[ $P2_EXIT_CODE -eq 0 ]]; then
        SUITE_RESULTS["P2"]="PASS"
    else
        SUITE_RESULTS["P2"]="YELLOW"
    fi
else
    echo -e "${RED}ERROR: P2 test suite not found at $P2_SUITE${NC}"
    SUITE_RESULTS["P2"]="MISSING"
fi

echo ""

# =============================================================================
# Run P3: Integration & Future-Proofing (Optional)
# =============================================================================

echo "============================================================================="
echo -e "${MAGENTA}P3: INTEGRATION & FUTURE-PROOFING (Optional)${NC}"
echo "============================================================================="
echo ""

if [[ -f "$P3_SUITE" ]]; then
    P3_OUTPUT=$("$P3_SUITE" 2>&1)
    P3_EXIT_CODE=$?
    echo "$P3_OUTPUT"

    SUITE_TESTS["P3"]=$(echo "$P3_OUTPUT" | grep "Tests Run:" | awk '{print $3}')
    SUITE_PASSED["P3"]=$(echo "$P3_OUTPUT" | grep "Tests Passed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')
    SUITE_FAILED["P3"]=$(echo "$P3_OUTPUT" | grep "Tests Failed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $3}')

    if [[ $P3_EXIT_CODE -eq 0 ]]; then
        SUITE_RESULTS["P3"]="PASS"
    else
        SUITE_RESULTS["P3"]="YELLOW"
    fi
else
    echo -e "${RED}ERROR: P3 test suite not found at $P3_SUITE${NC}"
    SUITE_RESULTS["P3"]="MISSING"
fi

# =============================================================================
# Generate Comprehensive Summary
# =============================================================================

echo ""
echo "============================================================================="
echo -e "${CYAN}COMPREHENSIVE TEST SUMMARY${NC}"
echo "============================================================================="
echo ""

# Calculate totals
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0

for priority in P0 P1 P2 P3; do
    tests=${SUITE_TESTS[$priority]:-0}
    passed=${SUITE_PASSED[$priority]:-0}
    failed=${SUITE_FAILED[$priority]:-0}

    TOTAL_TESTS=$((TOTAL_TESTS + tests))
    TOTAL_PASSED=$((TOTAL_PASSED + passed))
    TOTAL_FAILED=$((TOTAL_FAILED + failed))
done

# Per-suite summary
echo "Test Suites by Priority:"
echo ""
echo "┌──────────┬────────┬────────┬────────┬────────────┐"
echo "│ Priority │ Tests  │ Passed │ Failed │ Status     │"
echo "├──────────┼────────┼────────┼────────┼────────────┤"

for priority in P0 P1 P2 P3; do
    tests=${SUITE_TESTS[$priority]:-0}
    passed=${SUITE_PASSED[$priority]:-0}
    failed=${SUITE_FAILED[$priority]:-0}
    status=${SUITE_RESULTS[$priority]:-"UNKNOWN"}

    # Color code status
    case $status in
        "PASS")
            status_colored="${GREEN}PASS${NC}"
            ;;
        "FAIL")
            status_colored="${RED}FAIL${NC}"
            ;;
        "YELLOW")
            status_colored="${YELLOW}YELLOW${NC}"
            ;;
        "MISSING")
            status_colored="${RED}MISSING${NC}"
            ;;
        *)
            status_colored="${YELLOW}UNKNOWN${NC}"
            ;;
    esac

    printf "│ %-8s │ %6d │ %6d │ %6d │ %-18s │\n" "$priority" "$tests" "$passed" "$failed" "$(echo -e "$status_colored")"
done

echo "└──────────┴────────┴────────┴────────┴────────────┘"
echo ""

# Overall summary
echo "Overall Totals:"
echo ""
echo "  Total Tests:    $TOTAL_TESTS"
echo -e "  Tests Passed:   ${GREEN}$TOTAL_PASSED${NC}"
echo -e "  Tests Failed:   ${RED}$TOTAL_FAILED${NC}"

if [[ $TOTAL_TESTS -gt 0 ]]; then
    PASS_RATE=$((TOTAL_PASSED * 100 / TOTAL_TESTS))
    echo "  Pass Rate:      $PASS_RATE%"
fi

echo ""

# Critical tests status
CRITICAL_TESTS=$((${SUITE_TESTS["P0"]:-0} + ${SUITE_TESTS["P1"]:-0}))
CRITICAL_PASSED=$((${SUITE_PASSED["P0"]:-0} + ${SUITE_PASSED["P1"]:-0}))

echo "Critical Path (P0 + P1):"
echo "  Tests:    $CRITICAL_TESTS"
echo -e "  Passed:   ${GREEN}$CRITICAL_PASSED${NC}"

if [[ $CRITICAL_PASSED -eq $CRITICAL_TESTS ]]; then
    echo -e "  Status:   ${GREEN}✓ ALL CRITICAL TESTS PASSING${NC}"
else
    echo -e "  Status:   ${RED}✗ CRITICAL FAILURES DETECTED${NC}"
fi

echo ""
echo "============================================================================="

# Determine overall build status
if [[ "${SUITE_RESULTS["P0"]}" == "PASS" && "${SUITE_RESULTS["P1"]}" == "PASS" ]]; then
    if [[ $TOTAL_FAILED -eq 0 ]]; then
        echo -e "${GREEN}BUILD STATUS: PASS${NC} - All tests passing!"
        exit 0
    else
        echo -e "${YELLOW}BUILD STATUS: PASS WITH WARNINGS${NC} - Non-critical tests failing."
        exit 0
    fi
else
    echo -e "${RED}BUILD STATUS: FAIL${NC} - Critical tests failing."
    exit 1
fi
