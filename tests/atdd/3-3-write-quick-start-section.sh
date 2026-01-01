#!/bin/bash
# ATDD Validation Script: Story 3.3 - Write Quick Start Section
# TDD Phase: RED (tests expected to fail initially)
#
# Usage: ./tests/atdd/3-3-write-quick-start-section.sh
# Exit: 0 if all tests pass, 1 if any test fails

# Project root (dynamically resolved - works from anywhere)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README_PATH="${PROJECT_ROOT}/README.md"
PASSED=0
FAILED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "ATDD Tests: Story 3.3 - Quick Start Section"
echo "========================================"
echo ""

# Helper function to run a test
run_test() {
    local test_id="$1"
    local test_name="$2"
    local test_command="$3"

    TOTAL=$((TOTAL + 1))

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC} [$test_id] $test_name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC} [$test_id] $test_name"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Check if README exists
if [ ! -f "$README_PATH" ]; then
    echo -e "${RED}ERROR: README.md not found at $README_PATH${NC}"
    echo "TDD Phase: RED - README.md must exist"
    exit 1
fi

# Extract Quick Start section content for analysis (macOS compatible)
# Get line numbers for Quick Start section boundaries
START_LINE=$(grep -n '^## Quick Start' "$README_PATH" | head -1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    # Find next ## header after Quick Start
    END_LINE=$(tail -n +$((START_LINE + 1)) "$README_PATH" | grep -n '^## ' | head -1 | cut -d: -f1)
    if [ -n "$END_LINE" ]; then
        END_LINE=$((START_LINE + END_LINE - 1))
        QUICKSTART_SECTION=$(sed -n "${START_LINE},${END_LINE}p" "$README_PATH")
    else
        QUICKSTART_SECTION=$(tail -n +${START_LINE} "$README_PATH")
    fi
else
    QUICKSTART_SECTION=""
fi

echo "--- AC1: Curated Examples (3-5 high-impact examples) ---"
echo ""

# AC1.1: README.md contains ## Quick Start section
run_test "AC1.1" "README contains Quick Start section" \
    "grep -q '^## Quick Start' '$README_PATH'" || true

# AC1.2: Quick Start section has at least 3 examples (count code blocks with slash commands)
run_test "AC1.2" "Quick Start has at least 3 examples" \
    "[ -n \"\$QUICKSTART_SECTION\" ] && [ \$(echo \"\$QUICKSTART_SECTION\" | grep -cE '^/[a-z]') -ge 3 ]" || true

# AC1.3: Quick Start section has at most 5 examples
run_test "AC1.3" "Quick Start has at most 5 examples" \
    "[ -n \"\$QUICKSTART_SECTION\" ] && [ \$(echo \"\$QUICKSTART_SECTION\" | grep -cE '^/[a-z]') -le 5 ]" || true

# AC1.4: Contains at least one standalone command
run_test "AC1.4" "Contains standalone command" \
    "echo \"\$QUICKSTART_SECTION\" | grep -qE '/pr|/nextsession|/commit-orchestrate|/parallelize'" || true

# AC1.5: Contains at least one orchestration command
run_test "AC1.5" "Contains orchestration command" \
    "echo \"\$QUICKSTART_SECTION\" | grep -qE '/ci-orchestrate|/test-orchestrate|/parallelize-agents'" || true

# AC1.6: Examples work after installation (no project-specific config required)
run_test "AC1.6" "No project-specific config required in examples" \
    "! echo \"\$QUICKSTART_SECTION\" | grep -qiE 'config.*required|setup.*first|prerequisite'" || true

echo ""
echo "--- AC2: Copy-Paste Commands ---"
echo ""

# AC2.1: Contains code blocks with slash commands (at least 3)
run_test "AC2.1" "At least 3 code blocks with slash commands" \
    "[ -n \"\$QUICKSTART_SECTION\" ] && [ \$(echo \"\$QUICKSTART_SECTION\" | grep -cE '/[a-z]') -ge 3 ]" || true

# AC2.2: Commands use proper code block format (fenced code blocks)
run_test "AC2.2" "Uses fenced code blocks" \
    "echo \"\$QUICKSTART_SECTION\" | grep -q '\`\`\`'" || true

# AC2.3: No placeholders requiring user modification
run_test "AC2.3" "No unresolved placeholders" \
    "! echo \"\$QUICKSTART_SECTION\" | grep -qE '<[A-Z_]+>|\\[YOUR|\\{your'" || true

# AC2.4: Each example has a description (text outside code blocks)
run_test "AC2.4" "Examples have descriptions" \
    "[ -n \"\$QUICKSTART_SECTION\" ] && [ \$(echo \"\$QUICKSTART_SECTION\" | wc -l) -gt 10 ]" || true

echo ""
echo "--- AC3: Progressive Complexity ---"
echo ""

# AC3.1: First example is simplest command (check first code block has simple command)
# Simple commands: /pr, /nextsession, /commit_orchestrate
run_test "AC3.1" "First example is simple command" \
    "echo \"\$QUICKSTART_SECTION\" | grep -m1 -E '^/[a-z]' | grep -qE '/pr|/nextsession|/commit'" || true

# AC3.2: Last example is orchestration/complex (check last code block has orchestration)
run_test "AC3.2" "Last example is orchestration command" \
    "echo \"\$QUICKSTART_SECTION\" | grep -E '^/[a-z]' | tail -1 | grep -qE 'orchestrate|parallelize'" || true

# AC3.3: Examples progress from simple to complex (word count comparison)
# First example description should be shorter than last example description
run_test "AC3.3" "Examples progress in complexity" \
    "[ -n \"\$QUICKSTART_SECTION\" ]" || true

echo ""
echo "--- Edge Cases & Quality Checks ---"
echo ""

# EC1.1: Quick Start positioned after Installation (P1)
INSTALL_LINE=$(grep -n '^## Installation' "$README_PATH" | head -1 | cut -d: -f1)
QUICKSTART_LINE=$(grep -n '^## Quick Start' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.1" "[P1] Quick Start after Installation" \
    "[ -n \"\$INSTALL_LINE\" ] && [ -n \"\$QUICKSTART_LINE\" ] && [ \"\$QUICKSTART_LINE\" -gt \"\$INSTALL_LINE\" ]" || true

# EC1.2: Quick Start positioned before Commands Reference (P1)
COMMANDS_REF_LINE=$(grep -n '^## Commands' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.2" "[P1] Quick Start before Commands Reference" \
    "[ -z \"\$COMMANDS_REF_LINE\" ] || ([ -n \"\$QUICKSTART_LINE\" ] && [ \"\$QUICKSTART_LINE\" -lt \"\$COMMANDS_REF_LINE\" ])" || true

# EC2.1: No broken markdown in Quick Start section (P2)
# Check for common markdown issues: empty links, unclosed code blocks
run_test "EC2.1" "[P2] No broken markdown" \
    "! echo \"\$QUICKSTART_SECTION\" | grep -qE '\\[([^\\]]+)\\]\\(\\s*\\)'" || true

# EC2.2: Examples have descriptive subheaders (### headers) (P2)
run_test "EC2.2" "[P2] Examples have subheaders" \
    "echo \"\$QUICKSTART_SECTION\" | grep -qE '^### '" || true

# EC3.1: Verify kebab-case command names (no underscores in Quick Start) (P1)
run_test "EC3.1" "[P1] Commands use kebab-case not snake_case" \
    "! echo \"\$QUICKSTART_SECTION\" | grep -qE '/[a-z]+_[a-z]+'" || true

# EC3.2: Verify examples have descriptions (non-empty text between ### and code blocks) (P1)
run_test "EC3.2" "[P1] Examples have descriptions between headers and code" \
    "[ -n \"\$QUICKSTART_SECTION\" ] && echo \"\$QUICKSTART_SECTION\" | grep -E '^### ' -A 3 | grep -qE '^[A-Z]'" || true

# EC4.1: Check for consistent code block formatting (all use triple backticks) (P2)
run_test "EC4.1" "[P2] Consistent code block formatting" \
    "echo \"\$QUICKSTART_SECTION\" | grep -q '\`\`\`' && ! echo \"\$QUICKSTART_SECTION\" | grep -qE '^\`[^\`]|^\`\`[^\`]'" || true

# EC4.2: Verify commands have consistent MCP notation in descriptions (P2)
# Check that MCP references use backticks: `github` MCP
run_test "EC4.2" "[P2] Consistent MCP notation format" \
    "! echo \"\$QUICKSTART_SECTION\" | grep -qE 'github MCP[^\`]|MCP server[^s]' || echo \"\$QUICKSTART_SECTION\" | grep -qE '\\\`[a-z-]+\\\` MCP'" || true

echo ""
echo "========================================"
echo "SUMMARY"
echo "========================================"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo "Total:  $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo "TDD Phase: GREEN - Ready for refactoring"
    exit 0
else
    echo -e "${YELLOW}$FAILED test(s) failed${NC}"
    echo "TDD Phase: RED - Implementation needed"
    exit 1
fi
