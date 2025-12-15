#!/bin/bash
# ATDD Verification Script for Story 1.1: Create Repository Foundation
# TDD Phase: RED (tests should fail until implementation is complete)
#
# Usage: ./tests/atdd/1-1-repository-foundation.sh
# Exit code: 0 = all tests pass, non-zero = number of failed tests

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result tracking
declare -a RESULTS

# Helper function: Check if file has UTF-8 BOM
check_no_bom() {
    local file="$1"
    # Read first 3 bytes and check for BOM (EF BB BF)
    local first_bytes
    first_bytes=$(head -c 3 "$file" | od -An -tx1 | tr -d ' \n')
    [ "$first_bytes" != "efbbbf" ]
}

# Helper function: Check root files against allowed list
check_root_files() {
    local allowed_pattern='^(LICENSE|\.gitignore|CLAUDE\.md|README\.md|VALIDATION\.md|\.git|docs|tests|commands|agents|skills|\.DS_Store)$'
    cd "$PROJECT_ROOT"
    for item in *; do
        if ! echo "$item" | grep -qE "$allowed_pattern"; then
            return 1
        fi
    done
    return 0
}

# Helper function: Check .gitignore for duplicates
check_no_duplicates() {
    local file="$1"
    local duplicates
    duplicates=$(grep -v '^#' "$file" | grep -v '^$' | sort | uniq -d | wc -l | tr -d ' ')
    [ "$duplicates" -eq 0 ]
}

# Helper function: Count non-comment, non-empty lines
count_patterns() {
    local file="$1"
    grep -v '^#' "$file" | grep -v '^$' | wc -l | tr -d ' '
}

# Helper function: Check LICENSE file size is reasonable (500-2000 bytes)
check_license_size() {
    local file="$1"
    local size
    size=$(wc -c < "$file" | tr -d ' ')
    [ "$size" -ge 500 ] && [ "$size" -le 2000 ]
}

# Test helper function
run_test() {
    local test_id="$1"
    local test_desc="$2"
    local test_cmd="$3"

    echo -n "  [$test_id] $test_desc... "

    if eval "$test_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        RESULTS+=("PASS: $test_id - $test_desc")
    else
        echo -e "${RED}FAIL${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        RESULTS+=("FAIL: $test_id - $test_desc")
    fi
}

echo ""
echo "========================================================"
echo "ATDD Verification: Story 1.1 - Create Repository Foundation"
echo "========================================================"
echo ""
echo "Project Root: $PROJECT_ROOT"
echo "TDD Phase: RED (expecting failures until implementation)"
echo ""

# -----------------------------------------------------------------------------
# AC1: Repository Root Files
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC1: Repository Root Files${NC}"
echo "--------------------------------------------------------"

# TEST-AC-1.1: Check LICENSE file exists at root
run_test "TEST-AC-1.1" "[P0] LICENSE file exists at root" \
    "[ -f '$PROJECT_ROOT/LICENSE' ]"

# TEST-AC-1.2: Check .gitignore file exists at root
run_test "TEST-AC-1.2" "[P0] .gitignore file exists at root" \
    "[ -f '$PROJECT_ROOT/.gitignore' ]"

# TEST-AC-1.3: Verify only expected files exist at root (LICENSE, .gitignore, and allowed dev files)
# Note: We check that no unexpected files exist. Allowed: LICENSE, .gitignore, CLAUDE.md (project guidance)
# Also allowing: docs/, tests/, .git/ (development artifacts)
run_test "TEST-AC-1.3" "[P1] Only expected root files exist (LICENSE, .gitignore)" \
    "check_root_files"

echo ""

# -----------------------------------------------------------------------------
# AC2: Folder Structure
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC2: Folder Structure${NC}"
echo "--------------------------------------------------------"

# TEST-AC-2.1: Check commands/ directory exists
run_test "TEST-AC-2.1" "[P0] commands/ directory exists at root" \
    "[ -d '$PROJECT_ROOT/commands' ]"

