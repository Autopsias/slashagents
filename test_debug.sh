#!/bin/bash
README_PATH="README.md"
START_LINE=$(grep -n '^## Agents Reference' "$README_PATH" | head -1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    END_LINE=$(tail -n +$((START_LINE + 1)) "$README_PATH" | grep -n '^## ' | head -1 | cut -d: -f1)
    if [ -n "$END_LINE" ]; then
        END_LINE=$((START_LINE + END_LINE - 1))
        AGENTS_SECTION=$(sed -n "${START_LINE},${END_LINE}p" "$README_PATH")
    else
        AGENTS_SECTION=$(tail -n +${START_LINE} "$README_PATH")
    fi
else
    AGENTS_SECTION=""
fi

echo "=== Testing AC2.4 ==="
echo "$AGENTS_SECTION" | grep 'parallel-executor'
echo "Testing with -- separator:"
echo "$AGENTS_SECTION" | grep 'parallel-executor' | grep -qE -- '---|—' && echo "MATCH FOUND" || echo "NO MATCH"
echo "Testing just em dash:"
echo "$AGENTS_SECTION" | grep 'parallel-executor' | grep -qE -- '—' && echo "EM DASH MATCH" || echo "NO EM DASH"

echo ""
echo "=== Testing AC3.1 (agent count) ==="
echo "$AGENTS_SECTION" | grep -oE '\`[a-z-]+-fixer\`|\`[a-z-]+-scanner\`|\`[a-z-]+-manager\`|\`[a-z-]+-executor\`|\`digdeep\`' | sort -u | wc -l

echo ""
echo "=== Testing EC4.1 (duplicates) ==="
echo "$AGENTS_SECTION" | grep -oE '[a-z]+-fixer|[a-z]+-scanner|[a-z]+-manager|[a-z]+-executor|digdeep' | sort | uniq -d
