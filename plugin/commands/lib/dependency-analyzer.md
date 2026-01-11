# Dependency Analyzer Library

Shared library for analyzing file dependencies before refactoring. Used by all orchestrators to enable smart parallelization of refactoring work.

---

## Overview

This library provides dependency analysis capabilities to determine which files can be safely refactored in parallel and which must be serialized due to shared dependencies (especially shared test files).

---

## Core Algorithm

### analyze_dependencies(files: List[str]) -> DependencyGraph

Builds a dependency graph for the given files:

```bash
# For each file, find what it imports (forward dependencies)
grep -E "^(from|import) " {file} | sed -n 's/.*from \([^ ]*\).*/\1/p; s/^import \([^ ]*\).*/\1/p'

# For each file, find what imports it (reverse dependencies)
grep -rl "from.*{module}" --include="*.py" .

# For each file, find related test files
grep -rl "{module_name}" tests/ --include="test_*.py"
```

### find_independent_clusters(graph: DependencyGraph) -> List[Cluster]

Groups files into independent clusters based on:
1. No shared imports between clusters
2. No shared test files between clusters
3. No transitive dependencies crossing clusters

```python
# Pseudo-code for clustering algorithm
def find_independent_clusters(files, test_mappings):
    clusters = []
    visited = set()

    for file in files:
        if file not in visited:
            # BFS to find connected component via shared tests
            cluster = bfs_component_by_shared_tests(file, test_mappings)
            visited.update(cluster.files)
            clusters.append(cluster)

    return clusters
```

### schedule_batches(clusters, max_parallel=6) -> List[Batch]

Creates execution batches:
- Independent clusters: Run in parallel (up to max_parallel)
- Within shared-test clusters: Serialize
- Always respect max 6 agents per batch

---

## Shared Test Detection (Critical)

Files that share test files MUST be serialized to prevent test pollution and race conditions:

```
Example:
  user_service.py  ─┬─> tests/test_user.py  (shared!)
  user_utils.py    ─┘

  auth_handler.py  ──> tests/test_auth.py   (independent)

Result:
  Cluster 1 (SERIAL): [user_service.py, user_utils.py]
  Cluster 2 (PARALLEL ok): [auth_handler.py]
```

---

## Lock Lifecycle Management

Prevents deadlocks when agents crash or stall.

### Lock State Storage

```
.claude/locks/{cluster_id}.lock
Format: {"agent_id": "...", "acquired_at": "...", "heartbeat": "..."}
```

### Lock Operations

```bash
# Check lock file
LOCK_FILE=".claude/locks/${CLUSTER_ID}.lock"

# Create locks directory if needed
mkdir -p .claude/locks

# Acquire lock (returns 0 on success, 1 if locked by another)
acquire_lock() {
    local cluster_id="$1"
    local agent_id="$2"
    local lock_file=".claude/locks/${cluster_id}.lock"

    if [ -f "$lock_file" ]; then
        # Check if stale (no heartbeat for 90 seconds)
        local last_heartbeat=$(jq -r '.heartbeat' "$lock_file" 2>/dev/null || echo "0")
        local now=$(date +%s)
        local age=$((now - last_heartbeat))

        if [ $age -gt 90 ]; then
            echo "Force-releasing stale lock for cluster: $cluster_id"
            rm -f "$lock_file"
        else
            echo "Lock held by: $(jq -r '.agent_id' "$lock_file")"
            return 1
        fi
    fi

    # Acquire lock
    echo "{\"agent_id\": \"$agent_id\", \"acquired_at\": $(date +%s), \"heartbeat\": $(date +%s)}" > "$lock_file"
    return 0
}

# Update heartbeat (agents call every 30s)
update_heartbeat() {
    local cluster_id="$1"
    local lock_file=".claude/locks/${cluster_id}.lock"

    if [ -f "$lock_file" ]; then
        local agent_id=$(jq -r '.agent_id' "$lock_file")
        local acquired_at=$(jq -r '.acquired_at' "$lock_file")
        echo "{\"agent_id\": \"$agent_id\", \"acquired_at\": $acquired_at, \"heartbeat\": $(date +%s)}" > "$lock_file"
    fi
}

# Release lock
release_lock() {
    local cluster_id="$1"
    rm -f ".claude/locks/${cluster_id}.lock"
}
```

