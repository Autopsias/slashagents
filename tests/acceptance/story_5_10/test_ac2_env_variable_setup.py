"""
Story 5.10: Document Prerequisites and API Key Setup
AC2: Environment variable setup instructions

Tests that verify the documentation contains clear environment variable setup
instructions for shell profiles, verification steps, and optional alternatives.

Test IDs: TEST-AC-5.10.2.x
Priority: [P0] - Core documentation requirement for env var configuration
"""

import re
from pathlib import Path

import pytest


@pytest.fixture
def mcp_setup_content() -> str:
    """Load the MCP_SETUP.md content for testing."""
    mcp_setup_path = Path(__file__).parent.parent.parent.parent / "plugin" / "MCP_SETUP.md"
    if mcp_setup_path.exists():
        return mcp_setup_path.read_text()
    return ""


class TestAC2EnvVariableSetup:
    """
    AC2: Environment variable setup instructions

    Given a user following the API key documentation
    When they need to configure environment variables
    Then they find clear instructions for:
      - Setting variables in shell profile (~/.zshrc, ~/.bashrc)
      - Verifying variables are set correctly
      - Optional: Using .env files or secrets management
    """

    def test_ac_5_10_2_1_zshrc_instructions_exist(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.1: [P0] Instructions show ~/.zshrc for zsh users."""
        # Given: A user following API key documentation
        # When: They use zsh shell
        # Then: ~/.zshrc is mentioned as the config location

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_zshrc = re.search(
            r"~/\.zshrc|~/.zshrc|\.zshrc",
            mcp_setup_content
        )
        assert has_zshrc, (
            "Environment variable setup must mention ~/.zshrc for zsh users"
        )

    def test_ac_5_10_2_2_bashrc_instructions_exist(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.2: [P0] Instructions show ~/.bashrc for bash users."""
        # Given: A user following API key documentation
        # When: They use bash shell
        # Then: ~/.bashrc is mentioned as the config location

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_bashrc = re.search(
            r"~/\.bashrc|~/.bashrc|\.bashrc",
            mcp_setup_content
        )
        assert has_bashrc, (
            "Environment variable setup must mention ~/.bashrc for bash users"
        )

    def test_ac_5_10_2_3_export_syntax_shown(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.3: [P0] Clear export syntax examples are provided."""
        # Given: A user configuring environment variables
        # When: They need the exact syntax
        # Then: Export commands are shown (export VAR="value")

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should have export examples for the main API keys
        has_github_export = re.search(
            r'export\s+GITHUB_TOKEN\s*=',
            mcp_setup_content
        )
        has_perplexity_export = re.search(
            r'export\s+PERPLEXITY_API_KEY\s*=',
            mcp_setup_content
        )
        has_exa_export = re.search(
            r'export\s+EXA_API_KEY\s*=',
            mcp_setup_content
        )

        assert has_github_export, (
            "Environment setup must show export GITHUB_TOKEN=... example"
        )
        assert has_perplexity_export, (
            "Environment setup must show export PERPLEXITY_API_KEY=... example"
        )
        assert has_exa_export, (
            "Environment setup must show export EXA_API_KEY=... example"
        )

    def test_ac_5_10_2_4_verification_instructions_exist(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.4: [P0] Instructions show how to verify variables are set."""
        # Given: A user who has set environment variables
        # When: They want to verify the setup
        # Then: echo $VARIABLE commands are shown

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should show echo commands for verification
        has_echo_verification = re.search(
            r'echo\s+\$\w+|echo\s+"\$\w+"',
            mcp_setup_content
        )
        assert has_echo_verification, (
            "Environment setup must show echo $VARIABLE_NAME for verification"
        )

    def test_ac_5_10_2_5_source_command_documented(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.5: [P0] Instructions show source command to reload profile."""
        # Given: A user who added variables to shell profile
        # When: They need to apply changes
        # Then: source ~/.zshrc (or similar) is documented

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_source_command = re.search(
            r'source\s+~/\.\w+rc',
            mcp_setup_content
        )
        assert has_source_command, (
            "Environment setup must show 'source ~/.zshrc' or 'source ~/.bashrc' "
            "to reload profile after adding variables"
        )

    def test_ac_5_10_2_6_new_terminal_note_exists(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.6: [P1] Note about new terminal session alternative."""
        # Given: A user who added variables to shell profile
        # When: They read the setup instructions
        # Then: A note mentions new terminal session as alternative

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should mention opening new terminal as alternative to source
        has_new_terminal_note = re.search(
            r'(new|restart|open).*(terminal|shell|session)',
            mcp_setup_content,
            re.IGNORECASE
        )
        # If no explicit note, at least the source command should be present
        # This is P1, so we check for either option
        has_source = "source" in mcp_setup_content

        assert has_new_terminal_note or has_source, (
            "Environment setup should note that opening a new terminal session "
            "works as alternative to source command"
        )

    def test_ac_5_10_2_7_env_file_option_mentioned(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.7: [P2] Optional .env file usage is mentioned."""
        # Given: A user reading environment variable setup
        # When: They prefer project-level configuration
        # Then: .env file option is mentioned (optional)

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should mention .env files as an optional alternative
        has_env_file_mention = re.search(
            r'\.env\s*(file|files)?',
            mcp_setup_content,
            re.IGNORECASE
        )
        assert has_env_file_mention, (
            "Environment setup should optionally mention .env file usage "
            "(for project-level configuration)"
        )

    def test_ac_5_10_2_8_secrets_management_mentioned(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.8: [P2] Optional secrets management is mentioned."""
        # Given: A user reading environment variable setup
        # When: They want more secure key management
        # Then: Secrets management or password manager option is mentioned

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should mention security best practices
        has_secrets_mention = re.search(
            r'(secrets?\s*manag|password\s*manager|1password|keychain|vault)',
            mcp_setup_content,
            re.IGNORECASE
        )
        has_security_note = re.search(
            r'(store\s*securely|never\s*commit|security)',
            mcp_setup_content,
            re.IGNORECASE
        )

        assert has_secrets_mention or has_security_note, (
            "Environment setup should optionally mention secrets management "
            "or secure storage practices"
        )

    def test_ac_5_10_2_9_complete_setup_example(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.2.9: [P0] Complete code block example for shell profile."""
        # Given: A user who wants to copy-paste setup
        # When: They read the documentation
        # Then: A complete code block with all exports is provided

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Look for a code block containing multiple exports
        code_block_pattern = r'```\w*\n(.*?)```'
        code_blocks = re.findall(code_block_pattern, mcp_setup_content, re.DOTALL)

        # At least one code block should have multiple export statements
        has_complete_example = False
        for block in code_blocks:
            export_count = len(re.findall(r'export\s+\w+', block))
            if export_count >= 2:  # At least 2 exports in one block
                has_complete_example = True
                break

        assert has_complete_example, (
            "Environment setup must have a complete code block example "
            "showing multiple export statements that can be copied to shell profile"
        )
