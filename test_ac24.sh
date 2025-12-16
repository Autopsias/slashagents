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

# This is the EXACT test from line 175-176 of the test script
if echo "$AGENTS_SECTION" | grep 'parallel-executor' | grep -qE '---|—'; then
    echo "PASS"
    exit 0
else
    echo "FAIL"
    exit 1
fi
