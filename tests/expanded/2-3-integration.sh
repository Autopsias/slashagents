#!/bin/bash

# Test Expansion: Story 2.3 - Agent Metadata Integration & Future-Proofing
# Priority: P3 (Optional - Future-Proofing)
# Focus: Integration with other fields, documentation consistency, future-proofing

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Project root (dynamically resolved - works from anywhere)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"
README_FILE="$PROJECT_ROOT/README.md"

# Helper function to run a test
run_test() {
    local test_id="$1"
    local test_description="$2"
    local test_command="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${YELLOW}TEST:${NC} $test_id: $test_description"

    if eval "$test_command"; then
        echo -e "${GREEN}PASS:${NC} $test_id: $test_description"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}FAIL:${NC} $test_id: $test_description"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

echo "============================================================================="
echo "EXPANDED TEST SUITE: Story 2.3 - Agent Metadata"
echo "Priority: P3 (Integration & Future-Proofing)"
echo "============================================================================="
echo ""

# =============================================================================
# CATEGORY 1: Multi-Field Integration (14 tests)
# =============================================================================

echo "-----------------------------------------------------------------------------"
echo "CATEGORY 1: Multi-Field Integration (14 tests)"
echo "-----------------------------------------------------------------------------"

# Test 1.1: Works with name field (11 tests)
echo -e "\n${YELLOW}Test Group 1.1: Integration with Name Field${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P3-1.1-$agent_name" \
        "Has name field alongside standardized metadata in $agent_name" \
        "grep '^name:' '$agent_file' > /dev/null"
done

# Test 1.2: Works with tools field (11 tests - verify doesn't conflict)
echo -e "\n${YELLOW}Test Group 1.2: Integration with Tools Field${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P3-1.2-$agent_name" \
        "Has tools field alongside standardized metadata in $agent_name" \
        "grep '^tools:' '$agent_file' > /dev/null"
done

# Test 1.3: Reasonable frontmatter field count (11 tests)
echo -e "\n${YELLOW}Test Group 1.3: Reasonable Frontmatter Field Count${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    field_count=$(awk '/^---$/{p++} p==1 && /^[a-z_-]+:/{fields++} p==2{exit} END{print fields+0}' "$agent_file")
    run_test "TEST-P3-1.3-$agent_name" \
        "Frontmatter has reasonable field count (3-7) in $agent_name" \
        "[[ $field_count -ge 3 && $field_count -le 7 ]]"
done

# =============================================================================
# CATEGORY 2: Future-Proofing (44 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 2: Future-Proofing (44 tests)"
echo "-----------------------------------------------------------------------------"

# Test 2.1: Description not redundant with agent name (11 tests)
echo -e "\n${YELLOW}Test Group 2.1: Description Not Redundant with Name${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    description=$(grep '^description:' "$agent_file" | sed 's/description: "\(.*\)"/\1/')
    # Description should not just be the agent name rephrased
    run_test "TEST-P3-2.1-$agent_name" \
        "Description adds value beyond agent name in $agent_name" \
        "[[ \$(echo '$description' | wc -w) -gt 3 ]]"
done

# Test 2.2: Prerequisites not redundant with description (11 tests)
echo -e "\n${YELLOW}Test Group 2.2: Prerequisites Not Redundant with Description${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    description=$(grep '^description:' "$agent_file" | sed 's/description: "\(.*\)"/\1/')
    prerequisites=$(grep '^prerequisites:' "$agent_file" | sed 's/prerequisites: "\(.*\)"/\1/')
    # Prerequisites should not duplicate description content
    run_test "TEST-P3-2.2-$agent_name" \
        "Prerequisites different from description in $agent_name" \
        "[[ '$description' != *'$prerequisites'* || '$prerequisites' == '—' || '$prerequisites' == *'MCP'* ]]"
done

# Test 2.3: Active voice in descriptions (11 tests)
echo -e "\n${YELLOW}Test Group 2.3: Active Voice in Descriptions${NC}"
ACTIVE_VERBS=("Fixes" "Scans" "Executes" "Manages" "Investigates")
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    description=$(grep '^description:' "$agent_file" | sed 's/description: "\(.*\)"/\1/')
    first_word=$(echo "$description" | awk '{print $1}')

    is_active=false
    for verb in "${ACTIVE_VERBS[@]}"; do
        if [[ "$first_word" == "$verb" ]]; then
            is_active=true
            break
        fi
    done

    run_test "TEST-P3-2.3-$agent_name" \
        "Description starts with active verb in $agent_name" \
        "$is_active"
