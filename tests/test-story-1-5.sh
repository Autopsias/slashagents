#!/bin/bash
# Test Script for Story 1.5: Verify and Fix Cross-References
# This script validates that all cross-references between commands, agents, and skills
# use correct kebab-case naming and resolve to existing files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMANDS_DIR="$PROJECT_ROOT/commands"
AGENTS_DIR="$PROJECT_ROOT/agents"
SKILLS_DIR="$PROJECT_ROOT/skills"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Helper functions
pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARN_COUNT++))
}

info() {
    echo -e "[INFO] $1"
}

# Define expected agents (from story acceptance criteria)
EXPECTED_AGENTS=(
    "unit-test-fixer"
    "api-test-fixer"
    "database-test-fixer"
    "e2e-test-fixer"
    "linting-fixer"
    "type-error-fixer"
    "import-error-fixer"
    "security-scanner"
    "pr-workflow-manager"
    "parallel-executor"
    "digdeep"
)

# Define underscore variants that should NOT exist
UNDERSCORE_PATTERNS=(
    "unit_test_fixer"
    "api_test_fixer"
    "database_test_fixer"
    "e2e_test_fixer"
    "linting_fixer"
    "type_error_fixer"
    "import_error_fixer"
    "security_scanner"
    "pr_workflow_manager"
    "parallel_executor"
)

echo "=============================================="
echo "Story 1.5: Cross-Reference Verification Tests"
echo "=============================================="
echo ""

# =============================================================================
# TEST 1: Verify all expected agent files exist
# =============================================================================
echo "--- TEST 1: Agent Files Existence ---"
for agent in "${EXPECTED_AGENTS[@]}"; do
    if [[ -f "$AGENTS_DIR/$agent.md" ]]; then
        pass "Agent file exists: agents/$agent.md"
    else
        fail "Missing agent file: agents/$agent.md"
    fi
done
echo ""

# =============================================================================
# TEST 2: AC1 - CI Orchestrate References (kebab-case)
# =============================================================================
echo "--- TEST 2: AC1 - CI Orchestrate References ---"
CI_ORCHESTRATE_FILE="$COMMANDS_DIR/ci-orchestrate.md"

if [[ -f "$CI_ORCHESTRATE_FILE" ]]; then
    info "Checking ci-orchestrate.md for agent references..."

    # Check for correct kebab-case references
    AC1_AGENTS=("linting-fixer" "type-error-fixer" "unit-test-fixer" "import-error-fixer")
    for agent in "${AC1_AGENTS[@]}"; do
        if grep -q "$agent" "$CI_ORCHESTRATE_FILE"; then
            pass "ci-orchestrate.md references '$agent' (kebab-case)"
        else
            warn "ci-orchestrate.md does not reference '$agent'"
        fi
    done

    # Check for incorrect underscore references
    AC1_UNDERSCORE=("linting_fixer" "type_error_fixer" "unit_test_fixer" "import_error_fixer")
    for pattern in "${AC1_UNDERSCORE[@]}"; do
        if grep -q "$pattern" "$CI_ORCHESTRATE_FILE"; then
            fail "ci-orchestrate.md contains underscore reference: '$pattern'"
        else
            pass "ci-orchestrate.md does NOT contain underscore: '$pattern'"
        fi
    done
else
    fail "ci-orchestrate.md file not found"
fi
echo ""

# =============================================================================
# TEST 3: AC2 - Test Orchestrate References (kebab-case)
# =============================================================================
echo "--- TEST 3: AC2 - Test Orchestrate References ---"
TEST_ORCHESTRATE_FILE="$COMMANDS_DIR/test-orchestrate.md"

if [[ -f "$TEST_ORCHESTRATE_FILE" ]]; then
    info "Checking test-orchestrate.md for agent references..."

    # Check for correct kebab-case references
    AC2_AGENTS=("unit-test-fixer" "api-test-fixer" "database-test-fixer" "e2e-test-fixer")
    for agent in "${AC2_AGENTS[@]}"; do
        if grep -q "$agent" "$TEST_ORCHESTRATE_FILE"; then
            pass "test-orchestrate.md references '$agent' (kebab-case)"
        else
            warn "test-orchestrate.md does not reference '$agent'"
        fi
    done

    # Check for incorrect underscore references
    AC2_UNDERSCORE=("unit_test_fixer" "api_test_fixer" "database_test_fixer" "e2e_test_fixer")
    for pattern in "${AC2_UNDERSCORE[@]}"; do
        if grep -q "$pattern" "$TEST_ORCHESTRATE_FILE"; then
            fail "test-orchestrate.md contains underscore reference: '$pattern'"
        else
            pass "test-orchestrate.md does NOT contain underscore: '$pattern'"
        fi
    done
