#!/bin/bash
# Local CI Mirror for Docs Pipeline
# Mirrors GitHub Actions workflow for local debugging
# Usage: ./scripts/ci-local.sh [--quick]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "================================================"
echo "        DOCS CI - LOCAL MIRROR"
echo "================================================"
echo ""
echo "Project: $PROJECT_ROOT"
echo "Mode: ${1:-full}"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}PASS${NC}: $1"; }
fail() { echo -e "${RED}FAIL${NC}: $1"; }
warn() { echo -e "${YELLOW}WARN${NC}: $1"; }

# Track results
FAILURES=0

# ============================================
# Stage 1: Structure Check (Critical)
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 1: File Structure Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

required_files=("README.md" "LICENSE" "CLAUDE.md")
for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    pass "$file exists"
  else
    fail "$file missing"
    FAILURES=$((FAILURES + 1))
  fi
done

# Count distributable files
agent_count=$(find agents -name "*.md" -type f 2>/dev/null | wc -l | xargs)
command_count=$(find commands -name "*.md" -type f 2>/dev/null | wc -l | xargs)
skill_count=$(find skills -name "*.md" -type f 2>/dev/null | wc -l | xargs)

echo ""
echo "Distributable inventory:"
echo "  agents/:   $agent_count files"
echo "  commands/: $command_count files"
echo "  skills/:   $skill_count files"

total=$((agent_count + command_count + skill_count))
if [ "$total" -ge 10 ]; then
  pass "Total: $total distributable files"
else
  warn "Only $total distributable files (expected 20+)"
fi

# ============================================
# Stage 2: Naming Convention Check
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 2: Naming Convention Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

naming_errors=0
for dir in agents commands skills; do
  if [ -d "$dir" ]; then
    for file in "$dir"/*.md; do
      if [ -f "$file" ]; then
        basename=$(basename "$file")
        if echo "$basename" | grep -q '[A-Z]'; then
          fail "$file contains uppercase (should be kebab-case)"
          naming_errors=$((naming_errors + 1))
        fi
      fi
    done
  fi
done

if [ $naming_errors -eq 0 ]; then
  pass "All files follow kebab-case naming"
else
  FAILURES=$((FAILURES + naming_errors))
fi

# ============================================
# Stage 3: Hardcoded Path Check
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 3: Hardcoded Path Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

hardcoded=0
if grep -r "/Users/" agents/ commands/ skills/ 2>/dev/null | grep -v ".git"; then
  warn "Found /Users/ paths (may be intentional examples)"
  hardcoded=$((hardcoded + 1))
fi

if grep -r "/home/" agents/ commands/ skills/ 2>/dev/null | grep -v ".git"; then
  warn "Found /home/ paths (may be intentional examples)"
  hardcoded=$((hardcoded + 1))
fi

if [ $hardcoded -eq 0 ]; then
  pass "No hardcoded absolute paths detected"
fi

# ============================================
# Stage 4: Markdown Lint (if available)
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 4: Markdown Linting"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v markdownlint-cli2 &> /dev/null; then
  echo "Running markdownlint-cli2..."
  if markdownlint-cli2 "agents/**/*.md" "commands/**/*.md" "skills/**/*.md" "README.md" --config .markdownlint.json 2>/dev/null; then
    pass "Markdown linting passed"
  else
    warn "Markdown linting found issues (non-blocking)"
  fi
else
  warn "markdownlint-cli2 not installed (npm install -g markdownlint-cli2)"
fi

# ============================================
# Stage 5: Shell Script Check (if available)
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stage 5: Shell Script Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "tests" ]; then
  script_count=$(find tests -name "*.sh" -type f 2>/dev/null | wc -l | xargs)
  echo "Found $script_count shell scripts in tests/"

  if command -v shellcheck &> /dev/null; then
    echo "Running shellcheck..."
    shellcheck_errors=0
    for script in tests/*.sh; do
      if [ -f "$script" ]; then
        if shellcheck -S warning "$script" 2>/dev/null; then
          pass "$(basename "$script")"
        else
          warn "$(basename "$script") has issues"
          shellcheck_errors=$((shellcheck_errors + 1))
        fi
      fi
    done
  else
    warn "shellcheck not installed (brew install shellcheck)"
  fi

  # Check executable permissions
  echo ""
  echo "Checking executable permissions..."
  for script in tests/*.sh; do
    if [ -f "$script" ]; then
      if [ -x "$script" ]; then
        pass "$(basename "$script") is executable"
      else
        warn "$(basename "$script") is not executable"
      fi
    fi
  done
else
  echo "No tests/ directory found"
fi

# ============================================
# Summary
# ============================================
echo ""
echo "================================================"
echo "                 SUMMARY"
echo "================================================"
echo ""

if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}All critical checks passed!${NC}"
  echo ""
  echo "Ready to push. The full CI will run:"
  echo "  - Markdown linting"
  echo "  - Link validation"
  echo "  - ShellCheck"
  echo "  - Structure validation"
  echo "  - Content validation"
  echo ""
  exit 0
else
  echo -e "${RED}$FAILURES critical failure(s) detected${NC}"
  echo ""
  echo "Fix the issues above before pushing."
  echo ""
  exit 1
fi
