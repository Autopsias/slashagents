"""
Story 5.9: Update Documentation
Edge Cases and Integration Tests

Tests for edge cases, error scenarios, and cross-section integration
that weren't covered in the core acceptance criteria tests.

Priority: [P2-P3] - Edge case coverage
"""

import re
from pathlib import Path

import pytest


@pytest.fixture
def readme_content() -> str:
    """Load the README.md content for testing."""
    readme_path = Path(__file__).parent.parent.parent.parent / "README.md"
    return readme_path.read_text()


@pytest.fixture
def readme_sections(readme_content: str) -> dict:
    """Parse README into major sections."""
    sections = {}
    current_section = None
    current_content = []

    for line in readme_content.split('\n'):
        if line.startswith('## '):
            if current_section:
                sections[current_section] = '\n'.join(current_content)
            current_section = line[3:].strip()
            current_content = []
        else:
            current_content.append(line)

    if current_section:
        sections[current_section] = '\n'.join(current_content)

    return sections


class TestEdgeCasesAndIntegration:
    """Edge cases and integration tests for Story 5.9."""

    def test_p2_version_number_format_valid(self, readme_content: str) -> None:
        """[P2] Version number follows semantic versioning (X.Y.Z)."""
        version_match = re.search(r'\*\*Version:\*\*\s+(\d+\.\d+\.\d+)', readme_content)
        assert version_match, "Version metadata must exist in README header"

        version = version_match.group(1)
        parts = version.split('.')
        assert len(parts) == 3, f"Version must be X.Y.Z format, got: {version}"
        assert all(p.isdigit() for p in parts), f"Version parts must be numeric, got: {version}"

    def test_p2_version_updated_date_format(self, readme_content: str) -> None:
        """[P2] Updated date follows YYYY-MM-DD format."""
        date_match = re.search(r'\*\*Updated:\*\*\s+(\d{4}-\d{2}-\d{2})', readme_content)
        assert date_match, "Updated date must exist in README header"

        date_str = date_match.group(1)
        year, month, day = map(int, date_str.split('-'))
        assert 2020 <= year <= 2030, f"Year seems invalid: {year}"
        assert 1 <= month <= 12, f"Month invalid: {month}"
        assert 1 <= day <= 31, f"Day invalid: {day}"

    def test_p1_mcp_setup_link_consistent_across_sections(self, readme_sections: dict) -> None:
        """[P1] MCP_SETUP.md link is consistent in Prerequisites and Installation."""

        prereq_section = readme_sections.get('Prerequisites', '')
        install_section = readme_sections.get('Installation', '')

        prereq_link = re.search(r'\[plugin/MCP_SETUP\.md\]|MCP_SETUP\.md', prereq_section)
        install_link = re.search(r'\[plugin/MCP_SETUP\.md\]|MCP_SETUP\.md', install_section)

        assert prereq_link, "Prerequisites should reference MCP_SETUP.md"
        assert install_link, "Installation should reference MCP_SETUP.md"

    def test_p2_installation_table_properly_formatted(self, readme_sections: dict) -> None:
        """[P2] Installation comparison table has valid markdown table format."""

        install_section = readme_sections.get('Installation', '')

        # Extract table (lines with | separators)
        table_lines = [line for line in install_section.split('\n') if '|' in line]
        assert len(table_lines) >= 3, "Table must have header, separator, and at least one data row"

        # Check header separator row (contains --- pattern)
        separator_found = any('---' in line for line in table_lines)
        assert separator_found, "Table must have markdown separator row with ---"

    def test_p1_plugin_command_exact_format(self, readme_sections: dict) -> None:
        """[P1] Plugin install command uses exact format 'claude --plugin-dir ./plugin'."""

        install_section = readme_sections.get('Installation', '')

        # Must use ./plugin (not /plugin or plugin/)
        has_correct_format = re.search(
            r'claude\s+--plugin-dir\s+\./plugin\b',
            install_section
        )
        assert has_correct_format, (
            "Plugin command must use exact format: 'claude --plugin-dir ./plugin'"
        )

    def test_p2_file_install_all_copy_commands_present(self, readme_sections: dict) -> None:
        """[P2] File Install includes all three copy commands (commands, agents, skills)."""

        install_section = readme_sections.get('Installation', '')

        has_commands = 'cp -r commands/' in install_section
        has_agents = 'cp -r agents/' in install_section
        has_skills = 'cp -r skills/' in install_section

        missing = []
        if not has_commands:
            missing.append('commands/')
        if not has_agents:
            missing.append('agents/')
        if not has_skills:
            missing.append('skills/')

        assert not missing, (
            f"File Install must document copying all directories. Missing: {', '.join(missing)}"
        )

    def test_p3_quick_start_examples_match_installation_methods(self, readme_sections: dict) -> None:
        """[P3] Quick Start section examples work regardless of installation method."""

        quick_start = readme_sections.get('Quick Start', '')

        # Quick Start should use short command names (work with aliases OR direct files)
        # Should NOT use fully namespaced commands like /cc-agents-commands:pr
        namespaced_commands = re.findall(r'/[a-z-]+:[a-z-]+', quick_start)
        assert not namespaced_commands, (
            f"Quick Start should use short names, not namespaced commands. "
            f"Found: {namespaced_commands}"
        )

    def test_p2_prerequisites_ordered_correctly(self, readme_content: str) -> None:
        """[P2] Prerequisites section appears BEFORE Installation section."""

        prereq_pos = readme_content.find('## Prerequisites')
        install_pos = readme_content.find('## Installation')

        # Both must exist
        assert prereq_pos != -1, "Prerequisites section must exist"
        assert install_pos != -1, "Installation section must exist"

        # Prerequisites must come before Installation
        assert prereq_pos < install_pos, (
            "Prerequisites must appear before Installation section"
        )

    def test_p3_no_hardcoded_github_urls(self, readme_content: str) -> None:
        """[P3] GitHub clone URL uses correct repository path."""

        clone_match = re.search(
            r'git clone https://github\.com/([^/]+)/([^/\s]+)',
            readme_content
        )
        assert clone_match, "Git clone command must be present"

        owner = clone_match.group(1)
        repo = clone_match.group(2)

        # Verify it's the correct repository (not a hardcoded example)
        assert owner == "Autopsias", f"Repository owner should be 'Autopsias', got: {owner}"
        assert repo == "claude-agents-commands.git", f"Repository name should be 'claude-agents-commands.git', got: {repo}"

    def test_p2_plugin_install_benefits_documented(self, readme_sections: dict) -> None:
        """[P2] Plugin Install section mentions key benefits (MCP configs, aliases, hooks)."""

        install_section = readme_sections.get('Installation', '')

        # Extract Plugin Install subsection (between "Plugin Install" and next ###)
        plugin_match = re.search(
            r'###.*?Plugin Install.*?\n(.*?)(?=\n### |\Z)',
            install_section,
            re.DOTALL | re.IGNORECASE
        )
        assert plugin_match, "Plugin Install subsection must exist"

        plugin_section = plugin_match.group(1)

        # Check mentions of key features
        has_mcp_mention = 'mcp' in plugin_section.lower() or '.mcp.json' in plugin_section
        has_alias_mention = 'alias' in plugin_section.lower()
        has_hooks_mention = 'hook' in plugin_section.lower() or 'hooks.json' in plugin_section

        benefits = []
        if has_mcp_mention:
            benefits.append('MCP configs')
        if has_alias_mention:
            benefits.append('aliases')
        if has_hooks_mention:
            benefits.append('hooks')

        assert len(benefits) >= 2, (
            f"Plugin Install should mention key benefits (MCP, aliases, hooks). "
            f"Found: {', '.join(benefits)}"
        )

    def test_p2_file_install_warning_about_overwrites(self, readme_sections: dict) -> None:
        """[P2] File Install warns users about overwriting existing files."""

        install_section = readme_sections.get('Installation', '')

        # Look for warning indicators
        has_warning = re.search(
            r'(⚠️|warning|backup|overwrite)',
            install_section,
            re.IGNORECASE
        )
        assert has_warning, (
            "File Install should warn users about backing up or overwriting existing files"
        )

    def test_p3_contents_table_matches_reality(self, readme_sections: dict) -> None:
        """[P3] Contents table counts (18 commands, 35 agents, 2 skills) match text."""

        contents = readme_sections.get('Contents', '')

        # Extract counts from table
        commands_match = re.search(r'Commands.*?(\d+)', contents, re.IGNORECASE)
        agents_match = re.search(r'Agents.*?(\d+)', contents, re.IGNORECASE)
        skills_match = re.search(r'Skills.*?(\d+)', contents, re.IGNORECASE)

        assert commands_match, "Commands count must be in Contents table"
        assert agents_match, "Agents count must be in Contents table"
        assert skills_match, "Skills count must be in Contents table"

        # Verify expected counts (from story context)
        assert commands_match.group(1) == '18', f"Commands count should be 18, got: {commands_match.group(1)}"
        assert agents_match.group(1) == '35', f"Agents count should be 35, got: {agents_match.group(1)}"
        assert skills_match.group(1) == '2', f"Skills count should be 2, got: {skills_match.group(1)}"

    def test_p1_bmad_repository_link_provided(self, readme_sections: dict) -> None:
        """[P1] BMAD framework prerequisite includes link to BMAD repository."""

        prereq_section = readme_sections.get('Prerequisites', '')

        # Check for BMAD repository reference
        has_bmad_link = re.search(
            r'(github\.com.*bmad|bmad.*repository|bmad.*github)',
            prereq_section,
            re.IGNORECASE
        )
        assert has_bmad_link, (
            "Prerequisites should provide link to BMAD repository for users to install"
        )

    def test_p2_installation_table_column_consistency(self, readme_sections: dict) -> None:
        """[P2] Installation comparison table has consistent column count across all rows."""

        install_section = readme_sections.get('Installation', '')

        # Extract table rows
        table_lines = [
            line.strip() for line in install_section.split('\n')
            if '|' in line and line.strip()
        ]

        # TEST-AC-5.9.X: Assert valid table exists (FIXED: replaced pytest.skip antipattern)
        assert len(table_lines) >= 3, (
            "Invalid table found - requires header, separator, and at least one data row"
        )

        # Count columns in each row (count | separators)
        column_counts = [line.count('|') for line in table_lines]

        # All rows should have same column count
        unique_counts = set(column_counts)
        assert len(unique_counts) == 1, (
            f"Table rows have inconsistent column counts: {column_counts}. "
            f"All rows should have {max(column_counts)} columns."
        )
