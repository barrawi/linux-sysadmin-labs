# User Provisioning Module

This module contains automation scripts for Linux user lifecycle management.

## Features

- Single and bulk user creation
- Group assignment
- Sudo privilege configuration
- Account expiration management
- Audit logging
- Root privilege enforcement

## Environment

Tested on:
- CentOS
- RHEL-based systems

## Example Usage

```bash
sudo ./user_creation.sh -u john -g dev --sudo
sudo ./user_creation.sh -f users.txt
