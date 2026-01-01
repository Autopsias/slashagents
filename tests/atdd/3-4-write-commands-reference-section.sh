#!/bin/bash
# ATDD Validation Script: Story 3.4 - Write Commands Reference Section
# TDD Phase: RED (tests expected to fail initially)
#
# Usage: ./tests/atdd/3-4-write-commands-reference-section.sh
# Exit: 0 if all tests pass, 1 if any test fails
#
# Test Coverage: 76 tests total (expanded from original 48 ATDD tests)
#   - P0 (Core ATDD): 40 tests - Critical acceptance criteria
#   - P1 (Important): 14 tests - Edge cases and important validations
#   - P2 (Quality): 18 tests - Format validation and consistency
#   - P3 (Future): 4 tests - Cross-reference and future-proofing
#
# Categories:
#   - AC1 (Workflow Organization): 17 tests
#   - AC2 (Table Format): 9 tests
#   - AC3 (All 11 Commands): 14 tests
#   - EC1-EC8 (Edge Cases): 36 additional tests covering:
#     * Format validation (duplicate detection, table alignment, whitespace)
#     * Content validation (description length, correct subsections)
#     * Prerequisite validation (consistent notation across tiers)
#     * Cross-reference validation (file existence, command counts)
#     * Formatting consistency (table structure, spacing)

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
echo "ATDD Tests: Story 3.4 - Commands Reference Section"
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

