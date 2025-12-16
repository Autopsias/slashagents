#!/bin/bash
cd /Users/ricardocarvalho/CC_Agents_Commands
for agent in unit-test-fixer api-test-fixer database-test-fixer e2e-test-fixer linting-fixer type-error-fixer import-error-fixer security-scanner pr-workflow-manager parallel-executor digdeep; do
  if [ -f "agents/${agent}.md" ]; then
    echo "✓ $agent.md exists"
  else
    echo "✗ $agent.md MISSING"
  fi
done