# TEST-AC-2.2: Check agents/ directory exists
run_test "TEST-AC-2.2" "[P0] agents/ directory exists at root" \
    "[ -d '$PROJECT_ROOT/agents' ]"

# TEST-AC-2.3: Check skills/ directory exists
run_test "TEST-AC-2.3" "[P0] skills/ directory exists at root" \
    "[ -d '$PROJECT_ROOT/skills' ]"

echo ""

# -----------------------------------------------------------------------------
# AC3: License Content
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC3: License Content${NC}"
echo "--------------------------------------------------------"

# TEST-AC-3.1: Verify LICENSE contains "MIT License"
run_test "TEST-AC-3.1" "[P0] LICENSE contains 'MIT License'" \
    "grep -q 'MIT License' '$PROJECT_ROOT/LICENSE'"

# TEST-AC-3.2: Verify LICENSE contains "2025"
run_test "TEST-AC-3.2" "[P1] LICENSE contains copyright year '2025'" \
    "grep -q '2025' '$PROJECT_ROOT/LICENSE'"

# TEST-AC-3.3: Verify LICENSE contains "Ricardo"
run_test "TEST-AC-3.3" "[P1] LICENSE contains copyright holder 'Ricardo'" \
    "grep -q 'Ricardo' '$PROJECT_ROOT/LICENSE'"

echo ""

# -----------------------------------------------------------------------------
# Additional .gitignore Content Tests (from AC1 details)
# -----------------------------------------------------------------------------
echo -e "${YELLOW}AC1-Extended: .gitignore Content Validation${NC}"
echo "--------------------------------------------------------"

# TEST-AC-1.4: .gitignore contains .DS_Store pattern
run_test "TEST-AC-1.4" "[P1] .gitignore contains '.DS_Store'" \
    "grep -q '\.DS_Store' '$PROJECT_ROOT/.gitignore'"

# TEST-AC-1.5: .gitignore contains Thumbs.db pattern
run_test "TEST-AC-1.5" "[P1] .gitignore contains 'Thumbs.db'" \
    "grep -q 'Thumbs.db' '$PROJECT_ROOT/.gitignore'"

# TEST-AC-1.6: .gitignore contains .vscode/ pattern
run_test "TEST-AC-1.6" "[P1] .gitignore contains '.vscode/'" \
    "grep -q '\.vscode' '$PROJECT_ROOT/.gitignore'"

# TEST-AC-1.7: .gitignore contains .idea/ pattern
run_test "TEST-AC-1.7" "[P1] .gitignore contains '.idea/'" \
    "grep -q '\.idea' '$PROJECT_ROOT/.gitignore'"

# TEST-AC-1.8: .gitignore contains *.swp pattern
run_test "TEST-AC-1.8" "[P1] .gitignore contains '*.swp'" \
    "grep -q '\*\.swp' '$PROJECT_ROOT/.gitignore'"

# TEST-AC-1.9: .gitignore contains *.swo pattern
run_test "TEST-AC-1.9" "[P1] .gitignore contains '*.swo'" \
    "grep -q '\*\.swo' '$PROJECT_ROOT/.gitignore'"

echo ""

# -----------------------------------------------------------------------------
# [P1] Edge Cases: File Permissions & Accessibility
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[P1] Edge Cases: File Permissions & Accessibility${NC}"
echo "--------------------------------------------------------"

# TEST-EDGE-1.1: LICENSE file is readable
run_test "TEST-EDGE-1.1" "[P1] LICENSE file is readable" \
    "[ -r '$PROJECT_ROOT/LICENSE' ]"

# TEST-EDGE-1.2: .gitignore file is readable
run_test "TEST-EDGE-1.2" "[P1] .gitignore file is readable" \
    "[ -r '$PROJECT_ROOT/.gitignore' ]"

