"""
Real-world integration tests demonstrating weather-mcp capabilities.

These tests show how the MCP functions work for actual use cases.
"""

import pytest

from weather_mcp.main import get_weather

@pytest.mark.integration
def test_weather():
    """Complete workflow: Weather analysis from multiple data sources."""
    print("\n🌾 WEATHER NORMALS")

    # Test coordinates for Iowa farmland (known agricultural area)
    iowa_farmland_lat, iowa_farmland_lon = 42.0308, -93.6319

    # Step 1: Get available stations with hourly or daily coverage on a specific date.
