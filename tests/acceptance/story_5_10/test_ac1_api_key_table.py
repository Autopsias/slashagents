"""
Story 5.10: Document Prerequisites and API Key Setup
AC1: API key table with all MCP servers

Tests that verify the documentation contains a comprehensive API key table
listing all 8 MCP servers with server name, commands, env variable, and key source.

Test IDs: TEST-AC-5.10.1.x
Priority: [P0] - Core documentation requirement for MCP setup
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


# Expected MCP servers from plugin/.mcp.json (source of truth)
EXPECTED_MCP_SERVERS = [
    "github",
    "perplexity-ask",
    "exa",
    "ref",
    "grep",
    "semgrep-hosted",
    "chrome-devtools",
    "playwright",
]

# Expected environment variables for API key setup
EXPECTED_ENV_VARS = {
    "github": "GITHUB_TOKEN",
    "perplexity-ask": "PERPLEXITY_API_KEY",
    "exa": "EXA_API_KEY",
    "ref": "REF_API_KEY",
}


class TestAC1APIKeyTable:
    """
    AC1: API key table with all MCP servers

    Given the documentation (README or plugin/MCP_SETUP.md)
    When a user reads the API key setup section
    Then they see a table listing all MCP servers with:
      - Server name (matching .mcp.json)
      - Commands that use it
      - Environment variable name
      - Where to get the key (URL or instructions)
    """

    def test_ac_5_10_1_1_api_key_section_exists(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.1: [P0] MCP_SETUP.md has a dedicated API key section."""
        # Given: A user reading MCP_SETUP.md
        # When: They look for API key setup information
        # Then: A dedicated section for API keys exists

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Look for API key section header
        has_api_key_section = re.search(
            r"##\s*(API\s*Key|Environment\s*Variable)\s*(Setup|Table|Reference|Configuration)",
            mcp_setup_content,
            re.IGNORECASE
        )
        assert has_api_key_section, (
            "MCP_SETUP.md must have a dedicated 'API Key Setup' or "
            "'Environment Variable Configuration' section"
        )

    def test_ac_5_10_1_2_table_lists_all_eight_mcp_servers(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.2: [P0] API key table lists all 8 MCP servers from .mcp.json."""
        # Given: A user reading the API key table
        # When: They check which MCP servers are documented
        # Then: All 8 servers from .mcp.json are listed

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # All 8 MCP servers must be mentioned in the API key section
        missing_servers = []
        for server in EXPECTED_MCP_SERVERS:
            # Server names should appear as backtick-quoted (per architecture convention)
            pattern = rf"`{re.escape(server)}`"
            if not re.search(pattern, mcp_setup_content):
                missing_servers.append(server)

        assert not missing_servers, (
            f"API key table must list all 8 MCP servers. "
            f"Missing: {missing_servers}. "
            f"Server names should be backtick-quoted (e.g., `github`)"
        )

    def test_ac_5_10_1_3_table_has_server_name_column(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.3: [P0] API key table has Server/MCP Server name column."""
        # Given: A user reading the API key table
        # When: They look for server names
        # Then: A Server name column exists matching .mcp.json names

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Find tables in the document
        table_headers = re.findall(r"\|([^|]+(?:\|[^|]+)+)\|", mcp_setup_content)

        # Check for Server/MCP Server column header
        has_server_column = any(
            re.search(r"(mcp\s*)?server(\s*name)?", header, re.IGNORECASE)
            for header in table_headers
        )
        assert has_server_column, (
            "API key table must have a 'Server' or 'MCP Server' column header"
        )

    def test_ac_5_10_1_4_table_has_commands_column(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.4: [P0] API key table shows which commands use each server."""
        # Given: A user reading the API key table
        # When: They want to know which commands need each server
        # Then: A column shows commands that use each MCP server

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Find tables in the document
        table_headers = re.findall(r"\|([^|]+(?:\|[^|]+)+)\|", mcp_setup_content)

        # Check for Commands/Tools/Used By column header
        has_commands_column = any(
            re.search(r"commands?|tools?|used\s*by|requires?", header, re.IGNORECASE)
            for header in table_headers
        )
        assert has_commands_column, (
            "API key table must have a 'Commands' or 'Used By' column header"
        )

    def test_ac_5_10_1_5_table_has_env_variable_column(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.5: [P0] API key table shows environment variable for each server."""
        # Given: A user reading the API key table
        # When: They need to know which env variable to set
        # Then: Environment variable name is shown for each server

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Find tables in the document
        table_headers = re.findall(r"\|([^|]+(?:\|[^|]+)+)\|", mcp_setup_content)

        # Check for Environment Variable column header
        has_env_var_column = any(
            re.search(r"env(ironment)?\s*var(iable)?|variable", header, re.IGNORECASE)
            for header in table_headers
        )
        assert has_env_var_column, (
            "API key table must have an 'Environment Variable' column header"
        )

    def test_ac_5_10_1_6_table_has_get_key_column(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.6: [P0] API key table shows where to obtain each key."""
        # Given: A user reading the API key table
        # When: They need to know where to get an API key
        # Then: URLs or instructions are provided for obtaining keys

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Find tables in the document
        table_headers = re.findall(r"\|([^|]+(?:\|[^|]+)+)\|", mcp_setup_content)

        # Check for Where to Get/Source/URL column header
        has_get_key_column = any(
            re.search(r"where|get\s*key|source|url|obtain|link", header, re.IGNORECASE)
            for header in table_headers
        )
        assert has_get_key_column, (
            "API key table must have a 'Where to Get' or 'Source' column header "
            "showing where to obtain each API key"
        )

    def test_ac_5_10_1_7_github_token_documented(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.7: [P0] GITHUB_TOKEN is documented with source URL."""
        # Given: A user reading the API key table
        # When: They look for GitHub token setup
        # Then: GITHUB_TOKEN env var and github.com/settings/tokens are shown

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_github_token = "GITHUB_TOKEN" in mcp_setup_content
        has_github_url = re.search(
            r"github\.com/settings/tokens",
            mcp_setup_content,
            re.IGNORECASE
        )

        assert has_github_token and has_github_url, (
            "API key documentation must show GITHUB_TOKEN variable "
            "with github.com/settings/tokens source URL"
        )

    def test_ac_5_10_1_8_perplexity_key_documented(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.8: [P0] PERPLEXITY_API_KEY is documented with source URL."""
        # Given: A user reading the API key table
        # When: They look for Perplexity API key setup
        # Then: PERPLEXITY_API_KEY env var and perplexity.ai source are shown

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_perplexity_key = "PERPLEXITY_API_KEY" in mcp_setup_content
        has_perplexity_url = re.search(
            r"perplexity\.ai",
            mcp_setup_content,
            re.IGNORECASE
        )

        assert has_perplexity_key and has_perplexity_url, (
            "API key documentation must show PERPLEXITY_API_KEY variable "
            "with perplexity.ai source URL"
        )

    def test_ac_5_10_1_9_exa_key_documented(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.9: [P0] EXA_API_KEY is documented with source URL."""
        # Given: A user reading the API key table
        # When: They look for Exa API key setup
        # Then: EXA_API_KEY env var and exa.ai source are shown

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_exa_key = "EXA_API_KEY" in mcp_setup_content
        has_exa_url = re.search(
            r"(exa\.ai|dashboard\.exa\.ai)",
            mcp_setup_content,
            re.IGNORECASE
        )

        assert has_exa_key and has_exa_url, (
            "API key documentation must show EXA_API_KEY variable "
            "with exa.ai or dashboard.exa.ai source URL"
        )

    def test_ac_5_10_1_10_ref_key_documented(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.1.10: [P1] REF_API_KEY is documented with source URL."""
        # Given: A user reading the API key table
        # When: They look for Ref API key setup
        # Then: REF_API_KEY env var and source info are shown

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_ref_key = "REF_API_KEY" in mcp_setup_content
        has_ref_source = re.search(
            r"ref\.(tools|ai)|ref api",
            mcp_setup_content,
            re.IGNORECASE
        )

        assert has_ref_key and has_ref_source, (
            "API key documentation must show REF_API_KEY variable "
            "with ref.tools or similar source information"
        )