### Stale Lock Recovery

1. **Lock Acquisition**: Record timestamp + agent_id
2. **Heartbeat**: Agents ping every 30s while holding lock
3. **Stale Detection**: Lock considered stale if no heartbeat for 90s
4. **Force Release**: Orchestrator can force-release stale locks

---

## Runtime Conflict Detection

Before ANY file modification, check for conflicts:

```bash
# Check if file is locked by another agent
check_file_lock() {
    local file_path="$1"
    local agent_id="$2"

    # File-level lock for source files
    local lock_file=".claude/locks/file_$(echo "$file_path" | md5sum | cut -d' ' -f1).lock"

    if [ -f "$lock_file" ]; then
        local holder=$(jq -r '.agent_id' "$lock_file" 2>/dev/null)
        if [ "$holder" != "$agent_id" ]; then
            echo "{\"status\": \"conflict\", \"blocked_by\": \"$holder\", \"waiting_for\": [\"$file_path\"], \"retry_after_ms\": 5000}"
            return 1
        fi
    fi
    return 0
}
```

### Lock Granularity

| Resource Type | Lock Level | Reason |
|--------------|------------|--------|
| Source files | File-level | Fine-grained, allows parallel work |
| Test directories | Directory-level | Conservative, prevents fixture conflicts |
| conftest.py | File-level + blocking | Critical shared state |

---

## Cluster Priority Scoring

Higher priority clusters are executed first (fail fast on critical code):

```bash
calculate_cluster_priority() {
    local cluster_files="$1"
    local score=0

    for file in $cluster_files; do
        loc=$(wc -l < "$file" 2>/dev/null || echo 0)

        # +10 points per file with >600 LOC (worst violations)
        [ $loc -gt 600 ] && score=$((score + 10))

        # +5 points if frequently modified (check git log)
        commits=$(git log --oneline --since="30 days ago" -- "$file" 2>/dev/null | wc -l)
        [ $commits -gt 5 ] && score=$((score + 5))

        # +3 points if on critical path (imported by many)
        importers=$(grep -rl "$(basename "$file" .py)" --include="*.py" . 2>/dev/null | wc -l)
        [ $importers -gt 10 ] && score=$((score + 3))
    done

    # -5 points if cluster only affects test files
    non_test_files=$(echo "$cluster_files" | grep -v "test_" | wc -l)
    [ $non_test_files -eq 0 ] && score=$((score - 5))

    echo $score
}
```

**Execution order**: Highest scoring clusters first

---

## Usage by Orchestrators

### 1. Warm-Up Phase (Background)

Called at orchestrator startup to pre-cache dependency graph:

```bash
# Pre-cache import graph for all Python files
warm_up_dependency_cache() {
    local cache_file=".claude/cache/dependency-graph.json"
    local cache_age=900  # 15 minutes

    # Check if cache is fresh
    if [ -f "$cache_file" ]; then
        local modified=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
        local now=$(date +%s)
        [ $((now - modified)) -lt $cache_age ] && return 0  # Cache is fresh
    fi

    mkdir -p .claude/cache

    # Build dependency graph
    echo '{"files": {}, "test_mappings": {}, "built_at": '$(date +%s)'}' > "$cache_file"

    # For each Python file, record imports and test coverage
    find . -name "*.py" -not -path "./.venv/*" | while read file; do
        # Extract imports
        imports=$(grep -E "^(from|import) " "$file" 2>/dev/null | head -20)

        # Find test files that import this module
        module_name=$(basename "$file" .py)
        test_files=$(grep -rl "$module_name" tests/ --include="test_*.py" 2>/dev/null | tr '\n' ',' | sed 's/,$//')

        # Update cache (simplified - real implementation uses jq)
        echo "Cached: $file -> tests: [$test_files]"
    done

    echo "Dependency cache updated: $cache_file"
}
```

### 2. Analysis Phase

Called before spawning refactoring agents:

