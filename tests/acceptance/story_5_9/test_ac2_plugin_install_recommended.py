"""
Story 5.9: Update Documentation
AC2: Plugin Install documented as recommended

Tests that verify Plugin Install is clearly marked as recommended,
with single-command installation prominently featured.

Test IDs: TEST-AC-5.9.2.x
Priority: [P0] - Core documentation requirement
"""

import re
from pathlib import Path

import pytest


@pytest.fixture
def readme_content() -> str:
    """Load the README.md content for testing."""
    readme_path = Path(__file__).parent.parent.parent.parent / "README.md"
    return readme_path.read_text()


class TestAC2PluginInstallRecommended:
    """
    AC2: Plugin Install documented as recommended

    Given a new user looking to install the toolkit
    When they read the Installation section
    Then Plugin Install is clearly marked as the recommended method
    And the single-command installation is prominently featured
    And the `claude --plugin-dir ./plugin` command is documented
    """

    def test_ac_5_9_2_1_plugin_install_marked_recommended(self, readme_content: str) -> None:
        """TEST-AC-5.9.2.1: [P0] Plugin Install is marked as recommended."""
        # Given: A new user looking to install the toolkit
        # When: They read the Installation section
        # Then: Plugin Install is clearly marked as recommended

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Look for "Recommended" near "Plugin Install"
        # Common patterns: "Recommended: Plugin Install", "Plugin Install (Recommended)"
        recommended_plugin = re.search(
            r"(recommended[:\s]*plugin|plugin[^\n]*recommended)",
            installation_section,
            re.IGNORECASE
        )
        assert recommended_plugin, (
            "Plugin Install must be clearly marked as the recommended method. "
            "Expected text like 'Recommended: Plugin Install' or 'Plugin Install (Recommended)'"
        )

    def test_ac_5_9_2_2_single_command_prominently_featured(self, readme_content: str) -> None:
        """TEST-AC-5.9.2.2: [P0] Single-command installation is prominently featured."""
        # Given: A new user looking to install the toolkit
        # When: They read the Installation section
        # Then: The single-command installation is prominently featured

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Look for the plugin command in a code block, appearing BEFORE the file install steps
        # The plugin command should appear early in the section (first half)
        plugin_command_pos = installation_section.find("claude --plugin-dir")

        assert plugin_command_pos != -1, (
            "Plugin installation command must be present in Installation section"
        )

        # Verify it appears in a code block (```...```)
        code_block_match = re.search(
            r"```[^\n]*\n[^`]*claude\s+--plugin-dir[^`]*```",
            installation_section
        )
        assert code_block_match, (
            "Plugin installation command must be in a code block for prominence"
        )

        # It should be positioned prominently (in the first subsection about plugin)
        recommended_subsection = re.search(
            r"(###?\s*[^\n]*recommended[^\n]*|###?\s*plugin\s*install)",
            installation_section,
            re.IGNORECASE
        )
        assert recommended_subsection, (
            "Single-command installation should be in a clearly labeled subsection "
            "like '### Recommended: Plugin Install'"
        )

    def test_ac_5_9_2_3_plugin_dir_command_documented(self, readme_content: str) -> None:
        """TEST-AC-5.9.2.3: [P0] The claude --plugin-dir ./plugin command is documented."""
        # Given: A new user looking to install the toolkit
        # When: They read the Installation section
        # Then: The exact command is documented

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # The exact command should be present
        has_exact_command = re.search(
            r"claude\s+--plugin-dir\s+\.?/?plugin",
            installation_section
        )
        assert has_exact_command, (
            "The command 'claude --plugin-dir ./plugin' must be documented "
            "in the Installation section"
        )

    def test_ac_5_9_2_4_plugin_install_has_subsection(self, readme_content: str) -> None:
        """TEST-AC-5.9.2.4: [P1] Plugin Install has its own subsection."""
        # Given: A new user reading the Installation section
        # When: They look for how to install
        # Then: There is a clear subsection for Plugin Install

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Look for a subsection header about Plugin Install
        has_plugin_subsection = re.search(
            r"###?\s*[^\n]*(plugin\s*install|recommended)[^\n]*\n",
            installation_section,
            re.IGNORECASE
        )
        assert has_plugin_subsection, (
            "Installation section must have a clear subsection for Plugin Install "
            "(e.g., '### Recommended: Plugin Install')"
        )
