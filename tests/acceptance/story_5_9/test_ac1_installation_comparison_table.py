"""
Story 5.9: Update Documentation
AC1: Installation comparison table

Tests that verify the README contains a clear comparison table showing
Plugin Install vs File Install methods with pros, cons, and recommendations.

Test IDs: TEST-AC-5.9.1.x
Priority: [P0] - Core documentation requirement
"""

import re
from pathlib import Path

import pytest


# Fixture to load README content
@pytest.fixture
def readme_content() -> str:
    """Load the README.md content for testing."""
    readme_path = Path(__file__).parent.parent.parent.parent / "README.md"
    return readme_path.read_text()


class TestAC1InstallationComparisonTable:
    """
    AC1: Installation comparison table

    Given a user reading the README
    When they reach the Installation section
    Then they see a clear comparison table showing:
      - Plugin Install vs File Install methods
      - Pros and cons of each approach
      - When to use each method (recommended scenarios)
      - Required commands for each method
    """

    def test_ac_5_9_1_1_comparison_table_exists(self, readme_content: str) -> None:
        """TEST-AC-5.9.1.1: [P0] Installation section contains a comparison table."""
        # Given: A user reading the README
        # When: They reach the Installation section
        # Then: A comparison table exists

        # Find the Installation section
        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Verify a table exists in the Installation section
        # Tables in markdown have | characters and header separator rows (---)
        table_pattern = r"\|.*\|.*\n\|[-: |]+\|"
        assert re.search(table_pattern, installation_section), (
            "Installation section must contain a comparison table with "
            "Plugin Install vs File Install methods"
        )

    def test_ac_5_9_1_2_table_shows_plugin_install_method(self, readme_content: str) -> None:
        """TEST-AC-5.9.1.2: [P0] Comparison table includes Plugin Install method."""
        # Given: A user reading the comparison table
        # When: They look for installation methods
        # Then: Plugin Install is listed as a method

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # The table should show "Plugin Install" or "Plugin" as a method
        assert re.search(
            r"plugin\s*install|plugin\s*\|",
            installation_section,
            re.IGNORECASE
        ), "Comparison table must include Plugin Install method"

    def test_ac_5_9_1_3_table_shows_file_install_method(self, readme_content: str) -> None:
        """TEST-AC-5.9.1.3: [P0] Comparison table includes File Install method."""
        # Given: A user reading the comparison table
        # When: They look for installation methods
        # Then: File Install is listed as a method

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # The table should show "File Install" or "File" or "Manual" as a method
        assert re.search(
            r"file\s*install|file\s*\||manual\s*install",
            installation_section,
            re.IGNORECASE
        ), "Comparison table must include File Install method"

    def test_ac_5_9_1_4_table_shows_pros_and_cons(self, readme_content: str) -> None:
        """TEST-AC-5.9.1.4: [P0] Comparison table includes pros and cons."""
        # Given: A user reading the comparison table
        # When: They want to understand trade-offs
        # Then: Pros and cons are shown for each method

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Table headers or content should indicate pros/cons
        # Could be "Pros", "Cons", "Advantages", "Disadvantages", or similar
        has_pros_cons = (
            re.search(r"pros|advantages|benefits", installation_section, re.IGNORECASE)
            and re.search(r"cons|disadvantages|limitations", installation_section, re.IGNORECASE)
        )
        assert has_pros_cons, (
            "Comparison table must show pros and cons of each approach"
        )

    def test_ac_5_9_1_5_table_shows_recommended_scenarios(self, readme_content: str) -> None:
        """TEST-AC-5.9.1.5: [P0] Comparison table includes when to use each method."""
        # Given: A user reading the comparison table
        # When: They want guidance on which method to choose
        # Then: Recommended scenarios are provided

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Table should indicate when to use each method
        # Could be "Best For", "When to Use", "Recommended For", "Use Case"
        has_scenarios = re.search(
            r"best\s*for|when\s*to\s*use|recommended\s*for|use\s*case",
            installation_section,
            re.IGNORECASE
        )
        assert has_scenarios, (
            "Comparison table must indicate when to use each method (recommended scenarios)"
        )

    def test_ac_5_9_1_6_table_shows_required_commands(self, readme_content: str) -> None:
        """TEST-AC-5.9.1.6: [P0] Comparison table includes required commands."""
        # Given: A user reading the comparison table
        # When: They want to know the exact commands
        # Then: Required commands are shown for each method

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Plugin command should be shown
        has_plugin_command = "claude --plugin-dir" in installation_section

        # File copy commands should be shown (cp commands)
        has_copy_command = re.search(r"cp\s+-r", installation_section)

        assert has_plugin_command and has_copy_command, (
            "Comparison table must show required commands for both methods "
            "(claude --plugin-dir for plugin, cp -r for file install)"
        )
