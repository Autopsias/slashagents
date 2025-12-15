#!/bin/bash
# =============================================================================
# Master Test Runner for Story 2.2 Expanded Tests
# =============================================================================
# Runs all expanded test suites in priority order:
# - P0: ATDD tests (from tests/atdd/)
# - P1: Error handling & regression prevention
# - P2: Edge cases & boundary conditions
# - P3: Integration & future-proofing
# =============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ATDD_DIR="$PROJECT_ROOT/tests/atdd"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test suite tracking
SUITES_RUN=0
SUITES_PASSED=0
SUITES_FAILED=0

# Results tracking (using arrays instead of associative array for compatibility)
SUITE_NAMES=()
SUITE_STATUSES=()

# =============================================================================
# Helper Functions
# =============================================================================

run_suite() {
    local priority="$1"
    local suite_name="$2"
    local script_path="$3"

    SUITES_RUN=$((SUITES_RUN + 1))

    echo ""
    echo "============================================================================="
    echo -e "${BLUE}[$priority]${NC} Running: $suite_name"
    echo "============================================================================="

    if [[ ! -f "$script_path" ]]; then
        echo -e "${RED}ERROR:${NC} Test suite not found: $script_path"
        SUITES_FAILED=$((SUITES_FAILED + 1))
        SUITE_NAMES+=("$priority-$suite_name")
        SUITE_STATUSES+=("MISSING")
        return 1
    fi

    if ! bash "$script_path"; then
        echo -e "${RED}FAILED:${NC} $suite_name"
        SUITES_FAILED=$((SUITES_FAILED + 1))
        SUITE_NAMES+=("$priority-$suite_name")
        SUITE_STATUSES+=("FAILED")

        # P0 and P1 failures are critical
        if [[ "$priority" == "P0" ]] || [[ "$priority" == "P1" ]]; then
            return 1
        fi

        return 0 # P2 and P3 don't fail the build
    else
        echo -e "${GREEN}PASSED:${NC} $suite_name"
        SUITES_PASSED=$((SUITES_PASSED + 1))
        SUITE_NAMES+=("$priority-$suite_name")
        SUITE_STATUSES+=("PASSED")
        return 0
    fi
}

# =============================================================================
# Main Execution
# =============================================================================

echo "============================================================================="
echo "Story 2.2: Standardize Command Metadata - Expanded Test Suite"
echo "============================================================================="
echo "Project: CC_Agents_Commands"
echo "Story: 2-2-standardize-command-metadata"
echo "Test Phase: Comprehensive validation (P0 → P1 → P2 → P3)"
echo "============================================================================="

START_TIME=$(date +%s)

# =============================================================================
# P0: ATDD Tests (Critical Path - must pass)
# =============================================================================

run_suite "P0" "ATDD Acceptance Criteria" \
    "$ATDD_DIR/2-2-standardize-command-metadata.sh"

# =============================================================================
# P1: Error Handling & Regression (Important - should pass)
# =============================================================================

run_suite "P1" "Error Handling & Regression Prevention" \
    "$SCRIPT_DIR/2-2-error-handling.sh"

# =============================================================================
# P2: Edge Cases (Good to Have)
# =============================================================================

run_suite "P2" "Edge Cases & Boundary Conditions" \
    "$SCRIPT_DIR/2-2-edge-cases.sh"

# =============================================================================
# P3: Integration & Future-Proofing (Optional)
# =============================================================================

run_suite "P3" "Integration & Future-Proofing" \
    "$SCRIPT_DIR/2-2-integration.sh"

# =============================================================================
# Final Summary
# =============================================================================

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "============================================================================="
echo "COMPREHENSIVE TEST SUMMARY"
echo "============================================================================="
echo -e "Test Suites Run:    ${SUITES_RUN}"
echo -e "Test Suites Passed: ${GREEN}${SUITES_PASSED}${NC}"
echo -e "Test Suites Failed: ${RED}${SUITES_FAILED}${NC}"
echo -e "Duration:           ${DURATION}s"
echo "============================================================================="

# Detailed results by priority
echo ""
echo "Results by Priority:"
for i in "${!SUITE_NAMES[@]}"; do
    key="${SUITE_NAMES[$i]}"
    result="${SUITE_STATUSES[$i]}"
    priority="${key%%-*}"
    suite="${key#*-}"

    case "$result" in
        "PASSED")
            echo -e "  [$priority] ${GREEN}✓${NC} $suite"
            ;;
        "FAILED")
            echo -e "  [$priority] ${RED}✗${NC} $suite"
            ;;
        "MISSING")
            echo -e "  [$priority] ${YELLOW}?${NC} $suite (not found)"
            ;;
    esac
done

echo "============================================================================="

# Exit code determination
if [[ $SUITES_FAILED -gt 0 ]]; then
    # Check if failures are only in P2/P3 (non-critical)
    critical_failures=0

    for i in "${!SUITE_NAMES[@]}"; do
        key="${SUITE_NAMES[$i]}"
        result="${SUITE_STATUSES[$i]}"
        priority="${key%%-*}"

        if [[ "$result" == "FAILED" ]] && [[ "$priority" == "P0" || "$priority" == "P1" ]]; then
            critical_failures=$((critical_failures + 1))
        fi
    done

    if [[ $critical_failures -gt 0 ]]; then
        echo -e "\n${RED}BUILD FAILED:${NC} Critical test failures detected (P0 or P1)"
        exit 1
    else
        echo -e "\n${YELLOW}BUILD PASSED WITH WARNINGS:${NC} Only non-critical tests failed (P2 or P3)"
        exit 0
    fi
else
    echo -e "\n${GREEN}ALL TESTS PASSED!${NC} Story 2.2 implementation is complete and robust."
    exit 0
fi
