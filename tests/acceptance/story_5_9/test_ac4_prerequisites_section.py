"""
Story 5.9: Update Documentation
AC4: Prerequisites section added

Tests that verify a Prerequisites section exists with clear requirements
listing Claude Code CLI (required), MCP servers (optional), and BMAD (optional).

Test IDs: TEST-AC-5.9.4.x
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


class TestAC4PrerequisitesSection:
    """
    AC4: Prerequisites section added

    Given a user preparing to install
    When they read the Prerequisites section
    Then they see a clear list of requirements:
      - Claude Code CLI (required)
      - MCP servers (optional, with pointer to setup guide)
      - BMAD framework (optional, for epic-dev commands)
    And they understand what's required vs optional
    """

    def test_ac_5_9_4_1_prerequisites_section_exists(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.1: [P0] Prerequisites section exists in README."""
        # Given: A user preparing to install
        # When: They look for prerequisites
        # Then: A Prerequisites section exists

        # Look for a section titled "Prerequisites" or "Requirements"
        # positioned before Installation
        has_prerequisites_section = re.search(
            r"##\s*Prerequisites",
            readme_content,
            re.IGNORECASE
        )
        assert has_prerequisites_section, (
            "README must have a '## Prerequisites' section"
        )

    def test_ac_5_9_4_2_prerequisites_before_installation(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.2: [P0] Prerequisites section appears before Installation."""
        # Given: A user reading the README
        # When: They look for prerequisites
        # Then: Prerequisites appears before Installation

        prereq_match = re.search(r"##\s*Prerequisites", readme_content, re.IGNORECASE)
        install_match = re.search(r"##\s*Installation", readme_content, re.IGNORECASE)

        assert prereq_match is not None, "Prerequisites section must exist"
        assert install_match is not None, "Installation section must exist"

        assert prereq_match.start() < install_match.start(), (
            "Prerequisites section must appear BEFORE Installation section"
        )

    def test_ac_5_9_4_3_claude_code_cli_required(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.3: [P0] Claude Code CLI is listed as required."""
        # Given: A user reading Prerequisites
        # When: They look at requirements
        # Then: Claude Code CLI is listed as required

        prereq_match = re.search(
            r"##\s*Prerequisites\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL | re.IGNORECASE
        )
        assert prereq_match is not None, "Prerequisites section must exist"

        prereq_section = prereq_match.group(1)

        # Claude Code should be mentioned
        has_claude_code = re.search(
            r"claude\s*code",
            prereq_section,
            re.IGNORECASE
        )
        assert has_claude_code, (
            "Prerequisites must list Claude Code CLI"
        )

        # It should be marked as required
        has_required_marker = re.search(
            r"(required|must\s*have|necessary)",
            prereq_section,
            re.IGNORECASE
        )
        assert has_required_marker, (
            "Claude Code CLI must be marked as required in Prerequisites"
        )

    def test_ac_5_9_4_4_mcp_servers_optional(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.4: [P0] MCP servers are listed as optional."""
        # Given: A user reading Prerequisites
        # When: They look at requirements
        # Then: MCP servers are listed as optional

        prereq_match = re.search(
            r"##\s*Prerequisites\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL | re.IGNORECASE
        )
        assert prereq_match is not None, "Prerequisites section must exist"

        prereq_section = prereq_match.group(1)

        # MCP should be mentioned
        has_mcp = re.search(
            r"mcp\s*(server)?s?",
            prereq_section,
            re.IGNORECASE
        )
        assert has_mcp, (
            "Prerequisites must list MCP servers"
        )

        # It should be marked as optional
        has_optional_marker = re.search(
            r"optional",
            prereq_section,
            re.IGNORECASE
        )
        assert has_optional_marker, (
            "MCP servers must be marked as optional in Prerequisites"
        )

    def test_ac_5_9_4_5_mcp_has_setup_guide_link(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.5: [P1] MCP servers entry has pointer to setup guide."""
        # Given: A user reading Prerequisites
        # When: They see MCP servers listed
        # Then: There is a pointer to the setup guide

        prereq_match = re.search(
            r"##\s*Prerequisites\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL | re.IGNORECASE
        )
        assert prereq_match is not None, "Prerequisites section must exist"

        prereq_section = prereq_match.group(1)

        # Should have a link to MCP setup documentation
        has_mcp_link = re.search(
            r"(MCP_SETUP\.md|mcp.*guide|setup.*mcp)",
            prereq_section,
            re.IGNORECASE
        )
        assert has_mcp_link, (
            "Prerequisites must include a pointer to MCP setup guide (MCP_SETUP.md)"
        )

    def test_ac_5_9_4_6_bmad_framework_optional(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.6: [P0] BMAD framework is listed as optional."""
        # Given: A user reading Prerequisites
        # When: They look at requirements
        # Then: BMAD framework is listed as optional

        prereq_match = re.search(
            r"##\s*Prerequisites\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL | re.IGNORECASE
        )
        assert prereq_match is not None, "Prerequisites section must exist"

        prereq_section = prereq_match.group(1)

        # BMAD should be mentioned
        has_bmad = re.search(
            r"bmad",
            prereq_section,
            re.IGNORECASE
        )
        assert has_bmad, (
            "Prerequisites must list BMAD framework"
        )

    def test_ac_5_9_4_7_bmad_associated_with_epic_dev(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.7: [P1] BMAD entry mentions epic-dev commands."""
        # Given: A user reading Prerequisites
        # When: They see BMAD listed
        # Then: It mentions it's for epic-dev commands

        prereq_match = re.search(
            r"##\s*Prerequisites\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL | re.IGNORECASE
        )
        assert prereq_match is not None, "Prerequisites section must exist"

        prereq_section = prereq_match.group(1)

        # Should associate BMAD with epic-dev commands
        has_epic_dev_mention = re.search(
            r"(bmad.*epic|epic.*bmad|epic-dev)",
            prereq_section,
            re.IGNORECASE
        )
        assert has_epic_dev_mention, (
            "Prerequisites must mention BMAD is for epic-dev commands"
        )

    def test_ac_5_9_4_8_clear_required_vs_optional(self, readme_content: str) -> None:
        """TEST-AC-5.9.4.8: [P0] User can clearly distinguish required vs optional."""
        # Given: A user reading Prerequisites
        # When: They want to understand what's necessary
        # Then: They can clearly distinguish required vs optional

        prereq_match = re.search(
            r"##\s*Prerequisites\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL | re.IGNORECASE
        )
        assert prereq_match is not None, "Prerequisites section must exist"

        prereq_section = prereq_match.group(1)

        # Section should have BOTH "required" and "optional" terminology
        has_required = re.search(r"required", prereq_section, re.IGNORECASE)
        has_optional = re.search(r"optional", prereq_section, re.IGNORECASE)

        assert has_required and has_optional, (
            "Prerequisites section must clearly distinguish between "
            "'required' and 'optional' items so users understand what's necessary"
        )