else
    fail "test-orchestrate.md file not found"
fi
echo ""

# =============================================================================
# TEST 4: AC3 - Parallelize Agents References (kebab-case)
# =============================================================================
echo "--- TEST 4: AC3 - Parallelize Agents References ---"
PARALLELIZE_AGENTS_FILE="$COMMANDS_DIR/parallelize-agents.md"

if [[ -f "$PARALLELIZE_AGENTS_FILE" ]]; then
    info "Checking parallelize-agents.md for agent references..."

    # Check for correct kebab-case reference
    if grep -q "parallel-executor" "$PARALLELIZE_AGENTS_FILE"; then
        pass "parallelize-agents.md references 'parallel-executor' (kebab-case)"
    else
        warn "parallelize-agents.md does not reference 'parallel-executor'"
    fi

    # Check for incorrect underscore reference
    if grep -q "parallel_executor" "$PARALLELIZE_AGENTS_FILE"; then
        fail "parallelize-agents.md contains underscore reference: 'parallel_executor'"
    else
        pass "parallelize-agents.md does NOT contain underscore: 'parallel_executor'"
    fi
else
    fail "parallelize-agents.md file not found"
fi
echo ""

# =============================================================================
# TEST 5: PR Workflow Skill References
# =============================================================================
echo "--- TEST 5: PR Workflow Skill References ---"
PR_WORKFLOW_FILE="$SKILLS_DIR/pr-workflow.md"

if [[ -f "$PR_WORKFLOW_FILE" ]]; then
    info "Checking pr-workflow.md for agent references..."

    # Check for correct kebab-case reference
    if grep -q "pr-workflow-manager" "$PR_WORKFLOW_FILE"; then
        pass "pr-workflow.md references 'pr-workflow-manager' (kebab-case)"
    else
        warn "pr-workflow.md does not reference 'pr-workflow-manager'"
    fi

    # Check for incorrect underscore reference
    if grep -q "pr_workflow_manager" "$PR_WORKFLOW_FILE"; then
        fail "pr-workflow.md contains underscore reference: 'pr_workflow_manager'"
    else
        pass "pr-workflow.md does NOT contain underscore: 'pr_workflow_manager'"
    fi
else
    fail "pr-workflow.md file not found"
fi
echo ""

# =============================================================================
# TEST 6: AC4 - No Broken References (scan all files)
# =============================================================================
echo "--- TEST 6: AC4 - No Broken References Across All Files ---"

info "Scanning all tool files for underscore-style agent references..."

# Check all commands for underscore patterns
for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [[ -f "$cmd_file" ]]; then
        filename=$(basename "$cmd_file")
        for pattern in "${UNDERSCORE_PATTERNS[@]}"; do
            if grep -q "$pattern" "$cmd_file"; then
                fail "commands/$filename contains underscore reference: '$pattern'"
            fi
        done
    fi
done

