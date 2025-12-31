#!/usr/bin/env bash
# GitHub Actions Runner Health Check Script
# Diagnoses runner health, disk usage, and recent errors
# Usage: bash runner-health-check.sh

set -eo pipefail

echo "=========================================="
echo "  GitHub Actions Runner Health Check"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Exit code tracking
EXIT_CODE=0

# ==========================================
# 1. Runner Service Status
# ==========================================
echo "=== Runner Service Status ==="

# Try to find runner service
RUNNER_SERVICE=$(launchctl list 2>/dev/null | grep "actions.runner" | awk '{print $3}' || true)

if [ -n "$RUNNER_SERVICE" ]; then
    echo -e "${GREEN}✓${NC} Runner service found: $RUNNER_SERVICE"

    # Get service status
    SERVICE_PID=$(launchctl list "$RUNNER_SERVICE" 2>/dev/null | grep "PID" | awk '{print $3}' || echo "")

    if [ -n "$SERVICE_PID" ] && [ "$SERVICE_PID" != "-" ]; then
        echo -e "${GREEN}✓${NC} Service is running (PID: $SERVICE_PID)"
    else
        echo -e "${RED}✗${NC} Service is not running"
        EXIT_CODE=1
    fi
else
    echo -e "${YELLOW}⚠${NC}  No runner service found in launchctl"
    echo "  This may be normal if runner is not installed as a service"
fi

echo ""

# ==========================================
# 2. Disk Space Check
# ==========================================
echo "=== Disk Space ==="

DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')
DISK_AVAIL=$(df -h / | tail -1 | awk '{print $4}')

echo "Disk usage: ${DISK_USAGE}%"
echo "Available: ${DISK_AVAIL}"

if [ "$DISK_USAGE" -ge 90 ]; then
    echo -e "${RED}✗${NC} CRITICAL: Disk usage is ${DISK_USAGE}%"
    EXIT_CODE=1
elif [ "$DISK_USAGE" -ge 80 ]; then
    echo -e "${YELLOW}⚠${NC}  WARNING: Disk usage is ${DISK_USAGE}%"
else
    echo -e "${GREEN}✓${NC} Disk usage is healthy"
fi

echo ""

# ==========================================
# 3. Runner Directory Check
# ==========================================
echo "=== Runner Directory ==="

# Common runner installation paths
RUNNER_PATHS=(
    ~/actions-runner
    /opt/actions-runner
    /usr/local/actions-runner
)

RUNNER_DIR=""
for path in "${RUNNER_PATHS[@]}"; do
    if [ -d "$path" ]; then
        RUNNER_DIR="$path"
        echo -e "${GREEN}✓${NC} Found runner directory: $RUNNER_DIR"
        break
    fi
done

if [ -z "$RUNNER_DIR" ]; then
    echo -e "${YELLOW}⚠${NC}  Runner directory not found in standard locations"
    echo "  Checked: ${RUNNER_PATHS[*]}"
    echo ""
    exit $EXIT_CODE
fi

echo ""

# ==========================================
# 4. Runner Workspace Size
# ==========================================
echo "=== Workspace Size ==="

if [ -d "$RUNNER_DIR/_work" ]; then
    WORK_SIZE=$(du -sh "$RUNNER_DIR/_work" 2>/dev/null | awk '{print $1}')
    echo "Workspace size: $WORK_SIZE"

    # Count subdirectories (repos)
    WORK_REPOS=$(find "$RUNNER_DIR/_work" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    echo "Active workspaces: $WORK_REPOS"
else
    echo -e "${YELLOW}⚠${NC}  No _work directory found"
fi

if [ -d "$RUNNER_DIR/_tool" ]; then
    TOOL_SIZE=$(du -sh "$RUNNER_DIR/_tool" 2>/dev/null | awk '{print $1}')
    echo "Tool cache size: $TOOL_SIZE"
fi

if [ -d "$RUNNER_DIR/_actions" ]; then
    ACTIONS_SIZE=$(du -sh "$RUNNER_DIR/_actions" 2>/dev/null | awk '{print $1}')
    echo "Actions cache size: $ACTIONS_SIZE"
fi

echo ""

# ==========================================
# 5. Recent Runner Errors
# ==========================================
echo "=== Recent Errors (last 50 lines) ==="

if [ -d "$RUNNER_DIR/_diag" ]; then
    # Find most recent log file
    RECENT_LOG=$(ls -t "$RUNNER_DIR/_diag"/Runner_*.log 2>/dev/null | head -1)

    if [ -n "$RECENT_LOG" ]; then
        echo "Checking: $(basename "$RECENT_LOG")"

        # Look for errors in last 50 lines
        ERRORS=$(tail -50 "$RECENT_LOG" 2>/dev/null | grep -i "error" || true)

        if [ -n "$ERRORS" ]; then
            echo -e "${RED}Found errors:${NC}"
            echo "$ERRORS" | head -10
            EXIT_CODE=1
        else
            echo -e "${GREEN}✓${NC} No errors found in recent logs"
        fi
    else
        echo -e "${YELLOW}⚠${NC}  No runner log files found"
    fi
else
    echo -e "${YELLOW}⚠${NC}  No _diag directory found"
fi

echo ""

# ==========================================
# 6. Runner Configuration
# ==========================================
echo "=== Runner Configuration ==="

if [ -f "$RUNNER_DIR/.runner" ]; then
    echo -e "${GREEN}✓${NC} Runner configuration file exists"

    # Try to extract runner name (if JSON format)
    if command -v jq >/dev/null 2>&1; then
        RUNNER_NAME=$(jq -r '.agentName // empty' "$RUNNER_DIR/.runner" 2>/dev/null || true)
        if [ -n "$RUNNER_NAME" ]; then
            echo "Runner name: $RUNNER_NAME"
        fi
    fi
else
    echo -e "${YELLOW}⚠${NC}  No .runner configuration file found"
fi

echo ""

# ==========================================
# 7. Required Dependencies
# ==========================================
echo "=== Required Dependencies ==="

# Check ShellCheck
if command -v shellcheck >/dev/null 2>&1; then
    SHELLCHECK_VERSION=$(shellcheck --version | grep "version:" | awk '{print $2}')
    echo -e "${GREEN}✓${NC} ShellCheck: $SHELLCHECK_VERSION"
else
    echo -e "${RED}✗${NC} ShellCheck not found (required for workflows)"
    EXIT_CODE=1
fi

# Check npm
if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm: $NPM_VERSION"
else
    echo -e "${YELLOW}⚠${NC}  npm not found (actions/setup-node should handle this)"
fi

# Check Homebrew
if command -v brew >/dev/null 2>&1; then
    BREW_VERSION=$(brew --version | head -1)
    echo -e "${GREEN}✓${NC} Homebrew: $BREW_VERSION"
else
    echo -e "${YELLOW}⚠${NC}  Homebrew not found"
fi

echo ""

# ==========================================
# Summary
# ==========================================
echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Runner appears healthy${NC}"
else
    echo -e "${RED}✗ Runner has issues (see above)${NC}"
fi
echo "=========================================="

exit $EXIT_CODE
