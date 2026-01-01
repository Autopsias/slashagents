#!/usr/bin/env python3
"""
testgates_discovery.py
Discovers test gates from project documentation (epics.md)
Outputs JSON format configuration for test gate execution
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional


def find_epics_file(project_root: Path) -> Optional[Path]:
    """Find epics.md file in common documentation locations."""
    search_paths = [
        project_root / "docs" / "epics.md",
        project_root / "docs" / "planning-artifacts" / "epics.md",
        project_root / "docs" / "sprint-artifacts" / "epics.md",
        project_root / "epics.md",
    ]

    for path in search_paths:
        if path.exists():
            return path

    return None


def parse_test_gates(epics_content: str) -> List[Dict[str, str]]:
    """
    Parse test gates from epics.md content.

    Expected format:
    ### Test Gate: <name>
    - **Trigger:** <condition>
    - **Command:** `<command>`
    - **Purpose:** <description>
    """
    test_gates = []

    # Find test gate sections
    gate_pattern = r"###\s+Test Gate:\s+(.+?)\n(.*?)(?=###|$)"
    matches = re.finditer(gate_pattern, epics_content, re.DOTALL)

    for match in matches:
        gate_name = match.group(1).strip()
        gate_content = match.group(2).strip()

        # Extract fields
        trigger_match = re.search(r"\*\*Trigger:\*\*\s+(.+)", gate_content)
        command_match = re.search(r"\*\*Command:\*\*\s+`(.+?)`", gate_content)
        purpose_match = re.search(r"\*\*Purpose:\*\*\s+(.+)", gate_content)

        test_gate = {
            "name": gate_name,
            "trigger": trigger_match.group(1).strip() if trigger_match else "",
            "command": command_match.group(1).strip() if command_match else "",
            "purpose": purpose_match.group(1).strip() if purpose_match else "",
        }

        test_gates.append(test_gate)

    return test_gates


def get_next_test_gate(
    test_gates: List[Dict[str, str]], current_story: Optional[str] = None
) -> Optional[Dict[str, str]]:
    """
    Determine the next test gate to execute based on current story status.

    Logic:
    - If no current story provided, return first gate
    - Match story completion triggers to gate triggers
    - Return next applicable gate
    """
    if not test_gates:
        return None

    if not current_story:
        return test_gates[0] if test_gates else None

    # Simple logic: return first gate for now
    # Can be enhanced with story status matching
    return test_gates[0] if test_gates else None


def main():
    parser = argparse.ArgumentParser(
        description="Discover test gates from project documentation"
    )
    parser.add_argument(
        "project_root",
        type=Path,
        help="Project root directory to search for epics.md",
    )
    parser.add_argument(
        "--format",
        choices=["json", "text"],
        default="json",
        help="Output format (default: json)",
    )
    parser.add_argument(
        "--story",
        type=str,
        help="Current story key to determine next test gate",
    )

    args = parser.parse_args()

    # Find epics file
    epics_file = find_epics_file(args.project_root)

    if not epics_file:
        if args.format == "json":
            print(json.dumps({"error": "epics.md not found", "test_gates": []}))
        else:
            print("Error: epics.md not found in project", file=sys.stderr)
        sys.exit(1)

    # Parse test gates
    with open(epics_file, "r", encoding="utf-8") as f:
        epics_content = f.read()

    test_gates = parse_test_gates(epics_content)

    # Get next test gate if story provided
    if args.story:
        next_gate = get_next_test_gate(test_gates, args.story)
        result = {"next_gate": next_gate, "all_gates": test_gates}
    else:
        result = {"test_gates": test_gates}

    # Output
    if args.format == "json":
        print(json.dumps(result, indent=2))
    else:
        if args.story and next_gate:
            print(f"Next Test Gate: {next_gate['name']}")
            print(f"Command: {next_gate['command']}")
            print(f"Purpose: {next_gate['purpose']}")
        else:
            for gate in test_gates:
                print(f"\nTest Gate: {gate['name']}")
                print(f"  Trigger: {gate['trigger']}")
                print(f"  Command: {gate['command']}")
                print(f"  Purpose: {gate['purpose']}")


if __name__ == "__main__":
    main()
