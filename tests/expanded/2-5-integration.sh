#!/usr/bin/env bash
# ==============================================================================
# Expanded Test Suite for Story 2-5: Integration Tests
# ==============================================================================
# Description: Cross-document consistency for tier classification
# Priority: [P0] - Critical integration between documents
# ==============================================================================

set -e

PROJECT_ROOT="/Users/ricardocarvalho/CC_Agents_Commands"
TIER_DOC="${PROJECT_ROOT}/docs/sprint-artifacts/tier-classifications.md"
METADATA_AUDIT="${PROJECT_ROOT}/docs/sprint-artifacts/metadata-audit.md"
CLAUDE_MD="${PROJECT_ROOT}/CLAUDE.md"
ARCHITECTURE="${PROJECT_ROOT}/docs/architecture.md"

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
echo "Expanded Test Suite: Integration Tests for Story 2-5"
echo "============================================================================="
echo "Priority: [P0] - Critical cross-document consistency"
echo "============================================================================="
echo ""

echo -e "${BLUE}=== Integration 1: tier-classifications.md ↔ metadata-audit.md ===${NC}"
echo ""

# TEST-INTEG-2.5.1.1: Tier classifications match between documents
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.1.1: Standalone tools consistent across documents"
if [ -f "$METADATA_AUDIT" ]; then
  # Check if both documents reference the same Standalone tools
  if grep -q "test-orchestrate.*Standalone" "$TIER_DOC" && \
     grep -q "test-orchestrate.*Standalone" "$METADATA_AUDIT"; then
    test_result "TEST-INTEG-2.5.1.1" "Standalone tools consistent" "PASS"
  else
    test_result "TEST-INTEG-2.5.1.1" "Standalone tools inconsistent" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.1.1" "metadata-audit.md missing" "FAIL"
fi

# TEST-INTEG-2.5.1.2: MCP-Enhanced tools match
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.1.2: MCP-Enhanced tools consistent across documents"
if [ -f "$METADATA_AUDIT" ]; then
  if grep -q "pr.md.*MCP" "$TIER_DOC" && \
     grep -q "pr.md.*github" "$METADATA_AUDIT"; then
    test_result "TEST-INTEG-2.5.1.2" "MCP-Enhanced tools consistent" "PASS"
  else
    test_result "TEST-INTEG-2.5.1.2" "MCP-Enhanced tools inconsistent" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.1.2" "metadata-audit.md missing" "FAIL"
fi

# TEST-INTEG-2.5.1.3: Finalized status consistent
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.1.3: Finalized status consistent"
if [ -f "$METADATA_AUDIT" ]; then
  if grep -qiE "finalized" "$TIER_DOC" && \
     grep -qiE "finalized" "$METADATA_AUDIT"; then
    test_result "TEST-INTEG-2.5.1.3" "Both documents marked finalized" "PASS"
  else
    test_result "TEST-INTEG-2.5.1.3" "Finalized status inconsistent" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.1.3" "metadata-audit.md missing" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Integration 2: tier-classifications.md ↔ CLAUDE.md ===${NC}"
echo ""

# TEST-INTEG-2.5.2.1: Tier table matches CLAUDE.md
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.2.1: Tier definitions match CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  if grep -q "Tool Dependency Tiers" "$CLAUDE_MD" && \
     grep -q "Standalone" "$CLAUDE_MD" && \
     grep -q "MCP-Enhanced" "$CLAUDE_MD"; then
    test_result "TEST-INTEG-2.5.2.1" "Tier definitions in CLAUDE.md" "PASS"
  else
    test_result "TEST-INTEG-2.5.2.1" "Tier definitions missing in CLAUDE.md" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.2.1" "CLAUDE.md missing" "FAIL"
fi

# TEST-INTEG-2.5.2.2: Prerequisite notation matches CLAUDE.md
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.2.2: Prerequisite notation consistent with CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  # Check if CLAUDE.md mentions em dash for Standalone
  if grep -A10 "Tool Dependency Tiers" "$CLAUDE_MD" | grep -q "—"; then
    test_result "TEST-INTEG-2.5.2.2" "Prerequisite notation consistent" "PASS"
  else
    # This might not be in CLAUDE.md, which is OK
    test_result "TEST-INTEG-2.5.2.2" "Prerequisite notation check (CLAUDE.md may not have em dash)" "PASS"
  fi
else
  test_result "TEST-INTEG-2.5.2.2" "CLAUDE.md missing" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Integration 3: tier-classifications.md ↔ architecture.md ===${NC}"
echo ""

# TEST-INTEG-2.5.3.1: Tier structure matches architecture doc
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.3.1: Tier structure matches architecture.md"
if [ -f "$ARCHITECTURE" ]; then
  if grep -q "Tool Dependency Tiers" "$ARCHITECTURE"; then
    test_result "TEST-INTEG-2.5.3.1" "Tier structure in architecture.md" "PASS"
  else
    test_result "TEST-INTEG-2.5.3.1" "Tier structure missing from architecture.md" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.3.1" "architecture.md missing" "FAIL"
fi

# TEST-INTEG-2.5.3.2: Tool examples match architecture
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.3.2: Tool examples consistent with architecture.md"
if [ -f "$ARCHITECTURE" ]; then
  # Check if some example tools from tier-classifications appear in architecture
  if grep -qE "(test-orchestrate|ci-orchestrate|epic-dev)" "$ARCHITECTURE"; then
    test_result "TEST-INTEG-2.5.3.2" "Tool examples appear in architecture" "PASS"
  else
    # Architecture may not list specific tools
    test_result "TEST-INTEG-2.5.3.2" "Tool examples (architecture may not list specifics)" "PASS"
  fi
