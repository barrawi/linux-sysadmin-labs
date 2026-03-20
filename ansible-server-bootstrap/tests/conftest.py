"""
conftest.py
Configures ssh config for testinfra so I don't have to pass the key each time
"""

import pytest


def pytest_configure(config):
    config.addinivalue_line(
        "markers", "testinfra: mark test as a testinfra test"
    )