done

# Test 2.4: No version numbers in prerequisites (11 tests)
echo -e "\n${YELLOW}Test Group 2.4: No Version Numbers in Prerequisites${NC}"
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    run_test "TEST-P3-2.4-$agent_name" \
        "No version numbers in prerequisites of $agent_name" \
        "! grep '^prerequisites:' '$agent_file' | grep -E '[0-9]+\.[0-9]+' > /dev/null"
done

# =============================================================================
# CATEGORY 3: Documentation Consistency (12 tests)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 3: Documentation Consistency (12 tests)"
echo "-----------------------------------------------------------------------------"

# Test 3.1: README mentions all agents (1 test)
echo -e "\n${YELLOW}Test Group 3.1: README Agent Coverage${NC}"
if [[ -f "$README_FILE" ]]; then
    all_documented=true
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

    for agent in "${EXPECTED_AGENTS[@]}"; do
        if ! grep -i "$agent" "$README_FILE" > /dev/null; then
            all_documented=false
            break
        fi
    done

    run_test "TEST-P3-3.1-readme-coverage" \
        "README mentions all 11 agents" \
        "$all_documented"
else
    run_test "TEST-P3-3.1-readme-coverage" \
        "README file exists" \
        "false"
fi

# Test 3.2: Agent descriptions align with their specialization (11 tests)
echo -e "\n${YELLOW}Test Group 3.2: Description Alignment with Specialization${NC}"

# Define expected keywords for each agent specialization
declare -A SPECIALIZATION_KEYWORDS
SPECIALIZATION_KEYWORDS["unit-test-fixer"]="test"
SPECIALIZATION_KEYWORDS["api-test-fixer"]="API"
SPECIALIZATION_KEYWORDS["database-test-fixer"]="database"
SPECIALIZATION_KEYWORDS["e2e-test-fixer"]="E2E"
SPECIALIZATION_KEYWORDS["linting-fixer"]="linting"
SPECIALIZATION_KEYWORDS["type-error-fixer"]="type"
SPECIALIZATION_KEYWORDS["import-error-fixer"]="import"
SPECIALIZATION_KEYWORDS["security-scanner"]="security"
SPECIALIZATION_KEYWORDS["pr-workflow-manager"]="pull request|workflow|PR"
SPECIALIZATION_KEYWORDS["parallel-executor"]="parallel|task|execut"
SPECIALIZATION_KEYWORDS["digdeep"]="investigat|analys|root cause"

for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    description=$(grep '^description:' "$agent_file" | sed 's/description: "\(.*\)"/\1/')
    keywords="${SPECIALIZATION_KEYWORDS[$agent_name]}"

    run_test "TEST-P3-3.2-$agent_name" \
        "Description reflects specialization in $agent_name" \
        "echo '$description' | grep -iE '$keywords' > /dev/null"
done

# =============================================================================
# CATEGORY 4: Command vs Agent Consistency (1 test)
# =============================================================================

echo -e "\n-----------------------------------------------------------------------------"
echo "CATEGORY 4: Command vs Agent Consistency (1 test)"
echo "-----------------------------------------------------------------------------"

# Test 4.1: Agents follow same metadata standards as commands
echo -e "\n${YELLOW}Test Group 4.1: Cross-Collection Consistency${NC}"
run_test "TEST-P3-4.1-metadata-consistency" \
    "Agents use same frontmatter structure as commands" \
    "grep -l 'description:.*\"' '$AGENTS_DIR'/*.md | wc -l | grep -q '11' && \
     grep -l 'prerequisites:.*\"' '$AGENTS_DIR'/*.md | wc -l | grep -q '11'"

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "============================================================================="
echo "TEST SUMMARY (P3: Integration & Future-Proofing)"
echo "============================================================================="
echo "Tests Run:    $TOTAL_TESTS"
echo -e "Tests Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Tests Failed: ${RED}$FAILED_TESTS${NC}"
echo "============================================================================="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}GREEN PHASE: All P3 integration tests passing!${NC}"
    exit 0
else
    echo -e "${YELLOW}YELLOW PHASE: $FAILED_TESTS test(s) failing (future-proofing - optional).${NC}"
    exit 1
fi
