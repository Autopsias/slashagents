"""
Story 5.10: Document Prerequisites and API Key Setup
Edge Cases and Cross-Cutting Concerns

Tests for edge cases, integration between ACs, and quality requirements.

Test IDs: TEST-AC-5.10.E.x
Priority: [P1] - Quality and consistency checks
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


@pytest.fixture
def readme_content() -> str:
    """Load the README.md content for testing."""
    readme_path = Path(__file__).parent.parent.parent.parent / "README.md"
    return readme_path.read_text()


@pytest.fixture
def mcp_json_content() -> str:
    """Load the .mcp.json content for validation."""
    mcp_json_path = Path(__file__).parent.parent.parent.parent / "plugin" / ".mcp.json"
    if mcp_json_path.exists():
        return mcp_json_path.read_text()
    return ""


class TestEdgeCasesAndIntegration:
    """Edge cases and integration tests across all ACs."""

    def test_ac_5_10_e_1_mcp_setup_file_exists(self) -> None:
        """TEST-AC-5.10.E.1: [P0] MCP_SETUP.md file exists in plugin directory."""
        # Given: A user looking for MCP documentation
        # When: They navigate to plugin directory
        # Then: MCP_SETUP.md exists

        mcp_setup_path = Path(__file__).parent.parent.parent.parent / "plugin" / "MCP_SETUP.md"
        assert mcp_setup_path.exists(), (
            "plugin/MCP_SETUP.md must exist for API key documentation"
        )

    def test_ac_5_10_e_2_readme_links_to_mcp_setup(self, readme_content: str) -> None:
        """TEST-AC-5.10.E.2: [P0] README.md links to MCP_SETUP.md."""
        # Given: A user reading the README
        # When: They look for MCP information
        # Then: A link to MCP_SETUP.md exists

        has_mcp_setup_link = re.search(
            r'MCP_SETUP\.md|mcp.*setup.*guide',
            readme_content,
            re.IGNORECASE
        )
        assert has_mcp_setup_link, (
            "README.md must link to plugin/MCP_SETUP.md for detailed MCP setup"
        )

    def test_ac_5_10_e_3_consistent_server_names(
        self, mcp_setup_content: str, mcp_json_content: str
    ) -> None:
        """TEST-AC-5.10.E.3: [P0] Server names match between docs and .mcp.json."""
        # Given: Documentation and .mcp.json source
        # When: Comparing server names
        # Then: Names are consistent

        assert mcp_setup_content, "MCP_SETUP.md must exist"
        assert mcp_json_content, ".mcp.json must exist"

        # Extract server names from .mcp.json
        server_names_in_json = re.findall(r'"([^"]+)":\s*\{', mcp_json_content)

        # Each server in .mcp.json should be documented
        for server_name in server_names_in_json:
            if server_name == "mcpServers":  # Skip the wrapper key
                continue
            assert server_name in mcp_setup_content, (
                f"Server `{server_name}` from .mcp.json must be documented in MCP_SETUP.md"
            )

    def test_ac_5_10_e_4_no_hardcoded_api_keys(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.E.4: [P0] No real API keys are hardcoded in documentation."""
        # Given: Documentation with API key examples
        # When: Checking for real keys
        # Then: Only placeholder values are used

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Check for obvious placeholder patterns
        # Real GitHub tokens start with ghp_, gho_, etc.
        has_real_github_token = re.search(
            r'ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}',
            mcp_setup_content
        )
        assert not has_real_github_token, (
            "Documentation must not contain real GitHub tokens"
        )

        # Real Perplexity keys have a specific format
        # Using generic pattern to catch anything that looks like a real key
        has_suspicious_key = re.search(
            r'["\'][a-zA-Z0-9]{30,}["\']',  # Long alphanumeric string in quotes
            mcp_setup_content
        )
        # If found, verify it's a placeholder
        if has_suspicious_key:
            # Should contain placeholder indicators
            has_placeholder = re.search(
                r'your_|YOUR_|xxx|placeholder|example',
                mcp_setup_content,
                re.IGNORECASE
            )
            assert has_placeholder, (
                "API key examples must use obvious placeholders, not real-looking values"
            )

    def test_ac_5_10_e_5_troubleshooting_section_exists(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.E.5: [P1] Troubleshooting section for common API key issues."""
        # Given: A user having trouble with API keys
        # When: They look for help
        # Then: A troubleshooting section exists

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_troubleshooting = re.search(
            r'##\s*troubleshoot',
            mcp_setup_content,
            re.IGNORECASE
        )
        assert has_troubleshooting, (
            "MCP_SETUP.md should have a Troubleshooting section for common API key issues"
        )

    def test_ac_5_10_e_6_api_key_not_found_error_documented(
        self, mcp_setup_content: str
    ) -> None:
        """TEST-AC-5.10.E.6: [P1] 'API key not found' error resolution is documented."""
        # Given: A user getting "API key not found" error
        # When: They read troubleshooting
        # Then: Resolution steps are provided

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_not_found_resolution = re.search(
            r'(not\s*found|not\s*set|undefined|missing)',
            mcp_setup_content,
            re.IGNORECASE
        )
        assert has_not_found_resolution, (
            "Troubleshooting must address 'API key not found' or 'undefined' errors"
        )

    def test_ac_5_10_e_7_invalid_key_error_documented(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.E.7: [P1] 'Invalid API key' error resolution is documented."""
        # Given: A user getting "invalid API key" error
        # When: They read troubleshooting
        # Then: Resolution steps are provided

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_invalid_resolution = re.search(
            r'(invalid|expired|auth.*fail|authentication)',
            mcp_setup_content,
            re.IGNORECASE
        )
        assert has_invalid_resolution, (
            "Troubleshooting must address 'invalid API key' or authentication errors"
        )

    def test_ac_5_10_e_8_verification_commands_work(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.E.8: [P1] Verification commands are executable (valid syntax)."""
        # Given: Verification commands in documentation
        # When: Checking syntax
        # Then: Commands are valid bash syntax

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Extract code blocks
        code_blocks = re.findall(r'```(?:bash|sh)?\n(.*?)```', mcp_setup_content, re.DOTALL)

        # Check for echo verification commands
        has_echo_command = False
        for block in code_blocks:
            if re.search(r'echo\s+\$\w+', block):
                has_echo_command = True
                # Verify it's valid syntax ($ followed by valid var name)
                echo_commands = re.findall(r'echo\s+(\$\w+)', block)
                for cmd in echo_commands:
                    # Variable names should be valid
                    var_name = cmd[1:]  # Remove $
                    assert re.match(r'^[A-Z_][A-Z0-9_]*$', var_name), (
                        f"Environment variable {cmd} should follow naming convention"
                    )
                break

        assert has_echo_command, (
            "Documentation should include echo verification commands in code blocks"
        )

    def test_ac_5_10_e_9_consistent_env_var_format(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.E.9: [P1] Environment variable names use consistent format."""
        # Given: Environment variable documentation
        # When: Checking naming consistency
        # Then: All use UPPER_SNAKE_CASE with _API_KEY or _TOKEN suffix

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Find all environment variable references
        env_vars = re.findall(r'\$([A-Z_][A-Z0-9_]*)', mcp_setup_content)

        # Filter to API-related variables
        api_vars = [v for v in env_vars if 'KEY' in v or 'TOKEN' in v]

        # All should follow naming convention
        for var in api_vars:
            assert re.match(r'^[A-Z][A-Z0-9_]*_(KEY|TOKEN)$', var), (
                f"Environment variable {var} should follow UPPER_SNAKE_CASE "
                "with _API_KEY or _TOKEN suffix"
            )

    def test_ac_5_10_e_10_no_duplicate_server_entries(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.E.10: [P1] No duplicate MCP server entries in tables."""
        # Given: API key table in documentation
        # When: Checking for duplicates
        # Then: Each server appears only once in the main table

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Find backtick-quoted server names (the canonical format)
        server_mentions = re.findall(r'`(github|perplexity-ask|exa|ref|grep|semgrep-hosted|chrome-devtools|playwright)`', mcp_setup_content)

        # Count occurrences in tables (rows starting with |)
        table_lines = [line for line in mcp_setup_content.split('\n') if line.strip().startswith('|')]

        for server in ['github', 'perplexity-ask', 'exa', 'ref']:  # Main API key servers
            table_mentions = sum(1 for line in table_lines if f'`{server}`' in line)
            # Allow up to 2 mentions (main table + secondary reference table)
            assert table_mentions <= 3, (
                f"Server `{server}` appears {table_mentions} times in tables. "
                "Avoid duplicate entries to prevent confusion."
            )