```bash
# Analyze files and return clusters
analyze_for_refactoring() {
    local violation_files="$1"

    echo "=== PHASE 2: Dependency Analysis ==="
    echo "Analyzing imports for $(echo "$violation_files" | wc -w) files..."

    # Build test mapping for each file
    declare -A test_mappings
    for file in $violation_files; do
        module_name=$(basename "$file" .py)
        tests=$(grep -rl "$module_name" tests/ --include="test_*.py" 2>/dev/null | sort -u)
        test_mappings[$file]="$tests"
        echo "  $file -> tests: [$(echo $tests | tr '\n' ', ')]"
    done

    # Find files that share test files (must serialize)
    echo ""
    echo "Building dependency graph..."
    # ... clustering logic ...

    echo "Mapping test file relationships..."
    # ... test relationship mapping ...
}
```

### 3. Scheduling Phase

Returns execution schedule:

```
Cluster A (SERIAL - shared tests/test_user.py):
  - user_service.py (612 LOC)
  - user_utils.py (534 LOC)

Cluster B (PARALLEL - independent):
  - auth_handler.py (543 LOC)
  - payment_service.py (489 LOC)
  - notification.py (501 LOC)

Schedule:
  Batch 1: Cluster B (3 agents in parallel)
  Batch 2: Cluster A (2 agents serial)
```

---

## Observability & Metrics

Emit structured logs for orchestration decisions:

```json
{
  "event": "cluster_scheduled",
  "timestamp": "2025-01-15T10:30:00Z",
  "cluster_id": "cluster_a",
  "files": ["user_service.py", "user_utils.py"],
  "execution_mode": "serial",
  "reason": "shared_test_file",
  "shared_tests": ["tests/test_user.py"],
  "priority_score": 15
}
```

### Metrics to Track

| Metric | Type | Purpose |
|--------|------|---------|
| `refactor_duration_seconds{cluster, mode}` | Histogram | Per-cluster timing for tuning |
| `conflict_count{cluster}` | Counter | Conflicts detected |
| `rollback_count{cluster}` | Counter | Rollbacks performed |
| `user_intervention_count` | Counter | Failure prompts shown |
| `early_termination_accepted` | Counter | Times user chose early exit |
| `batch_size_actual` | Gauge | Actual parallel agents per batch |

### Log File Location

`.claude/logs/orchestration-{date}.jsonl`

---

## Integration Points

### For code_quality.md

```markdown
## STEP 4: Smart Parallel Refactoring

### 4A: Build Dependency Graph
Before ANY refactoring:
1. Call dependency-analyzer library
2. Map all violation files and their dependencies
3. Identify test file overlaps
4. Create independent clusters

### 4B: Execute Batched Refactoring
For each cluster (can parallelize clusters):
  If cluster has shared tests:
    Execute files SERIALLY within cluster
  Else:
    Execute files in PARALLEL (max 6)
```

### For safe-refactor.md

Add cluster context parameters:
- `cluster_id`: Which dependency cluster this file belongs to
- `parallel_peers`: List of files being refactored in parallel
- `test_scope`: Which test files this refactor may affect

### For parallel-orchestrator.md

Add refactoring-specific rules:
- ALWAYS call dependency-analyzer first for safe-refactor work
- Group files by cluster (shared deps/tests)
- Serialize within shared-test clusters

---

## Error Handling

### On Lock Acquisition Failure

```json
{
  "status": "conflict",
  "blocked_by": "agent_xyz",
  "waiting_for": ["file_a.py", "file_b.py"],
  "retry_after_ms": 5000
}
```

### On Stale Lock Detection

```json
{
  "event": "stale_lock_released",
  "cluster_id": "cluster_a",
  "original_agent": "agent_old",
  "stale_duration_seconds": 120,
  "action": "force_released"
}
```

---

## Best Practices

1. **Always warm up cache at orchestrator start** - reduces perceived latency
2. **Never skip dependency analysis** - prevents test pollution
3. **Use file-level locks for source, directory-level for tests** - balance granularity vs safety
4. **Log all orchestration decisions** - enables debugging and tuning
5. **Respect max 6 agents per batch** - prevents resource exhaustion
