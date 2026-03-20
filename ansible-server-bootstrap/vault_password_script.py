#!/usr/bin/env python3
"""
vault_password_script.py
This script will help me to work the ansible vault password from a env var stored only on my shell session
Wilberth Barrantes
"""

import os

password = os.environ.get("ANSIBLE_VAULT_PASS")

if not password:
    raise SystemExit("Error: ANSIBLE_VAULT_PASS environment variable not set")
print(password)