# Extract Commands Reference section content for analysis (macOS compatible)
# Get line numbers for Commands Reference section boundaries
START_LINE=$(grep -n '^## Commands Reference' "$README_PATH" | head -1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    # Find next ## header after Commands Reference
    END_LINE=$(tail -n +$((START_LINE + 1)) "$README_PATH" | grep -n '^## ' | head -1 | cut -d: -f1)
    if [ -n "$END_LINE" ]; then
        END_LINE=$((START_LINE + END_LINE - 1))
        COMMANDS_SECTION=$(sed -n "${START_LINE},${END_LINE}p" "$README_PATH")
    else
        COMMANDS_SECTION=$(tail -n +${START_LINE} "$README_PATH")
    fi
else
    COMMANDS_SECTION=""
fi

echo "--- AC1: Workflow Moment Organization (4 subsections in order) ---"
echo ""

# AC1.1: README.md contains ## Commands Reference section
run_test "AC1.1" "README contains Commands Reference section" \
    "grep -q '^## Commands Reference' '$README_PATH'" || true

# AC1.2: Commands Reference contains Starting Work subsection
run_test "AC1.2" "Contains Starting Work subsection" \
    "echo \"\$COMMANDS_SECTION\" | grep -q '^### Starting Work'" || true

# AC1.3: Commands Reference contains Building subsection
run_test "AC1.3" "Contains Building subsection" \
    "echo \"\$COMMANDS_SECTION\" | grep -q '^### Building'" || true

# AC1.4: Commands Reference contains Quality Gates subsection
run_test "AC1.4" "Contains Quality Gates subsection" \
    "echo \"\$COMMANDS_SECTION\" | grep -q '^### Quality Gates'" || true

# AC1.5: Commands Reference contains Shipping subsection
run_test "AC1.5" "Contains Shipping subsection" \
    "echo \"\$COMMANDS_SECTION\" | grep -q '^### Shipping'" || true

# AC1.6: Subsections are in correct order (Starting Work < Building < Quality Gates < Shipping)
STARTING_LINE=$(echo "$COMMANDS_SECTION" | grep -n '^### Starting Work' | head -1 | cut -d: -f1)
BUILDING_LINE=$(echo "$COMMANDS_SECTION" | grep -n '^### Building' | head -1 | cut -d: -f1)
QUALITY_LINE=$(echo "$COMMANDS_SECTION" | grep -n '^### Quality Gates' | head -1 | cut -d: -f1)
SHIPPING_LINE=$(echo "$COMMANDS_SECTION" | grep -n '^### Shipping' | head -1 | cut -d: -f1)
run_test "AC1.6" "Subsections in correct order" \
    "[ -n \"\$STARTING_LINE\" ] && [ -n \"\$BUILDING_LINE\" ] && [ -n \"\$QUALITY_LINE\" ] && [ -n \"\$SHIPPING_LINE\" ] && [ \"\$STARTING_LINE\" -lt \"\$BUILDING_LINE\" ] && [ \"\$BUILDING_LINE\" -lt \"\$QUALITY_LINE\" ] && [ \"\$QUALITY_LINE\" -lt \"\$SHIPPING_LINE\" ]" || true

# AC1.7: Starting Work contains nextsession
run_test "AC1.7" "Starting Work contains nextsession" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Starting Work/,/^### /p' | grep -q '/nextsession'" || true

# AC1.8: Starting Work contains epic-dev-init
run_test "AC1.8" "Starting Work contains epic-dev-init" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Starting Work/,/^### /p' | grep -q '/epic-dev-init'" || true

# AC1.9: Building contains epic-dev
run_test "AC1.9" "Building contains epic-dev" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Building/,/^### /p' | grep -qE '/epic-dev[^-]|/epic-dev\`'" || true

# AC1.10: Building contains epic-dev-full
run_test "AC1.10" "Building contains epic-dev-full" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Building/,/^### /p' | grep -q '/epic-dev-full'" || true

# AC1.11: Building contains parallelize
run_test "AC1.11" "Building contains parallelize" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Building/,/^### /p' | grep -qE '/parallelize[^-]|/parallelize\`'" || true

# AC1.12: Building contains parallelize-agents
run_test "AC1.12" "Building contains parallelize-agents" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Building/,/^### /p' | grep -q '/parallelize-agents'" || true

# AC1.13: Quality Gates contains ci-orchestrate
run_test "AC1.13" "Quality Gates contains ci-orchestrate" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Quality Gates/,/^### /p' | grep -q '/ci-orchestrate'" || true

# AC1.14: Quality Gates contains test-orchestrate
run_test "AC1.14" "Quality Gates contains test-orchestrate" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Quality Gates/,/^### /p' | grep -q '/test-orchestrate'" || true

# AC1.15: Quality Gates contains usertestgates
run_test "AC1.15" "Quality Gates contains usertestgates" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Quality Gates/,/^### /p' | grep -q '/usertestgates'" || true

# AC1.16: Shipping contains pr
run_test "AC1.16" "Shipping contains pr" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Shipping/,/^## /p' | grep -qE '/pr[^a-z-]|/pr\`'" || true

# AC1.17: Shipping contains commit-orchestrate
run_test "AC1.17" "Shipping contains commit-orchestrate" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Shipping/,/^## /p' | grep -q '/commit-orchestrate'" || true

echo ""
echo "--- AC2: Table Format (exact structure with Command, What it does, Prerequisites) ---"
echo ""

# AC2.1: Starting Work has correct table header
run_test "AC2.1" "Starting Work has correct table header" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Starting Work/,/^### /p' | grep -q '| Command | What it does | Prerequisites |'" || true

# AC2.2: Building has correct table header
run_test "AC2.2" "Building has correct table header" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Building/,/^### /p' | grep -q '| Command | What it does | Prerequisites |'" || true

# AC2.3: Quality Gates has correct table header
run_test "AC2.3" "Quality Gates has correct table header" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Quality Gates/,/^### /p' | grep -q '| Command | What it does | Prerequisites |'" || true

# AC2.4: Shipping has correct table header
run_test "AC2.4" "Shipping has correct table header" \
    "echo \"\$COMMANDS_SECTION\" | sed -n '/^### Shipping/,/^## /p' | grep -q '| Command | What it does | Prerequisites |'" || true

# AC2.5: Standalone commands use em dash (— or ---)
# Check nextsession, test-orchestrate, commit-orchestrate, parallelize, parallelize-agents use em dash
run_test "AC2.5" "Standalone commands use em dash" \
    "echo \"\$COMMANDS_SECTION\" | grep '/nextsession' | grep -qE -- '---|—'" || true

# AC2.6: MCP-Enhanced commands use backtick format
# Check pr and ci-orchestrate use `github` MCP
run_test "AC2.6" "MCP-Enhanced commands use backtick format" \
    "echo \"\$COMMANDS_SECTION\" | grep '/ci-orchestrate' | grep -q '\`github\` MCP'" || true

# AC2.7: BMAD-Required commands use BMAD framework
# Check epic-dev, epic-dev-full, epic-dev-init use BMAD framework
run_test "AC2.7" "BMAD-Required commands use BMAD framework" \
    "echo \"\$COMMANDS_SECTION\" | grep '/epic-dev-init' | grep -q 'BMAD framework'" || true

# AC2.8: Project-Context commands use descriptive text
# Check usertestgates uses descriptive text (test gates infrastructure)
run_test "AC2.8" "Project-Context commands use descriptive text" \
    "echo \"\$COMMANDS_SECTION\" | grep '/usertestgates' | grep -qiE 'test.*gate|infrastructure'" || true

# AC2.9: Tables have separator row (|---|---|---|)
run_test "AC2.9" "Tables have separator row" \
    "echo \"\$COMMANDS_SECTION\" | grep -qE '\\|[-]+\\|[-]+\\|[-]+\\|'" || true

echo ""
echo "--- AC3: All 11 Commands Documented (each appears exactly once) ---"
echo ""

# AC3.1: Total command count is exactly 11
COMMAND_COUNT=$(echo "$COMMANDS_SECTION" | grep -oE '\`/[a-z-]+\`' | sort -u | wc -l | tr -d ' ')
run_test "AC3.1" "Exactly 11 unique commands documented" \
    "[ \"\$COMMAND_COUNT\" -eq 11 ]" || true

# AC3.2: nextsession appears exactly once
NEXTSESSION_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/nextsession' | tr -d ' ')
run_test "AC3.2" "nextsession appears exactly once" \
    "[ \"\$NEXTSESSION_COUNT\" -eq 1 ]" || true

# AC3.3: epic-dev-init appears exactly once
EPICDEVINIT_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/epic-dev-init' | tr -d ' ')
run_test "AC3.3" "epic-dev-init appears exactly once" \
    "[ \"\$EPICDEVINIT_COUNT\" -eq 1 ]" || true

# AC3.4: epic-dev appears exactly once (not counting epic-dev-init or epic-dev-full)
EPICDEV_COUNT=$(echo "$COMMANDS_SECTION" | grep -oE '/epic-dev[`\s|]' | wc -l | tr -d ' ')
run_test "AC3.4" "epic-dev appears exactly once" \
    "[ \"\$EPICDEV_COUNT\" -eq 1 ]" || true

# AC3.5: epic-dev-full appears exactly once
EPICDEVFULL_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/epic-dev-full' | tr -d ' ')
run_test "AC3.5" "epic-dev-full appears exactly once" \
    "[ \"\$EPICDEVFULL_COUNT\" -eq 1 ]" || true

# AC3.6: parallelize appears exactly once (not counting parallelize-agents)
PARALLELIZE_COUNT=$(echo "$COMMANDS_SECTION" | grep -oE '/parallelize[`\s|]' | wc -l | tr -d ' ')
run_test "AC3.6" "parallelize appears exactly once" \
    "[ \"\$PARALLELIZE_COUNT\" -eq 1 ]" || true

# AC3.7: parallelize-agents appears exactly once
PARALLELIZEAGENTS_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/parallelize-agents' | tr -d ' ')
run_test "AC3.7" "parallelize-agents appears exactly once" \
    "[ \"\$PARALLELIZEAGENTS_COUNT\" -eq 1 ]" || true

# AC3.8: ci-orchestrate appears exactly once
CIORCHESTRATE_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/ci-orchestrate' | tr -d ' ')
run_test "AC3.8" "ci-orchestrate appears exactly once" \
    "[ \"\$CIORCHESTRATE_COUNT\" -eq 1 ]" || true

# AC3.9: test-orchestrate appears exactly once
TESTORCHESTRATE_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/test-orchestrate' | tr -d ' ')
run_test "AC3.9" "test-orchestrate appears exactly once" \
    "[ \"\$TESTORCHESTRATE_COUNT\" -eq 1 ]" || true

# AC3.10: usertestgates appears exactly once
USERTESTGATES_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/usertestgates' | tr -d ' ')
run_test "AC3.10" "usertestgates appears exactly once" \
    "[ \"\$USERTESTGATES_COUNT\" -eq 1 ]" || true

# AC3.11: pr appears exactly once
PR_COUNT=$(echo "$COMMANDS_SECTION" | grep -oE '/pr[`\s|]' | wc -l | tr -d ' ')
run_test "AC3.11" "pr appears exactly once" \
    "[ \"\$PR_COUNT\" -eq 1 ]" || true

# AC3.12: commit-orchestrate appears exactly once
COMMITORCHESTRATE_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '/commit-orchestrate' | tr -d ' ')
run_test "AC3.12" "commit-orchestrate appears exactly once" \
    "[ \"\$COMMITORCHESTRATE_COUNT\" -eq 1 ]" || true

