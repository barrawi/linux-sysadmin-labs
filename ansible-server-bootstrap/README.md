# CentOS 9 Stream Server Bootstrap

An automated Ansible project to transform a fresh CentOS installation into a secured, 
production-ready workstation.

## Purpose
Manually configuring users, SSH keys, and system updates is error-prone. 
This project automates the "Day 0" setup to ensure:
* **Security**: Password logins are disabled for the admin user.
* **Consistency**: Essential packages (Vim, Curl, Git) are installed on every run.
* **Efficiency**: Passwordless Sudo is configured for streamlined automation.

## Tech Stack
* **Controller**: Arch Linux
* **Managed Node**: CentOS 9 Stream (VM)
* **Tooling**: Ansible, Ansible-Vault, OpenSSH

## Project Structure
* `roles/common`: Updates dnf packages and installs core utilities.
* `roles/users`: Creates a `devops` user, manages SSH authorized keys, and configures sudoers.
* `roles/ssh_hardening`: Secures the OpenSSH daemon using a Jinja2 template to enforce key based authentication, disable root login, and prevent brute force attacks via password disablement. 
* `roles/firewall`: Manages the system perimeter by ensuring the firewalld service is active and properly configured to allow only authorized traffic, with built in support for non-standard SSH ports.

## Setup
* **Secrets**: Create an encrypted vault file to store your sudo password.
   ```bash
   ansible-vault create group_vars/all.yml

## Technical Challenges & Solutions

### YAML Syntax & Indentation
**Challenge**: Encountered `Empty playbook` and `expected dicts` errors during initial runs.
**Solution**: Identified that YAML is whitespace-sensitive. Standardized the use of `---` document markers and ensured roles were properly indented under the `roles:` key.

### Secure Secret Management
**Challenge**: Needed to provide a sudo password for the `become` privilege without hardcoding it in plain text.
**Solution**: Implemented **Ansible Vault** to encrypt sensitive variables. Used `group_vars/all.yml` to store the encrypted `ansible_become_pass`, ensuring the repository remains safe for public version control.

### SSH Key Automation
**Challenge**: Automating the transfer of public keys while maintaining the "Controller to Node" relationship.
**Solution**: Utilized the `ansible.builtin.authorized_key` module combined with a `file` lookup to dynamically push the Arch controller's public key to the CentOS managed node.

# Feedback and Contributions
This project was developed as part of my **SysAdmin / DevOps Portfolio** to demonstrate technical proficiency in Linux automation and configuration management. 
I am always looking to improve my workflows and code efficiency. If you have any feedback or suggestions, they are 100% appreciated! Feel free to reach out, constructive conversations and professional networking are always welcome.

# AI-Assisted Development & Quality Assurance
While this project was architected and driven by me, I utilized AI as a collaborative tool for code revisioning, best practice auditing, and logic verification.
- Every AI-generated suggestion was manually reviewed, tested in a sandbox environment, and investigated for its implications before integration.
- AI helped identify and resolve complex YAML parsing issues and Ansible Vault formatting errors (e.g., dict vs. string mismatches).
- The collaborative process was used to refine the "Controller to Node" logic, specifically the secure lookup of local public keys to ensure zero hardcoded secrets in version control.

# Author
Wilberth Barrantes - SysAdmin / DevOps Portfolio Project