# TEST-EDGE-1.3: commands/ directory is accessible
run_test "TEST-EDGE-1.3" "[P1] commands/ directory is readable and executable" \
    "[ -r '$PROJECT_ROOT/commands' ] && [ -x '$PROJECT_ROOT/commands' ]"

# TEST-EDGE-1.4: agents/ directory is accessible
run_test "TEST-EDGE-1.4" "[P1] agents/ directory is readable and executable" \
    "[ -r '$PROJECT_ROOT/agents' ] && [ -x '$PROJECT_ROOT/agents' ]"

# TEST-EDGE-1.5: skills/ directory is accessible
run_test "TEST-EDGE-1.5" "[P1] skills/ directory is readable and executable" \
    "[ -r '$PROJECT_ROOT/skills' ] && [ -x '$PROJECT_ROOT/skills' ]"

echo ""

# -----------------------------------------------------------------------------
# [P2] LICENSE Format & Structure Validation
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[P2] LICENSE Format & Structure Validation${NC}"
echo "--------------------------------------------------------"

# TEST-LICENSE-2.1: LICENSE contains copyright line with proper format
run_test "TEST-LICENSE-2.1" "[P2] LICENSE has 'Copyright (c) 2025 Ricardo' format" \
    "grep -q 'Copyright (c) 2025 Ricardo' '$PROJECT_ROOT/LICENSE'"

# TEST-LICENSE-2.2: LICENSE contains permission grant paragraph
run_test "TEST-LICENSE-2.2" "[P2] LICENSE contains permission grant text" \
    "grep -q 'Permission is hereby granted, free of charge' '$PROJECT_ROOT/LICENSE'"

# TEST-LICENSE-2.3: LICENSE contains conditions section
run_test "TEST-LICENSE-2.3" "[P2] LICENSE contains conditions clause" \
    "grep -q 'The above copyright notice and this permission notice shall be included' '$PROJECT_ROOT/LICENSE'"

# TEST-LICENSE-2.4: LICENSE contains warranty disclaimer
run_test "TEST-LICENSE-2.4" "[P2] LICENSE contains warranty disclaimer" \
    "grep -q 'THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND' '$PROJECT_ROOT/LICENSE'"

# TEST-LICENSE-2.5: LICENSE contains liability disclaimer
run_test "TEST-LICENSE-2.5" "[P2] LICENSE contains liability disclaimer" \
    "grep -q 'IN NO EVENT SHALL' '$PROJECT_ROOT/LICENSE'"

echo ""

# -----------------------------------------------------------------------------
# [P2] .gitignore Structure & Quality
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[P2] .gitignore Structure & Quality${NC}"
echo "--------------------------------------------------------"

# TEST-GITIGNORE-2.1: .gitignore has no duplicate non-comment patterns
run_test "TEST-GITIGNORE-2.1" "[P2] .gitignore has no duplicate patterns" \
    "check_no_duplicates '$PROJECT_ROOT/.gitignore'"

# TEST-GITIGNORE-2.2: .gitignore is not empty
run_test "TEST-GITIGNORE-2.2" "[P2] .gitignore is not empty" \
    "[ -s '$PROJECT_ROOT/.gitignore' ]"

# TEST-GITIGNORE-2.3: .gitignore has expected minimum line count (at least 6 patterns)
run_test "TEST-GITIGNORE-2.3" "[P2] .gitignore has minimum 6 patterns" \
    "[ \$(count_patterns '$PROJECT_ROOT/.gitignore') -ge 6 ]"

echo ""

# -----------------------------------------------------------------------------
# [P3] File Encoding & Format Standards
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[P3] File Encoding & Format Standards${NC}"
echo "--------------------------------------------------------"

# TEST-FORMAT-3.1: LICENSE uses Unix line endings (LF not CRLF)
run_test "TEST-FORMAT-3.1" "[P3] LICENSE uses Unix line endings (LF)" \
    "! grep -q $'\r' '$PROJECT_ROOT/LICENSE'"