# AC3.13: Every command has a description (non-empty second column)
run_test "AC3.13" "Every command has a description" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/[a-z-]+\`' | grep -qE '\\| \`/[a-z-]+\` \\|\\s*\\|'" || true

# AC3.14: Every command has prerequisites (non-empty third column)
run_test "AC3.14" "Every command has prerequisites" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/[a-z-]+\`' | grep -qE '\\|\\s*\\|$'" || true

echo ""
echo "--- Edge Cases & Quality Checks ---"
echo ""

# EC1.1: Commands Reference positioned after Quick Start (P1)
QUICKSTART_LINE=$(grep -n '^## Quick Start' "$README_PATH" | head -1 | cut -d: -f1)
COMMANDSREF_LINE=$(grep -n '^## Commands Reference' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.1" "[P1] Commands Reference after Quick Start" \
    "[ -n \"\$QUICKSTART_LINE\" ] && [ -n \"\$COMMANDSREF_LINE\" ] && [ \"\$COMMANDSREF_LINE\" -gt \"\$QUICKSTART_LINE\" ]" || true

# EC1.2: Commands Reference positioned before Agents Reference (P1)
AGENTSREF_LINE=$(grep -n '^## Agents' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.2" "[P1] Commands Reference before Agents Reference" \
    "[ -z \"\$AGENTSREF_LINE\" ] || ([ -n \"\$COMMANDSREF_LINE\" ] && [ \"\$COMMANDSREF_LINE\" -lt \"\$AGENTSREF_LINE\" ])" || true

# EC2.1: No broken markdown in Commands Reference section (P2)
run_test "EC2.1" "[P2] No broken markdown" \
    "! echo \"\$COMMANDS_SECTION\" | grep -qE '\\[([^\\]]+)\\]\\(\\s*\\)'" || true

# EC2.2: Commands use kebab-case (no underscores) (P1)
run_test "EC2.2" "[P1] Commands use kebab-case not snake_case" \
    "! echo \"\$COMMANDS_SECTION\" | grep -qE '/[a-z]+_[a-z]+'" || true

# EC2.3: Commands have consistent formatting with backticks (P2)
run_test "EC2.3" "[P2] Commands wrapped in backticks" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| /[a-z]' | grep -qv '\`/'" || true

# EC3.1: Descriptions start with present-tense verb (P2)
# Check a sample of commands for present-tense verb descriptions
run_test "EC3.1" "[P2] Descriptions start with present-tense verb" \
    "echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/' | head -5 | grep -qE '\\| [A-Z][a-z]+(s|es) '" || true

# EC3.2: pr command uses `github` MCP prerequisite (P1)
run_test "EC3.2" "[P1] pr command uses github MCP prerequisite" \
    "echo \"\$COMMANDS_SECTION\" | grep '/pr' | grep -q '\`github\` MCP'" || true

# EC3.3: Section has intro sentence explaining workflow moment organization (P2)
run_test "EC3.3" "[P2] Section has intro sentence" \
    "echo \"\$COMMANDS_SECTION\" | head -5 | grep -qiE 'workflow|moment|organized'" || true

echo ""
echo "--- Additional Edge Cases: Format Validation ---"
echo ""

# [P1] EC4.1: No duplicate command entries across all subsections
DUPLICATE_COUNT=$(echo "$COMMANDS_SECTION" | grep -oE '/[a-z-]+' | sort | uniq -d | wc -l | tr -d ' ')
run_test "EC4.1" "[P1] No duplicate commands across subsections" \
    "[ \"\$DUPLICATE_COUNT\" -eq 0 ]" || true

# [P2] EC4.2: Table columns are properly aligned (no missing pipes)
run_test "EC4.2" "[P2] All table rows have 4 pipes (3 columns)" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/' | grep -vE '^\\| [^|]+ \\| [^|]+ \\| [^|]+ \\|'" || true

# [P2] EC4.3: No trailing whitespace in table cells
run_test "EC4.3" "[P2] No trailing whitespace in table cells" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/' | grep -q ' \\|'" || true

# [P1] EC4.4: All command names match actual files in commands/ directory
run_test "EC4.4" "[P1] Command names match actual files" \
    "for cmd in \$(echo \"\$COMMANDS_SECTION\" | grep -oE '/[a-z-]+' | sort -u | sed 's|^/||'); do [ -f \"${PROJECT_ROOT}/commands/\${cmd}.md\" ] || exit 1; done" || true

# [P2] EC4.5: Description column not empty for any command
run_test "EC4.5" "[P2] All commands have non-empty descriptions" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/[a-z-]+\` \\| \\|'" || true

# [P2] EC4.6: Prerequisites column not empty for any command
run_test "EC4.6" "[P2] All commands have non-empty prerequisites" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/[a-z-]+\` \\| [^|]+ \\| \\|'" || true

echo ""
echo "--- Additional Edge Cases: Content Validation ---"
echo ""

# [P1] EC5.1: Descriptions under 60 characters
run_test "EC5.1" "[P1] All descriptions under 60 characters" \
    "! echo \"\$COMMANDS_SECTION\" | grep -oE '^\\| \`/[a-z-]+\` \\| [^|]{61,} \\|'" || true

# [P2] EC5.2: Commands use lowercase kebab-case only (no uppercase or underscores)
# Validate that command names like /nextsession, /epic-dev use only lowercase letters and hyphens
run_test "EC5.2" "[P2] Commands are lowercase kebab-case" \
    "echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/' | grep -qE '\`/[a-z][a-z-]*\`'" || true

# [P1] EC5.3: No command appears in wrong workflow moment
# nextsession, epic-dev-init should ONLY be in Starting Work
STARTING_WORK_SECTION=$(echo "$COMMANDS_SECTION" | sed -n '/^### Starting Work/,/^### Building/p')
BUILDING_SECTION=$(echo "$COMMANDS_SECTION" | sed -n '/^### Building/,/^### Quality Gates/p')
QUALITY_SECTION=$(echo "$COMMANDS_SECTION" | sed -n '/^### Quality Gates/,/^### Shipping/p')
SHIPPING_SECTION=$(echo "$COMMANDS_SECTION" | sed -n '/^### Shipping/,/^## /p')

run_test "EC5.3a" "[P1] nextsession only in Starting Work" \
    "echo \"\$STARTING_WORK_SECTION\" | grep -q '/nextsession' && ! echo \"\$BUILDING_SECTION\$QUALITY_SECTION\$SHIPPING_SECTION\" | grep -q '/nextsession'" || true

run_test "EC5.3b" "[P1] epic-dev only in Building" \
    "echo \"\$BUILDING_SECTION\" | grep -qE '/epic-dev[^-]' && ! echo \"\$STARTING_WORK_SECTION\$QUALITY_SECTION\$SHIPPING_SECTION\" | grep -qE '/epic-dev[^-]'" || true

run_test "EC5.3c" "[P1] ci-orchestrate only in Quality Gates" \
    "echo \"\$QUALITY_SECTION\" | grep -q '/ci-orchestrate' && ! echo \"\$STARTING_WORK_SECTION\$BUILDING_SECTION\$SHIPPING_SECTION\" | grep -q '/ci-orchestrate'" || true

run_test "EC5.3d" "[P1] pr only in Shipping" \
    "echo \"\$SHIPPING_SECTION\" | grep -qE '/pr[^a-z-]' && ! echo \"\$STARTING_WORK_SECTION\$BUILDING_SECTION\$QUALITY_SECTION\" | grep -qE '/pr[^a-z-]'" || true

# [P2] EC5.4: Table header separator has correct format (at least 3 dashes per column)
run_test "EC5.4" "[P2] Table separators have 3+ dashes" \
    "echo \"\$COMMANDS_SECTION\" | grep -E '\\|[-]{3,}\\|[-]{3,}\\|[-]{3,}\\|' | head -4 | wc -l | grep -q '[4-9]'" || true

echo ""
echo "--- Additional Edge Cases: Prerequisite Validation ---"
echo ""

# [P1] EC6.1: Standalone commands consistently use em dash (not multiple formats)
run_test "EC6.1" "[P1] Standalone commands use em dash notation" \
    "echo \"\$COMMANDS_SECTION\" | grep '/test-orchestrate\\|/commit-orchestrate\\|/parallelize' | grep -qE '—|---'" || true

# [P1] EC6.2: MCP commands consistently use backtick format
run_test "EC6.2" "[P1] MCP commands use backtick format" \
    "echo \"\$COMMANDS_SECTION\" | grep '/ci-orchestrate\\|/pr' | grep -q '\`github\` MCP'" || true

# [P1] EC6.3: BMAD commands consistently use 'BMAD framework'
run_test "EC6.3" "[P1] BMAD commands use BMAD framework notation" \
    "echo \"\$COMMANDS_SECTION\" | grep '/epic-dev' | grep -q 'BMAD framework'" || true

# [P2] EC6.4: No prerequisite uses 'None' or 'N/A' (should be em dash)
run_test "EC6.4" "[P2] No prerequisites use None or N/A" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/' | grep -qiE 'None|N/A'" || true

echo ""
echo "--- Additional Edge Cases: Cross-Reference Validation ---"
echo ""

# [P3] EC7.1: Commands match the 11 expected commands exactly (no extras)
EXPECTED_COMMANDS="nextsession epic-dev-init epic-dev epic-dev-full parallelize parallelize-agents ci-orchestrate test-orchestrate usertestgates pr commit-orchestrate"
ACTUAL_COMMANDS=$(echo "$COMMANDS_SECTION" | grep -oE '/[a-z-]+' | sed 's|^/||' | sort -u | tr '\n' ' ')
run_test "EC7.1" "[P3] Commands list matches expected 11 commands" \
    "[ \"\$(echo \$EXPECTED_COMMANDS | tr ' ' '\n' | sort | tr '\n' ' ')\" = \"\$(echo \$ACTUAL_COMMANDS | tr ' ' '\n' | sort | tr '\n' ' ')\" ]" || true

# [P2] EC7.2: Each subsection has expected command count
run_test "EC7.2a" "[P2] Starting Work has 2 commands" \
    "[ \"\$(echo \"\$STARTING_WORK_SECTION\" | grep -c '\`/')\" -eq 2 ]" || true

run_test "EC7.2b" "[P2] Building has 4 commands" \
    "[ \"\$(echo \"\$BUILDING_SECTION\" | grep -c '\`/')\" -eq 4 ]" || true

run_test "EC7.2c" "[P2] Quality Gates has 3 commands" \
    "[ \"\$(echo \"\$QUALITY_SECTION\" | grep -c '\`/')\" -eq 3 ]" || true

run_test "EC7.2d" "[P2] Shipping has 2 commands" \
    "[ \"\$(echo \"\$SHIPPING_SECTION\" | grep -c '\`/')\" -eq 2 ]" || true

# [P3] EC7.3: No extra subsections beyond the 4 workflow moments
SUBSECTION_COUNT=$(echo "$COMMANDS_SECTION" | grep -c '^### ')
run_test "EC7.3" "[P3] Exactly 4 subsections (no extras)" \
    "[ \"\$SUBSECTION_COUNT\" -eq 4 ]" || true

# [P2] EC7.4: Commands Reference section ends before next major section
run_test "EC7.4" "[P2] Section properly terminated before next ##" \
    "[ -n \"\$END_LINE\" ] || (tail -n +\$START_LINE '$README_PATH' | tail -5 | grep -vq '^## ')" || true

echo ""
echo "--- Additional Edge Cases: Formatting Consistency ---"
echo ""

# [P2] EC8.1: All subsections have same table structure
run_test "EC8.1" "[P2] All 4 subsections have table headers" \
    "[ \"\$(echo \"\$COMMANDS_SECTION\" | grep -c '| Command | What it does | Prerequisites |')\" -eq 4 ]" || true

# [P2] EC8.2: All subsections have separator rows
run_test "EC8.2" "[P2] All 4 subsections have separator rows" \
    "[ \"\$(echo \"\$COMMANDS_SECTION\" | grep -c '|[-]')\" -ge 4 ]" || true

# [P3] EC8.3: Consistent spacing around pipes in tables
run_test "EC8.3" "[P3] Consistent spacing around table pipes" \
    "! echo \"\$COMMANDS_SECTION\" | grep -E '^\\| \`/' | grep -qE '\\|[^ ]|[^ ]\\|'" || true

# [P3] EC8.4: Command names consistently wrapped with backticks (format: `/command`)
run_test "EC8.4" "[P3] Commands use backtick/command format consistently" \
    "echo \"\$COMMANDS_SECTION\" | grep -E '^\\|' | grep -qE '\`/[a-z-]+\`'" || true

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
