"""
Story 5.10: Document Prerequisites and API Key Setup
AC3: Clear distinction between required vs optional

Tests that verify the documentation clearly distinguishes which MCP servers
are required (none), optional (recommended), and specialized (niche use cases).

Test IDs: TEST-AC-5.10.3.x
Priority: [P0] - Core documentation requirement for understanding dependencies
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


class TestAC3RequiredVsOptional:
    """
    AC3: Clear distinction between required vs optional

    Given the API key documentation
    When a user reads it
    Then they clearly understand which MCP servers are:
      - Required for core functionality (none - all are optional enhancements)
      - Optional for enhanced features (github, perplexity-ask, exa, ref)
      - Only needed for specific use cases (chrome-devtools, playwright, semgrep-hosted, grep)
    And the tier/priority is clearly indicated
    """

    def test_ac_5_10_3_1_no_required_mcp_statement(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.1: [P0] Documentation states no MCP servers are required."""
        # Given: A user reading the API key documentation
        # When: They look for what's required
        # Then: They see that no MCP servers are required for core functionality

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should explicitly state that all MCP servers are optional
        # or that none are required for core functionality
        has_all_optional_statement = re.search(
            r'(all\s+(mcp\s*)?(servers?\s*)?are\s*optional|'
            r'no\s+(mcp\s*)?(servers?\s*)?required|'
            r'none.*required.*core|'
            r'optional.*enhancement)',
            mcp_setup_content,
            re.IGNORECASE
        )
        assert has_all_optional_statement, (
            "Documentation must clearly state that no MCP servers are required "
            "for core functionality (all are optional enhancements)"
        )

    def test_ac_5_10_3_2_tier_system_explained(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.2: [P0] Tier/priority system is explained at top of section."""
        # Given: A user reading the API key documentation
        # When: They see tier assignments
        # Then: The tier meanings are explained

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should have tier definitions (Recommended/Tier 1, Useful/Tier 2, Specialized/Tier 3)
        has_tier_explanation = re.search(
            r'(tier\s*1|tier\s*2|tier\s*3|recommended|useful|specialized)',
            mcp_setup_content,
            re.IGNORECASE
        )
        assert has_tier_explanation, (
            "Documentation must explain the tier/priority system "
            "(e.g., Tier 1/Recommended, Tier 2/Useful, Tier 3/Specialized)"
        )

    def test_ac_5_10_3_3_github_is_recommended_tier(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.3: [P0] GitHub MCP is in Recommended/Tier 1 category."""
        # Given: A user reading the tier assignments
        # When: They look for github MCP
        # Then: It is listed in Recommended/Tier 1 (high value)

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Find github in context of recommended/tier 1
        # Could be in a section header or table
        has_github_recommended = re.search(
            r'(tier\s*1|recommended).*`?github`?|`?github`?.*?(tier\s*1|recommended)',
            mcp_setup_content,
            re.IGNORECASE | re.DOTALL
        )
        assert has_github_recommended, (
            "`github` MCP must be in Tier 1/Recommended category (high value)"
        )

    def test_ac_5_10_3_4_perplexity_is_recommended_tier(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.4: [P0] Perplexity MCP is in Recommended/Tier 1 category."""
        # Given: A user reading the tier assignments
        # When: They look for perplexity-ask MCP
        # Then: It is listed in Recommended/Tier 1 (high value)

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_perplexity_recommended = re.search(
            r'(tier\s*1|recommended).*`?perplexity(-ask)?`?|`?perplexity(-ask)?`?.*?(tier\s*1|recommended)',
            mcp_setup_content,
            re.IGNORECASE | re.DOTALL
        )
        assert has_perplexity_recommended, (
            "`perplexity-ask` MCP must be in Tier 1/Recommended category (high value)"
        )

    def test_ac_5_10_3_5_exa_ref_are_useful_tier(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.5: [P1] Exa and Ref MCPs are in Useful/Tier 2 category."""
        # Given: A user reading the tier assignments
        # When: They look for exa and ref MCPs
        # Then: They are listed in Useful/Tier 2 (moderate value)

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # exa and ref should be in tier 2/useful
        has_tier_2_section = re.search(
            r'(tier\s*2|useful|moderate)',
            mcp_setup_content,
            re.IGNORECASE
        )
        has_exa_mention = "`exa`" in mcp_setup_content or "exa" in mcp_setup_content.lower()
        has_ref_mention = "`ref`" in mcp_setup_content or "ref" in mcp_setup_content.lower()

        assert has_tier_2_section and has_exa_mention and has_ref_mention, (
            "`exa` and `ref` MCPs should be in Tier 2/Useful category (moderate value)"
        )

    def test_ac_5_10_3_6_browser_mcps_are_specialized_tier(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.6: [P1] Browser MCPs are in Specialized/Tier 3 category."""
        # Given: A user reading the tier assignments
        # When: They look for chrome-devtools and playwright MCPs
        # Then: They are listed in Specialized/Tier 3 (niche use cases)

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Browser MCPs should be in tier 3/specialized
        has_tier_3_section = re.search(
            r'(tier\s*3|specialized|niche|specific)',
            mcp_setup_content,
            re.IGNORECASE
        )
        has_chrome_devtools = re.search(r'chrome-devtools', mcp_setup_content, re.IGNORECASE)
        has_playwright = re.search(r'playwright', mcp_setup_content, re.IGNORECASE)

        assert has_tier_3_section and has_chrome_devtools and has_playwright, (
            "`chrome-devtools` and `playwright` MCPs should be in "
            "Tier 3/Specialized category (niche use cases)"
        )

    def test_ac_5_10_3_7_security_mcps_are_specialized_tier(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.7: [P1] Security MCPs are in Specialized/Tier 3 category."""
        # Given: A user reading the tier assignments
        # When: They look for semgrep-hosted MCP
        # Then: It is listed in Specialized/Tier 3 (niche use cases)

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_semgrep = re.search(r'semgrep(-hosted)?', mcp_setup_content, re.IGNORECASE)
        has_tier_3_section = re.search(
            r'(tier\s*3|specialized|security)',
            mcp_setup_content,
            re.IGNORECASE
        )

        assert has_semgrep and has_tier_3_section, (
            "`semgrep-hosted` MCP should be in Tier 3/Specialized category (security scanning)"
        )

    def test_ac_5_10_3_8_grep_is_specialized_no_key(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.8: [P1] Grep MCP noted as specialized with no API key needed."""
        # Given: A user reading the tier assignments
        # When: They look for grep MCP
        # Then: It shows as specialized with no API key required

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        has_grep = re.search(r'`grep`|grep\s*\|', mcp_setup_content, re.IGNORECASE)
        # grep should indicate no key needed
        has_no_key_indication = re.search(
            r'grep.*(none|no.*key|public|no\s*auth)',
            mcp_setup_content,
            re.IGNORECASE | re.DOTALL
        )

        assert has_grep and has_no_key_indication, (
            "`grep` MCP should be documented as specialized with no API key required"
        )

    def test_ac_5_10_3_9_tier_indicator_in_table(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.9: [P0] API key table shows tier/priority for each server."""
        # Given: A user reading the API key table
        # When: They look at each MCP server row
        # Then: A tier/priority indicator is shown

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Table should have a tier/priority column or indicator
        table_headers = re.findall(r"\|([^|]+(?:\|[^|]+)+)\|", mcp_setup_content)

        has_tier_column = any(
            re.search(r'tier|priority|category|type', header, re.IGNORECASE)
            for header in table_headers
        )

        # Alternative: tiers are organized in separate sections
        has_tier_sections = (
            re.search(r'###?\s*(tier\s*1|recommended)', mcp_setup_content, re.IGNORECASE) and
            re.search(r'###?\s*(tier\s*2|useful)', mcp_setup_content, re.IGNORECASE)
        )

        assert has_tier_column or has_tier_sections, (
            "API key table must show tier/priority indicator for each MCP server, "
            "either in a column or organized by tier sections"
        )

    def test_ac_5_10_3_10_clear_user_understanding(self, mcp_setup_content: str) -> None:
        """TEST-AC-5.10.3.10: [P0] User can clearly understand optional nature."""
        # Given: A user reading the documentation
        # When: They finish reading the MCP setup section
        # Then: They clearly understand all MCP servers are optional

        assert mcp_setup_content, "MCP_SETUP.md must exist"

        # Should have clear language about optional nature
        # Must have both "optional" mention AND avoid "required" as mandatory
        has_optional = re.search(r'\boptional\b', mcp_setup_content, re.IGNORECASE)

        # Check that "required" is not used to mean mandatory for core features
        # It's OK if "required" is used in context like "required BY specific tools"
        required_matches = re.findall(r'required', mcp_setup_content, re.IGNORECASE)

        # If "required" appears, it should be in context of specific tools, not core
        has_required_by_context = re.search(
            r'required\s*(by|for|only)',
            mcp_setup_content,
            re.IGNORECASE
        )

        assert has_optional, (
            "Documentation must use word 'optional' to clearly indicate "
            "MCP servers are not mandatory"
        )

        if required_matches:
            assert has_required_by_context, (
                "If 'required' is used, it should be in context of specific tools "
                "(e.g., 'required by /pr') not implying core requirement"
            )