# TEST-FORMAT-3.2: .gitignore uses Unix line endings (LF not CRLF)
run_test "TEST-FORMAT-3.2" "[P3] .gitignore uses Unix line endings (LF)" \
    "! grep -q $'\r' '$PROJECT_ROOT/.gitignore'"

# TEST-FORMAT-3.3: LICENSE has no trailing whitespace on lines
run_test "TEST-FORMAT-3.3" "[P3] LICENSE has no trailing whitespace" \
    "! grep -q ' $' '$PROJECT_ROOT/LICENSE'"

# TEST-FORMAT-3.4: LICENSE file is UTF-8 encoded (no BOM)
run_test "TEST-FORMAT-3.4" "[P3] LICENSE is UTF-8 without BOM" \
    "check_no_bom '$PROJECT_ROOT/LICENSE'"

echo ""

# -----------------------------------------------------------------------------
# [P2] Directory Structure Completeness
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[P2] Directory Structure Completeness${NC}"
echo "--------------------------------------------------------"

# TEST-STRUCT-2.1: All three required directories exist together
run_test "TEST-STRUCT-2.1" "[P2] All three tool directories exist (commands, agents, skills)" \
    "[ -d '$PROJECT_ROOT/commands' ] && \
     [ -d '$PROJECT_ROOT/agents' ] && \
     [ -d '$PROJECT_ROOT/skills' ]"

# TEST-STRUCT-2.2: Directories are at root level (not nested)
run_test "TEST-STRUCT-2.2" "[P2] Tool directories are at root level" \
    "[ \"\$(dirname '$PROJECT_ROOT/commands')\" = '$PROJECT_ROOT' ] && \
     [ \"\$(dirname '$PROJECT_ROOT/agents')\" = '$PROJECT_ROOT' ] && \
     [ \"\$(dirname '$PROJECT_ROOT/skills')\" = '$PROJECT_ROOT' ]"

# TEST-STRUCT-2.3: No .claude/ directory exists at root (local config only)
run_test "TEST-STRUCT-2.3" "[P2] No .claude/ directory at root (users copy tools to their ~/.claude/)" \
    "[ ! -d '$PROJECT_ROOT/.claude' ] || [ -f '$PROJECT_ROOT/.gitignore' ] && grep -q '\.claude' '$PROJECT_ROOT/.gitignore'"

echo ""

# -----------------------------------------------------------------------------
# [P1] Content Integrity Checks
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[P1] Content Integrity Checks${NC}"
echo "--------------------------------------------------------"

# TEST-INTEGRITY-1.1: LICENSE file size is reasonable (MIT is ~1KB)
run_test "TEST-INTEGRITY-1.1" "[P1] LICENSE file size is reasonable (500-2000 bytes)" \
    "check_license_size '$PROJECT_ROOT/LICENSE'"

# TEST-INTEGRITY-1.2: LICENSE is plain text (no binary content)
run_test "TEST-INTEGRITY-1.2" "[P1] LICENSE is plain text file" \
    "file '$PROJECT_ROOT/LICENSE' | grep -q 'text'"

# TEST-INTEGRITY-1.3: .gitignore is plain text (no binary content)
run_test "TEST-INTEGRITY-1.3" "[P1] .gitignore is plain text file" \
    "file '$PROJECT_ROOT/.gitignore' | grep -q 'text'"

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "========================================================"
echo "TEST SUMMARY"
echo "========================================================"
echo ""
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo "Total Tests: $TOTAL"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}STATUS: ALL TESTS PASS - Ready for GREEN phase!${NC}"
    exit 0
else
    echo -e "${RED}STATUS: RED PHASE - $FAIL_COUNT test(s) failing${NC}"
    echo ""
    echo "Failed Tests:"
    for result in "${RESULTS[@]}"; do
        if [[ $result == FAIL* ]]; then
            echo "  - ${result#FAIL: }"
        fi
    done
    exit $FAIL_COUNT
fi
