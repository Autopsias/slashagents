#!/bin/bash
# shared-discovery.sh
# Token-efficient project context caching for orchestration commands
# Discovers project structure, config files, and test patterns
# Caches results for 15 minutes to avoid redundant discovery
# Provides: SHARED_CONTEXT, PROJECT_TYPE, VALIDATION_CMD

# Cache configuration
CACHE_DIR="${TMPDIR:-/tmp}/claude-code-cache"
CACHE_FILE="$CACHE_DIR/project-context-$(pwd | (command -v md5sum >/dev/null 2>&1 && md5sum || md5) | cut -d' ' -f1).cache"
CACHE_TTL=900  # 15 minutes in seconds

# Initialize cache directory
mkdir -p "$CACHE_DIR"

# Function: Check if cache is valid
is_cache_valid() {
    if [[ ! -f "$CACHE_FILE" ]]; then
        return 1
    fi

    local cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null)))
    [[ $cache_age -lt $CACHE_TTL ]]
}

# Function: Discover project context
discover_project_context() {
    # Check cache first
    if is_cache_valid; then
        source "$CACHE_FILE"
        return 0
    fi

    # Discover project type
    if [[ -f "package.json" ]]; then
        PROJECT_TYPE="node"
        VALIDATION_CMD="npm test"

        # Check for specific frameworks
        if grep -q '"@playwright/test"' package.json 2>/dev/null; then
            VALIDATION_CMD="npx playwright test"
        elif grep -q '"vitest"' package.json 2>/dev/null; then
            VALIDATION_CMD="npm run test"
        elif grep -q '"jest"' package.json 2>/dev/null; then
            VALIDATION_CMD="npm test"
        fi

        # Check for pnpm
        if [[ -f "pnpm-lock.yaml" ]]; then
            VALIDATION_CMD="${VALIDATION_CMD/npm/pnpm}"
        fi

    elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; then
        PROJECT_TYPE="python"
        VALIDATION_CMD="pytest"

        # Check for uv
        if command -v uv &>/dev/null && [[ -f "pyproject.toml" ]]; then
            VALIDATION_CMD="uv run pytest"
        fi

    elif [[ -f "Cargo.toml" ]]; then
        PROJECT_TYPE="rust"
        VALIDATION_CMD="cargo test"

    elif [[ -f "go.mod" ]]; then
        PROJECT_TYPE="go"
        VALIDATION_CMD="go test ./..."

    else
        PROJECT_TYPE="unknown"
        VALIDATION_CMD=""
    fi

    # Build shared context summary
    SHARED_CONTEXT="Project Type: $PROJECT_TYPE"

    # Add test framework info
    if [[ -n "$VALIDATION_CMD" ]]; then
        SHARED_CONTEXT="$SHARED_CONTEXT
Test Command: $VALIDATION_CMD"
    fi

    # Add directory structure info
    if [[ -d "src" ]]; then
        SHARED_CONTEXT="$SHARED_CONTEXT
Source: src/"
    fi

    if [[ -d "tests" ]]; then
        SHARED_CONTEXT="$SHARED_CONTEXT
Tests: tests/"
    elif [[ -d "test" ]]; then
        SHARED_CONTEXT="$SHARED_CONTEXT
Tests: test/"
    fi

    # Cache the results
    {
        echo "PROJECT_TYPE='$PROJECT_TYPE'"
        echo "VALIDATION_CMD='$VALIDATION_CMD'"
        echo "SHARED_CONTEXT='$SHARED_CONTEXT'"
    } > "$CACHE_FILE"

    export PROJECT_TYPE VALIDATION_CMD SHARED_CONTEXT
}

# Auto-discover on source
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    discover_project_context
fi
