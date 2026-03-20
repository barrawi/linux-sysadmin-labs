# RHEL Enterprise Stream Server Bootstrap (Zero Trust Architecture)

[![CI Pipeline](https://github.com/barrawi/devops-automation-toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/barrawi/devops-automation-toolkit/actions/workflows/ci.yml)

An automated Ansible project to transform a fresh RHEL installation into a secured,
production ready workstation within a Zero Trust Network — and serve as the continuous
deployment backbone for the containerized webapp.

## Purpose
Manually configuring users, SSH keys, and system updates is error prone.
This project automates the "Day 0" setup to ensure:
- **Security**: Password logins are disabled, strict SSH key permissions are enforced, and servers are isolated behind a VPN overlay.
- **Consistency**: Essential packages and metadata configurations are idempotent and deployed identically across Dev and Prod environments.
- **Efficiency**: Passwordless sudo is configured for streamlined CI/CD and automation pipelines.
- **Continuous Deployment**: Every push to `main` automatically deploys the latest container image to all 3 prod VMs via GitHub Actions over Tailscale.

## Infrastructure Architecture
- **Management**: Arch Linux (Controller) -> RHEL (Nodes)
- **Networking**: Zero Trust VPN Overlay via Tailscale (WireGuard)
- **Security**: Zone based Firewalld segmentation
- **Web**: Nginx serving dynamic host metadata via Jinja2
- **Containers**: Podman + podman-compose running Flask + Redis stack
- **CI/CD**: GitHub Actions -> Tailscale -> Dynamic Inventory -> 3 node prod cluster

## Project Structure
```
ansible-server-bootstrap/
├── site.yml                        # Day 1+ playbook — full stack provisioning
├── bootstrap.yml                   # Day 0 playbook — fresh VM preparation
├── deploy_container.yml            # CD playbook — pulls and restarts containers
├── ansible.cfg
├── requirements.yml
├── tests/
│   ├── test_bootstrap.py 
│   └── conftest.py
├── group_vars/
│   └── all.yml                     # Global variables (vault encrypted)
├── inventories/
│   ├── tailscale_inventory.py      # Dynamic inventory via Tailscale API
│   ├── dev/
│   │   ├── hosts.ini               # Dev VM — .local mDNS hostnames
│   │   └── group_vars/all.yml
│   └── prod/
│       ├── hosts.ini               # Prod VMs — .local hostnames (manual runs)
│       └── group_vars/all.yml
└── roles/
    ├── common/                     # System updates and core packages
    ├── users/                      # Admin user creation and SSH key management
    ├── ssh_hardening/              # OpenSSH daemon hardening via Jinja2 template
    ├── firewall/                   # Zone-based firewalld configuration
    ├── tailscale/                  # Tailscale VPN install and authentication
    ├── nginx/                      # Nginx deployment with dynamic Jinja2 template
    ├── podman/                     # Podman install, app directory, compose stack
    └── deploy_key/                 # GitHub Actions SSH key generation and distribution
```
## Roles

- `roles/common`: Updates dnf packages and installs core utilities.
- `roles/users`: Creates the admin user, manages SSH authorized keys with strict `0600` permissions, and safely configures sudoers.
- `roles/ssh_hardening`: Secures the OpenSSH daemon using a Jinja2 template to enforce key based authentication, disable root login, and prevent brute force attacks via password disablement.
- `roles/firewall`: Manages the system perimeter by ensuring the firewalld service is active and properly configured to allow only authorized traffic, dropping public HTTP traffic and binding the `tailscale0` interface to the trusted zone.
- `roles/tailscale`: Installs and authenticates the Tailscale daemon to join the secure private mesh network.
- `roles/nginx`: Deploys a web server instance using a dynamic Jinja2 template. Captures and displays system level metadata (hostname, environment, deployment timestamp) using Ansible Facts.
- `roles/podman`: Installs Podman and podman compose, creates the app directory, and deploys the docker compose stack and `.env` file via Jinja2 templates.
- `roles/deploy_key`: Generates an ed25519 SSH key pair locally (`delegate_to: localhost`), distributes the public key to all prod VMs, and stores the private key for GitHub Actions use — fully automated, zero manual key management.

## Playbooks

**`bootstrap.yml` — Day 0**

Use this once on a single freshly installed RHEL VM before cloning it.

Purpose: Installs the prerequisites for Ansible and mDNS to function correctly. Once bootstrapped, the VM is cloned and each clone gets its hostname updated — this is the only setup step needed per machine.

Why mDNS: VMs on the local network receive dynamic IPs via DHCP. Rather than tracking changing IPs, Avahi enables hostname resolution via `hostname.local` so Ansible can always reach each node regardless of its current IP.

Key tasks:
- Installs Avahi and nss-mdns so you can reach the server via `hostname.local` instead of tracking IPs.
- Opens the mDNS port in the firewall for local hostname resolution.

**Workflow for adding new prod VMs:**
1. Install RHEL on one machine
2. Run `bootstrap.yml` on it
3. Clone the VM as many times as needed
4. Update the hostname on each clone
5. Run `site.yml` across all nodes

**`site.yml` — Day 1+**

Use this for everything else and for all ongoing updates.

Purpose: Enforces your desired state across all roles. This is your Single Source of Truth.

Roles included: Users, SSH Hardening, Firewall, Tailscale, Nginx, Podman, Deploy Key.

**`deploy_container.yml` — Continuous Deployment**

Used exclusively by the GitHub Actions CI/CD pipeline.

Purpose: Pulls the latest image from Docker Hub and restarts the container stack on all prod VMs.

Key tasks:
- Pulls `dockerhub_username/containerized-webapp:latest` via `containers.podman.podman_image`.
- Gets the admin user's UID dynamically to set `XDG_RUNTIME_DIR` correctly.
- Runs `podman-compose up -d --force-recreate` as the admin user.

## Dynamic Inventory

`inventories/tailscale_inventory.py` queries the Tailscale API at runtime to discover prod VMs tagged with `tag:prod`. No static IP management — IP changes are handled automatically.

```bash
# test the inventory locally
export TAILSCALE_API_KEY=your_key
python3 inventories/tailscale_inventory.py --list
```

Used by the CI/CD pipeline. For manual local runs, `prod/hosts.ini` uses `.local` mDNS hostnames.

```bash
ansible-vault create group_vars/all.yml
```

Required vault variables:
```yaml
ansible_become_pass: "your_sudo_password"
tailscale_authkey: "tskey-auth-..."
```

## Setup

**Secrets**: Create an encrypted vault file to store your sudo password and Tailscale keys.

```bash
ansible-vault create group_vars/all.yml
```

Required vault variables:
```yaml
ansible_become_pass: "your_sudo_password"
tailscale_authkey: "tskey-auth-..."
```

## How to Run

**1. Clone the repo:**
```bash
git clone https://github.com/barrawi/devops-automation-toolkit.git
```

**2. Fresh VM — run bootstrap first (once per machine):**
```bash
ansible-playbook -i inventories/prod/hosts.ini bootstrap.yml --ask-vault-pass
```

**3. Full stack provisioning:**
```bash
ansible-playbook -i inventories/prod/hosts.ini site.yml --ask-vault-pass
```

**4. Deploy containers manually:**
```bash
export TAILSCALE_API_KEY=your_key
ansible-playbook -i inventories/tailscale_inventory.py deploy_container.yml --ask-vault-pass
```

**5. Run a specific role only:**
```bash
ansible-playbook -i inventories/prod/hosts.ini site.yml --ask-vault-pass --tags tag
```

## CI/CD Pipeline Integration

The GitHub Actions pipeline in `.github/workflows/ci.yml` (repo root) handles the full CI/CD loop:

```
push to main
    ↓
pytest tests pass
    ↓
Docker image built and pushed to Docker Hub
    ↓
Kind cluster spins up    
    ↓
Kubernetes manifests applied and validated
    ↓
Tailscale GitHub Action connects the runner to the mesh
    ↓
tailscale_inventory.py discovers prod VMs dynamically
    ↓
deploy_container.yml pulls latest image and restarts stack on all 3 VMs
```

GitHub Secrets required: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `TAILSCALE_AUTHKEY`, `TAILSCALE_API_KEY`, `VM_SSH_KEY`, `ANSIBLE_VAULT_PASS`.

## Post-Deployment Validation (Testinfra)

After Ansible runs, Testinfra verifies the configuration was applied correctly across all nodes — turning assumptions into assertions.

**Run tests:**
```bash
export ANSIBLE_VAULT_PASS=your-vault-password
pytest tests/
```

**What gets tested on every node:**
- devops user exists and belongs to the wheel group
- SSH root login is disabled
- SSH password authentication is disabled
- sshd is running and enabled
- firewalld is running and enabled
- Nginx is running and enabled
- Tailscale daemon is running and enabled
- Podman is installed

The vault password is never stored on disk — it's read from the `ANSIBLE_VAULT_PASS` environment variable at runtime via `vault_password_script.py`.

## Technical Challenges & Solutions

### The "Perfect Storm" SSH Lockout: 
**Challenge**: During the SSH hardening phase, applying `PasswordAuthentication` no resulted in a total lockout. The `authorized_keys` file was being ignored by the OpenSSH daemon.

**Solution**: Conducted a root cause analysis via the hypervisor console. Identified a strict ownership/permissions conflict where the key file was created with `0644` permissions. Refactored the `users` role to explicitly enforce `0700` on the `.ssh` directory and utilize `manage_dir: yes` to satisfy SSH's strict security requirements.

### Secure Secret Management 
**Challenge**: Needed to provide a sudo password and API keys without hardcoding them in plain text.

**Solution**: Implemented Ansible Vault to encrypt sensitive variables. Used environment_specific `group_vars` to store encrypted credentials, ensuring the repository remains safe for public version control.

### Zero-Trust Network segmentation
**Challenge**: Standard firewall rules were blocking legitimate internal traffic while leaving public ports unnecessarily exposed.

**Solution**: Migrated from standard port blocking to a Zone Based Firewall architecture. Bound the `tailscale0` interface to the trusted zone, allowing internal Nginx routing entirely through the encrypted WireGuard mesh while keeping the node completely dark on the public LAN.

### Dynamic Inventory Over Static IPs
**Challenge**: Static `hosts.ini` files with hardcoded IPs break on VM rebuilds and don't scale. Managing IPs across 3 prod VMs for CI/CD required a more resilient approach.

**Solution**: Built a dependency free Python script that queries the Tailscale API at runtime using only the standard library. VMs are discovered by `tag:prod` — add a VM to Tailscale with the tag and it's automatically included in every deployment. No IP management required.

### Bootstrap vs Steady-State Separation
**Challenge**: CI/CD pipeline needs Tailscale to reach VMs, but Tailscale is installed by the bootstrap. Fresh VMs are inaccessible via Tailscale before provisioning.

**Solution**: Separated provisioning into two phases with distinct inventories. `bootstrap.yml` with `prod/hosts.ini` (mDNS) handles initial setup. After Tailscale is running, all subsequent operations — including CI/CD — use `tailscale_inventory.py` exclusively.

# Feedback and Contributions
This project was developed as part of my **SysAdmin / DevOps Portfolio** to demonstrate technical proficiency in Linux automation, Zero Trust networking and configuration management. 
I am always looking to improve my workflows and code efficiency. If you have any feedback or suggestions, they are 100% appreciated! Feel free to reach out, constructive conversations and professional networking are always welcome.

# AI-Assisted Development & Quality Assurance
While this project was architected and driven by me, I utilized AI as a collaborative tool for code revisioning, best practice auditing, and logic verification.
- Every AI-generated suggestion was manually reviewed, tested in a sandbox environment, and investigated for its implications before integration.
- AI helped identify and resolve complex YAML parsing issues and Ansible Vault formatting errors.
- The collaborative process was used to refine the dynamic inventory script, deploy key automation, and CI/CD pipeline integration.

# Author
Wilberth Barrantes - SysAdmin / DevOps Too# Linux SysAdmin & DevOps Portfolio Toolkit
