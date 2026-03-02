# RHEL Enterprise Stream Server Bootstrap (Zero Trust Architecture)

An automated Ansible project to transform a fresh RHEL installation into a secured, 
production ready workstation within a Zero Trust Network.

## Purpose
Manually configuring users, SSH keys, and system updates is error prone. 
This project automates the "Day 0" setup to ensure:
* **Security**: Password logins are disabled, strict SSH key permissions are enforced, and servers are isolated behind a VPN overlay.
* **Consistency**: Essential packages and metadata configurations are idempotent and deployed identically across Dev and Prod environments.
* **Efficiency**: Passwordless Sudo is configured for streamlined CI/CD and automation pipelines.

## Infrastructure Architecture
* **Management**: Arch Linux (Controller) -> RHEL (Nodes)
* **Networking**: Zero Trust VPN Overlay via Tailscale (WireGuard)
* **Security**: Zone-based Firewalld segmentation
* **Web**: Nginx serving dynamic host metadata via Jinja2.

## Project Structure
* `roles/common`: Updates dnf packages and installs core utilities.
* `roles/users`: Creates a `devops` user, manages SSH authorized keys with strict `0600` permissions, and safely configures sudoers.
* `roles/ssh_hardening`: Secures the OpenSSH daemon using a Jinja2 template to enforce key based authentication, disable root login, and prevent brute force attacks via password disablement.
* `roles/firewall`: Manages the system perimeter by ensuring the firewalld service is active and properly configured to allow only authorized traffic, dropping public HTTP traffic and binding the `tailscale0` interface to the trusted zone.
* `roles/tailscale`: Installs and authenticates the Tailscale daemon to join the secure private mesh network.
* `roles/nginx`: Deploys a web server instance using a dynamic Jinja2 template. It captures and displays system-level metadata (hostname, environment, and deployment timestamp) using Ansible Facts.

## Setup
* **Secrets**: Create an encrypted vault file to store your sudo password and Tailscale keys.
   ```bash
   ansible-vault create group_vars/all.yml

## How to Run
1. **Clone the Repo**: `git clone https://github.com/youruser/linux-sysadmin-labs.git`
2. **Setup Inventory**: Update inventories/dev/hosts.ini or inventories/prod/hosts.ini with your VM IP addresses.
3. **Vault Setup**: Ensure your `all.yml` contains your `ansible_become_pass` and `tailscale_key`.
4. **Execute the Playbook**(Example for Dev):
   ```bash
   ansible-playbook -i inventories/dev/hosts.ini site.yml --ask-vault-pass

**Important**: `bootstrap.yml` and `site.yml`

* `bootstrap.yml`: The "Day 0" Script:
Use this only once per new virtual machine instance.
**When to use**: Immediately after the RHEL OS is installed and you have basic SSH access.
**Purpose**: To install the "missing links" required for Ansible and modern networking to function correctly. 
**Key Tasks**: 
    * Installing Avahi and nss-mdns so you can reach the server via dev-vm01.local instead of tracking changing IP addresses. 
    * Opening the mDNS port in the firewall to allow local hostname resolution.

* `site.yml`: The "Day 1+" Script
Use this for everything else and for all ongoing updates.
**When to use**: 
    1. Right after the bootstrap is finished to apply the full security stack. 
    2. Whenever you change a configuration (e.g., adding a new user, updating Nginx templates, or rotating SSH keys). 
**Purpose**: This is your "Single Source of Truth." It enforces your desired state across all roles. 
**Key Roles Included**:
    * Users & SSH Hardening: Locking down the server. 
    * Firewall & Tailscale: Setting up the Zero-Trust network. 
    * Nginx: Deploying the actual application or web content.

## Technical Challenges & Solutions

### The "Perfect Storm" SSH Lockout: 
**Challenge**: During the SSH hardening phase, applying `PasswordAuthentication` no resulted in a total lockout. The `authorized_keys` file was being ignored by the OpenSSH daemon.

**Solution**: Conducted a root cause analysis via the hypervisor console. Identified a strict ownership/permissions conflict where the key file was created with `0644` permissions. Refactored the `users` role to explicitly enforce `0700` on the `.ssh` directory and utilize `manage_dir: yes` to satisfy SSH's strict security requirements.

### Secure Secret management
**Challenge**: Needed to provide a sudo password and API keys without hardcoding them in plain text.

**Solution**: Implemented Ansible Vault to encrypt sensitive variables. Used environment_specific `group_vars` to store encrypted credentials, ensuring the repository remains safe for public version control.

### Zero-Trust Network segmentation
**Challenge**: Standard firewall rules were blocking legitimate internal traffic while leaving public ports unnecessarily exposed.

**Solution**: Migrated from standard port blocking to a Zone Based Firewall architecture. Bound the `tailscale0` interface to the trusted zone, allowing internal Nginx routing entirely through the encrypted WireGuard mesh while keeping the node completely dark on the public LAN.

# Feedback and Contributions
This project was developed as part of my **SysAdmin / DevOps Portfolio** to demonstrate technical proficiency in Linux automation, Zero Trust networking and configuration management. 
I am always looking to improve my workflows and code efficiency. If you have any feedback or suggestions, they are 100% appreciated! Feel free to reach out, constructive conversations and professional networking are always welcome.

# AI-Assisted Development & Quality Assurance
While this project was architected and driven by me, I utilized AI as a collaborative tool for code revisioning, best practice auditing, and logic verification.
- Every AI-generated suggestion was manually reviewed, tested in a sandbox environment, and investigated for its implications before integration.
- AI helped identify and resolve complex YAML parsing issues and Ansible Vault formatting errors (e.g., dict vs. string mismatches).
- The collaborative process was used to refine the "Controller to Node" logic, specifically the secure lookup of local public keys to ensure zero hardcoded secrets in version control.

# Author
Wilberth Barrantes - SysAdmin / DevOps Portfolio Project