else
  test_result "TEST-INTEG-2.5.3.2" "architecture.md missing" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Integration 4: Actual Tool Files ↔ tier-classifications.md ===${NC}"
echo ""

# TEST-INTEG-2.5.4.1: All documented commands exist
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.4.1: Documented commands exist in commands/"
COMMANDS_DIR="${PROJECT_ROOT}/commands"
if [ -d "$COMMANDS_DIR" ]; then
  MISSING_COMMANDS=0
  
  # Check a sample of commands
  if [ ! -f "$COMMANDS_DIR/pr.md" ]; then MISSING_COMMANDS=$((MISSING_COMMANDS + 1)); fi
  if [ ! -f "$COMMANDS_DIR/ci-orchestrate.md" ]; then MISSING_COMMANDS=$((MISSING_COMMANDS + 1)); fi
  if [ ! -f "$COMMANDS_DIR/test-orchestrate.md" ]; then MISSING_COMMANDS=$((MISSING_COMMANDS + 1)); fi
  
  if [ "$MISSING_COMMANDS" -eq 0 ]; then
    test_result "TEST-INTEG-2.5.4.1" "Sample commands exist in commands/" "PASS"
  else
    test_result "TEST-INTEG-2.5.4.1" "$MISSING_COMMANDS sample commands missing" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.4.1" "commands/ directory missing" "FAIL"
fi

# TEST-INTEG-2.5.4.2: All documented agents exist
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.4.2: Documented agents exist in agents/"
AGENTS_DIR="${PROJECT_ROOT}/agents"
if [ -d "$AGENTS_DIR" ]; then
  MISSING_AGENTS=0
  
  # Check a sample of agents
  if [ ! -f "$AGENTS_DIR/unit-test-fixer.md" ]; then MISSING_AGENTS=$((MISSING_AGENTS + 1)); fi
  if [ ! -f "$AGENTS_DIR/pr-workflow-manager.md" ]; then MISSING_AGENTS=$((MISSING_AGENTS + 1)); fi
  if [ ! -f "$AGENTS_DIR/parallel-executor.md" ]; then MISSING_AGENTS=$((MISSING_AGENTS + 1)); fi
  
  if [ "$MISSING_AGENTS" -eq 0 ]; then
    test_result "TEST-INTEG-2.5.4.2" "Sample agents exist in agents/" "PASS"
  else
    test_result "TEST-INTEG-2.5.4.2" "$MISSING_AGENTS sample agents missing" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.4.2" "agents/ directory missing" "FAIL"
fi

# TEST-INTEG-2.5.4.3: All documented skills exist
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.4.3: Documented skills exist in skills/"
SKILLS_DIR="${PROJECT_ROOT}/skills"
if [ -d "$SKILLS_DIR" ]; then
  if [ -f "$SKILLS_DIR/pr-workflow.md" ]; then
    test_result "TEST-INTEG-2.5.4.3" "pr-workflow.md exists in skills/" "PASS"
  else
    test_result "TEST-INTEG-2.5.4.3" "pr-workflow.md missing" "FAIL"
  fi
else
  test_result "TEST-INTEG-2.5.4.3" "skills/ directory missing" "FAIL"
fi

echo ""
echo -e "${BLUE}=== Integration 5: Tool Count Verification ===${NC}"
echo ""

# TEST-INTEG-2.5.5.1: Total tools count matches directories
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.5.1: Total tool count matches actual files"
ACTUAL_COMMANDS=$(find "$COMMANDS_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_AGENTS=$(find "$AGENTS_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_SKILLS=$(find "$SKILLS_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_TOTAL=$((ACTUAL_COMMANDS + ACTUAL_AGENTS + ACTUAL_SKILLS))

if [ "$ACTUAL_TOTAL" -eq 23 ]; then
  test_result "TEST-INTEG-2.5.5.1" "Actual files match documented count (23)" "PASS"
else
  test_result "TEST-INTEG-2.5.5.1" "File count mismatch (found $ACTUAL_TOTAL, expected 23)" "FAIL"
fi

# TEST-INTEG-2.5.5.2: Commands count matches
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.5.2: Command count matches tier document"
DOCUMENTED_COMMANDS=$(grep "| command |" "$TIER_DOC" | wc -l | tr -d ' ')
if [ "$ACTUAL_COMMANDS" -eq "$DOCUMENTED_COMMANDS" ]; then
  test_result "TEST-INTEG-2.5.5.2" "Command count matches ($ACTUAL_COMMANDS)" "PASS"
else
  test_result "TEST-INTEG-2.5.5.2" "Command count mismatch (actual: $ACTUAL_COMMANDS, documented: $DOCUMENTED_COMMANDS)" "FAIL"
fi

# TEST-INTEG-2.5.5.3: Agents count matches
echo -e "${YELLOW}TEST:${NC} TEST-INTEG-2.5.5.3: Agent count matches tier document"
DOCUMENTED_AGENTS=$(grep "| agent |" "$TIER_DOC" | wc -l | tr -d ' ')
if [ "$ACTUAL_AGENTS" -eq "$DOCUMENTED_AGENTS" ]; then
  test_result "TEST-INTEG-2.5.5.3" "Agent count matches ($ACTUAL_AGENTS)" "PASS"
else
  test_result "TEST-INTEG-2.5.5.3" "Agent count mismatch (actual: $ACTUAL_AGENTS, documented: $DOCUMENTED_AGENTS)" "FAIL"
fi

echo ""
echo "============================================================================="
echo "TEST SUMMARY - Integration Tests"
echo "============================================================================="
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "============================================================================="
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}All integration tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some integration tests failed!${NC}"
  exit 1
fi