# Check all agents for underscore patterns (cross-references)
for agent_file in "$AGENTS_DIR"/*.md; do
    if [[ -f "$agent_file" ]]; then
        filename=$(basename "$agent_file")
        for pattern in "${UNDERSCORE_PATTERNS[@]}"; do
            if grep -q "$pattern" "$agent_file"; then
                fail "agents/$filename contains underscore reference: '$pattern'"
            fi
        done
    fi
done

# Check skill for underscore patterns
for skill_file in "$SKILLS_DIR"/*.md; do
    if [[ -f "$skill_file" ]]; then
        filename=$(basename "$skill_file")
        for pattern in "${UNDERSCORE_PATTERNS[@]}"; do
            if grep -q "$pattern" "$skill_file"; then
                fail "skills/$filename contains underscore reference: '$pattern'"
            fi
        done
    fi
done

if [[ $FAIL_COUNT -eq 0 ]]; then
    pass "No underscore-style agent references found in any tool files"
fi
echo ""

# =============================================================================
# TEST 7: Verify referenced agents resolve to existing files
# =============================================================================
echo "--- TEST 7: Agent Reference Resolution ---"

# Extract all agent references from files and verify they exist
info "Extracting agent references from ci-orchestrate.md..."

# ci-orchestrate references
CI_REFS=$(grep -oE '(linting|type-error|unit-test|import-error|api-test|database-test|e2e-test|security|parallel-executor)-fixer|security-scanner|parallel-executor|digdeep' "$COMMANDS_DIR/ci-orchestrate.md" 2>/dev/null | sort -u || true)
for ref in $CI_REFS; do
    if [[ -f "$AGENTS_DIR/$ref.md" ]]; then
        pass "Reference '$ref' in ci-orchestrate.md resolves to existing agent"
    else
        fail "Reference '$ref' in ci-orchestrate.md does NOT resolve to existing agent"
    fi
done

info "Extracting agent references from test-orchestrate.md..."

# test-orchestrate references
TEST_REFS=$(grep -oE '(unit-test|api-test|database-test|e2e-test|type-error|import-error)-fixer' "$COMMANDS_DIR/test-orchestrate.md" 2>/dev/null | sort -u || true)
for ref in $TEST_REFS; do
    if [[ -f "$AGENTS_DIR/$ref.md" ]]; then
        pass "Reference '$ref' in test-orchestrate.md resolves to existing agent"
    else
        fail "Reference '$ref' in test-orchestrate.md does NOT resolve to existing agent"
    fi
done

info "Extracting agent references from parallelize-agents.md..."

# parallelize-agents references
PARA_REFS=$(grep -oE '(unit-test|api-test|database-test|e2e-test|type-error|import-error|linting)-fixer|security-scanner|parallel-executor|digdeep' "$COMMANDS_DIR/parallelize-agents.md" 2>/dev/null | sort -u || true)
for ref in $PARA_REFS; do
    if [[ -f "$AGENTS_DIR/$ref.md" ]]; then
        pass "Reference '$ref' in parallelize-agents.md resolves to existing agent"
    else
        fail "Reference '$ref' in parallelize-agents.md does NOT resolve to existing agent"
    fi
done

info "Extracting agent references from pr-workflow.md skill..."

# pr-workflow skill references
if [[ -f "$SKILLS_DIR/pr-workflow.md" ]]; then
    SKILL_REFS=$(grep -oE 'pr-workflow-manager|ci-orchestrate|test-orchestrate' "$SKILLS_DIR/pr-workflow.md" 2>/dev/null | sort -u || true)
    for ref in $SKILL_REFS; do
        if [[ -f "$AGENTS_DIR/$ref.md" ]] || [[ -f "$COMMANDS_DIR/$ref.md" ]]; then
            pass "Reference '$ref' in pr-workflow.md resolves to existing file"
        else
            warn "Reference '$ref' in pr-workflow.md - may be command name (not file)"
        fi
    done
fi
echo ""

# =============================================================================
# TEST 8: [P0] Deep Underscore Pattern Scan - All File Content
# =============================================================================
echo "--- TEST 8: [P0] Deep Underscore Pattern Scan ---"

info "Scanning all markdown files for ANY underscore patterns in agent context..."

# Search for underscore patterns in various contexts (not just exact matches)
# This catches patterns like "unit_test_fixer.md" or "uses unit_test_fixer" etc.
DEEP_SCAN_PATTERNS=(
    "unit_test_fixer"
    "api_test_fixer"
    "database_test_fixer"
    "e2e_test_fixer"
    "linting_fixer"
    "type_error_fixer"
    "import_error_fixer"
    "security_scanner"
    "pr_workflow_manager"
    "parallel_executor"
)

DEEP_SCAN_FOUND=0

for file in "$COMMANDS_DIR"/*.md "$AGENTS_DIR"/*.md "$SKILLS_DIR"/*.md; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        dirname=$(basename "$(dirname "$file")")
        for pattern in "${DEEP_SCAN_PATTERNS[@]}"; do
            if grep -q "$pattern" "$file" 2>/dev/null; then
                fail "[P0] $dirname/$filename contains underscore pattern: '$pattern'"
                ((DEEP_SCAN_FOUND++))
            fi
        done
    fi
done

if [[ $DEEP_SCAN_FOUND -eq 0 ]]; then
    pass "[P0] No underscore patterns found in ANY tool files (deep scan)"
else
    fail "[P0] Found $DEEP_SCAN_FOUND underscore pattern violations across all files"
fi
echo ""

# =============================================================================
# TEST 9: [P0] Bidirectional Reference Validation - Commands to Agents
# =============================================================================
echo "--- TEST 9: [P0] Bidirectional Reference Validation ---"

info "Validating that all subagent_type references resolve to existing agents..."

# Extract all subagent_type values from command files
REFERENCED_AGENTS=()
for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [[ -f "$cmd_file" ]]; then
        # Extract subagent_type="..." values
        while IFS= read -r line; do
            if [[ "$line" =~ subagent_type=\"([^\"]+)\" ]]; then
                agent_ref="${BASH_REMATCH[1]}"
                REFERENCED_AGENTS+=("$agent_ref")
            fi
        done < "$cmd_file"
    fi
done

# Remove duplicates
UNIQUE_REFS=($(printf '%s\n' "${REFERENCED_AGENTS[@]}" | sort -u))

info "Found ${#UNIQUE_REFS[@]} unique agent references in command files"

for ref in "${UNIQUE_REFS[@]}"; do
    # Skip "general-purpose" as it's a special agent type
    if [[ "$ref" == "general-purpose" ]]; then
        pass "[P0] Reference '$ref' is a special agent type (allowed)"
        continue
    fi

    if [[ -f "$AGENTS_DIR/$ref.md" ]]; then
        pass "[P0] Reference '$ref' resolves to agents/$ref.md"
    else
        fail "[P0] Reference '$ref' does NOT resolve to any agent file"
    fi
done
echo ""

# =============================================================================
# TEST 10: [P1] Skill-to-Agent Reference Validation
# =============================================================================
echo "--- TEST 10: [P1] Skill-to-Agent Reference Validation ---"

info "Validating skill file references to agents and commands..."

if [[ -f "$SKILLS_DIR/pr-workflow.md" ]]; then
    # Check for pr-workflow-manager agent reference
    if grep -q "pr-workflow-manager" "$SKILLS_DIR/pr-workflow.md"; then
        if [[ -f "$AGENTS_DIR/pr-workflow-manager.md" ]]; then
            pass "[P1] Skill references pr-workflow-manager agent (exists)"
        else
            fail "[P1] Skill references pr-workflow-manager but agent file missing"
        fi
    fi

    # Check that skill does NOT use underscore format
    if grep -q "pr_workflow_manager" "$SKILLS_DIR/pr-workflow.md"; then
        fail "[P1] Skill uses underscore format: pr_workflow_manager"
    else
        pass "[P1] Skill does NOT use underscore format for agent references"
    fi

    # Validate any command references in skill
    SKILL_CMD_REFS=$(grep -oE '/[a-z-]+' "$SKILLS_DIR/pr-workflow.md" | grep -E '^/[a-z-]+$' | sort -u || true)
    for cmd_ref in $SKILL_CMD_REFS; do
        cmd_name="${cmd_ref:1}"  # Remove leading /
        if [[ -f "$COMMANDS_DIR/$cmd_name.md" ]]; then
            pass "[P1] Skill references command '$cmd_ref' (exists)"
        else
            warn "[P1] Skill references '$cmd_ref' but no matching command file"
        fi
    done
else
    fail "[P1] pr-workflow.md skill file not found"
fi
echo ""

# =============================================================================
# TEST 11: [P1] Cross-Agent References (Agents Referencing Other Agents)
# =============================================================================
echo "--- TEST 11: [P1] Cross-Agent References Validation ---"

info "Checking if any agents reference other agents..."

CROSS_AGENT_REFS=0
for agent_file in "$AGENTS_DIR"/*.md; do
    if [[ -f "$agent_file" ]]; then
        agent_name=$(basename "$agent_file")

        # Check if this agent references any other agents
        for other_agent in "${EXPECTED_AGENTS[@]}"; do
            if [[ "$agent_name" != "$other_agent.md" ]]; then
                if grep -q "$other_agent" "$agent_file" 2>/dev/null; then
                    info "[P1] Agent $agent_name references $other_agent"
                    ((CROSS_AGENT_REFS++))

                    # Verify it uses kebab-case (not underscore)
                    underscore_variant="${other_agent//-/_}"
                    if grep -q "$underscore_variant" "$agent_file" 2>/dev/null; then
                        fail "[P1] Agent $agent_name uses underscore format: $underscore_variant"
                    else
                        pass "[P1] Agent $agent_name correctly uses kebab-case: $other_agent"
                    fi
                fi
            fi
        done
    fi
done

if [[ $CROSS_AGENT_REFS -eq 0 ]]; then
    pass "[P1] No cross-agent references found (agents are self-contained)"
else
    info "[P1] Found $CROSS_AGENT_REFS cross-agent references"
fi
echo ""

# =============================================================================
# TEST 12: [P1] Validate All subagent_type Values Are Valid Agents
# =============================================================================
echo "--- TEST 12: [P1] All subagent_type Values Are Valid ---"

info "Extracting and validating all subagent_type declarations..."

INVALID_AGENTS=0
for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [[ -f "$cmd_file" ]]; then
        cmd_name=$(basename "$cmd_file")

        # Extract all subagent_type values
        while IFS= read -r line; do
            if [[ "$line" =~ subagent_type=\"([^\"]+)\" ]]; then
                agent_type="${BASH_REMATCH[1]}"

                # Skip special types
                if [[ "$agent_type" == "general-purpose" ]]; then
                    continue
                fi

                # Check if agent file exists
                if [[ -f "$AGENTS_DIR/$agent_type.md" ]]; then
                    pass "[P1] commands/$cmd_name declares valid agent: $agent_type"
                else
                    fail "[P1] commands/$cmd_name declares INVALID agent: $agent_type"
                    ((INVALID_AGENTS++))
                fi

                # Verify kebab-case (no underscores)
                if [[ "$agent_type" =~ _ ]]; then
                    fail "[P1] commands/$cmd_name uses underscore in agent type: $agent_type"
                    ((INVALID_AGENTS++))
                fi
            fi
        done < "$cmd_file"
    fi
done

if [[ $INVALID_AGENTS -eq 0 ]]; then
    pass "[P1] All subagent_type declarations reference valid agents"
else
    fail "[P1] Found $INVALID_AGENTS invalid subagent_type declarations"
fi
echo ""

# =============================================================================
# TEST 13: [P2] Command File Naming Consistency
# =============================================================================
echo "--- TEST 13: [P2] Command File Naming Consistency ---"

info "Verifying all command files use kebab-case naming..."

for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [[ -f "$cmd_file" ]]; then
        filename=$(basename "$cmd_file" .md)

        # Check if filename contains underscores
        if [[ "$filename" =~ _ ]]; then
            fail "[P2] Command file uses underscore: $filename.md"
        else
            pass "[P2] Command file uses kebab-case: $filename.md"
        fi
    fi
done
echo ""

# =============================================================================
# TEST 14: [P2] Agent File Naming Consistency
# =============================================================================
echo "--- TEST 14: [P2] Agent File Naming Consistency ---"

info "Verifying all agent files use kebab-case naming..."

for agent_file in "$AGENTS_DIR"/*.md; do
    if [[ -f "$agent_file" ]]; then
        filename=$(basename "$agent_file" .md)

        # Check if filename contains underscores
        if [[ "$filename" =~ _ ]]; then
            fail "[P2] Agent file uses underscore: $filename.md"
        else
            pass "[P2] Agent file uses kebab-case: $filename.md"
        fi

        # Verify file exists in EXPECTED_AGENTS list
        if [[ " ${EXPECTED_AGENTS[*]} " =~ " ${filename} " ]]; then
            pass "[P2] Agent file is in expected list: $filename.md"
        else
            warn "[P2] Agent file NOT in expected list: $filename.md"
        fi
    fi
done
echo ""

# =============================================================================
# TEST 15: [P3] README Consistency Check
# =============================================================================
echo "--- TEST 15: [P3] README Cross-Reference Consistency ---"

info "Checking if README.md references match actual tool files..."

README_FILE="$PROJECT_ROOT/README.md"

if [[ -f "$README_FILE" ]]; then
    # Check for underscore patterns in README
    for pattern in "${UNDERSCORE_PATTERNS[@]}"; do
        if grep -q "$pattern" "$README_FILE"; then
            fail "[P3] README.md contains underscore reference: '$pattern'"
        fi
    done

    if [[ $FAIL_COUNT -eq 0 ]]; then
        pass "[P3] README.md does NOT contain underscore patterns"
    fi

    # Verify README references actual agent files
    for agent in "${EXPECTED_AGENTS[@]}"; do
        if grep -q "$agent" "$README_FILE"; then
            pass "[P3] README.md references agent: $agent"
        else
            warn "[P3] README.md does NOT mention agent: $agent"
        fi
    done
else
    warn "[P3] README.md not found - skipping README consistency checks"
fi
echo ""

# =============================================================================
# Summary
# =============================================================================
echo "=============================================="
echo "TEST SUMMARY"
echo "=============================================="
echo -e "${GREEN}PASSED:${NC} $PASS_COUNT"
echo -e "${RED}FAILED:${NC} $FAIL_COUNT"
echo -e "${YELLOW}WARNINGS:${NC} $WARN_COUNT"
echo ""

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "${RED}STATUS: FAILING - Cross-reference issues detected${NC}"
    exit 1
else
    echo -e "${GREEN}STATUS: PASSING - All cross-references verified${NC}"
    exit 0
fi
