"""
Story 5.9: Update Documentation
AC3: File Install preserved for power users

Tests that verify File Install method is still fully documented
and positioned as the power user option with all 5 copy steps.

Test IDs: TEST-AC-5.9.3.x
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


class TestAC3FileInstallPreserved:
    """
    AC3: File Install preserved for power users

    Given an experienced user who prefers manual installation
    When they read the Installation section
    Then the File Install method is still fully documented
    And it is positioned as the "power user" option
    And all 5 copy steps remain available
    """

    def test_ac_5_9_3_1_file_install_documented(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.1: [P0] File Install method is fully documented."""
        # Given: An experienced user who prefers manual installation
        # When: They read the Installation section
        # Then: The File Install method is still fully documented

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # File Install section should exist
        file_install_exists = re.search(
            r"(file\s*install|alternative|manual\s*install|power\s*user)",
            installation_section,
            re.IGNORECASE
        )
        assert file_install_exists, (
            "File Install method must be documented in the Installation section"
        )

    def test_ac_5_9_3_2_positioned_as_power_user_option(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.2: [P0] File Install is positioned as power user option."""
        # Given: An experienced user reading the Installation section
        # When: They look for manual installation
        # Then: It is positioned as the power user option

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Look for "power user", "alternative", "advanced", or similar positioning
        power_user_positioning = re.search(
            r"(power\s*user|alternative|advanced|manual|experienced)",
            installation_section,
            re.IGNORECASE
        )
        assert power_user_positioning, (
            "File Install must be positioned as the 'power user' or 'alternative' option"
        )

        # The File Install section should appear AFTER the Plugin Install section
        plugin_pos = re.search(
            r"(recommended.*plugin|plugin.*recommended)",
            installation_section,
            re.IGNORECASE
        )
        file_pos = re.search(
            r"(alternative|power\s*user|file\s*install)",
            installation_section,
            re.IGNORECASE
        )

        if plugin_pos and file_pos:
            assert file_pos.start() > plugin_pos.start(), (
                "File Install (power user option) should appear AFTER "
                "Plugin Install (recommended) in the Installation section"
            )

    def test_ac_5_9_3_3_clone_step_available(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.3: [P0] Clone step is available for File Install."""
        # Given: An experienced user following File Install
        # When: They look for steps
        # Then: Clone step is available

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Clone command should be present
        has_clone = "git clone" in installation_section
        assert has_clone, (
            "File Install must include the git clone step"
        )

    def test_ac_5_9_3_4_backup_step_available(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.4: [P0] Backup step is available for File Install."""
        # Given: An experienced user following File Install
        # When: They look for steps
        # Then: Backup step is available

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Backup command or instruction should be present
        has_backup = re.search(
            r"(backup|cp\s+-r\s+~/.claude\s+~/.claude\.backup)",
            installation_section,
            re.IGNORECASE
        )
        assert has_backup, (
            "File Install must include the backup step"
        )

    def test_ac_5_9_3_5_copy_commands_step_available(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.5: [P0] Copy commands step is available for File Install."""
        # Given: An experienced user following File Install
        # When: They look for copy steps
        # Then: Copy commands for commands/, agents/, skills/ are available

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # All three copy commands should be present
        has_copy_commands = "cp -r commands/" in installation_section
        has_copy_agents = "cp -r agents/" in installation_section
        has_copy_skills = "cp -r skills/" in installation_section

        assert has_copy_commands and has_copy_agents and has_copy_skills, (
            "File Install must include copy commands for commands/, agents/, and skills/"
        )

    def test_ac_5_9_3_6_start_session_step_available(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.6: [P0] Start session step is available for File Install."""
        # Given: An experienced user following File Install
        # When: They look for final steps
        # Then: Start new session instruction is available

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Should mention starting a new session
        has_session_step = re.search(
            r"(start|new)\s*(a\s*)?(claude\s*code\s*)?(session|terminal)",
            installation_section,
            re.IGNORECASE
        )
        assert has_session_step, (
            "File Install must include step to start a new Claude Code session"
        )

    def test_ac_5_9_3_7_verify_step_available(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.7: [P0] Verify step is available for File Install."""
        # Given: An experienced user following File Install
        # When: They look for verification
        # Then: Verify installation instruction is available

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Should mention verification
        has_verify = re.search(
            r"(verify|confirm|check).*install",
            installation_section,
            re.IGNORECASE
        )
        assert has_verify, (
            "File Install must include step to verify installation"
        )

    def test_ac_5_9_3_8_all_five_steps_present(self, readme_content: str) -> None:
        """TEST-AC-5.9.3.8: [P0] All 5 original File Install steps remain available."""
        # Given: An experienced user reading File Install documentation
        # When: They count the steps
        # Then: All 5 original steps are present

        installation_match = re.search(
            r"## Installation\s*(.*?)(?=\n## |\Z)",
            readme_content,
            re.DOTALL
        )
        assert installation_match is not None, "Installation section must exist"

        installation_section = installation_match.group(1)

        # Count the presence of all 5 steps:
        # 1. Clone
        # 2. Backup
        # 3. Copy (commands, agents, skills)
        # 4. Start session
        # 5. Verify

        steps_present = [
            "git clone" in installation_section,  # Step 1
            "backup" in installation_section.lower(),  # Step 2
            "cp -r" in installation_section,  # Step 3
            bool(re.search(r"(start|new).*session", installation_section, re.IGNORECASE)),  # Step 4
            bool(re.search(r"verify", installation_section, re.IGNORECASE)),  # Step 5
        ]

        steps_count = sum(steps_present)
        assert steps_count >= 5, (
            f"File Install must have all 5 steps present. Found {steps_count}/5 steps. "
            f"Missing steps: Clone={steps_present[0]}, Backup={steps_present[1]}, "
            f"Copy={steps_present[2]}, Session={steps_present[3]}, Verify={steps_present[4]}"
        )
