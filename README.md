# Linux SysAdmin & DevOps Portfolio Labs
This repository serves as a collection of labs and projects focused on Infrastructure-as-Code (IaC), Linux System Hardening, and Automation Tooling.

The goal of these labs is to demonstrate a production-ready approach to managing Linux environments—prioritizing security, idempotency, and comprehensive documentation

## Core projects

### Automated Server Bootstrap (Ansible)
A multi role project that transforms a fresh CentOS 9 installation into a hardened, production ready node.
- **Zero-Trust Networking**: Integrated Tailscale (WireGuard) to establish secure, encrypted management tunnels.
- **Security Hardening**: Automated OpenSSH configuration (disabling root login, enforcing key-based auth) and firewalld orchestration.
- **Web Orchestration**: Dynamic deployment of Nginx using Jinja2 templates and Ansible Facts.

### User Lifecycle Automation Toolkit (Bash)
A small suite of defensive shell scripts designed for enterprise-scale user management.
- **Safety First**: Implemented set -euo pipefail and root-privilege validation to ensure script reliability.
- **Idempotent Logic**: Scripts verify existing system states (e.g., checking if a user exists or is logged in) before execution to prevent system errors.
- **Auditability**: All actions are logged to /var/log/user_administration.log with timestamps and actor IDs.

### AI-Collaborative Content Exporter (Python)
A custom utility built to facilitate secure code auditing and AI collaboration.
- **Security Filtering**: Automatically detects and redacts sensitive data and Ansible Vault headers during export.
- **Pattern Matching**: Respects .gitignore patterns and filters by file extension to provide clean, relevant technical context.

## My Technical Stack
- **Operating Systems**: Red Hat / CentOS 9 Stream, Arch Linux (Controller).
- **Automation**: Ansible (Roles, Playbooks, Vault, Handlers).
- **Security**: Tailscale/WireGuard, SSH Hardening, Firewalld.
- **Languages**: Python (Tooling), Bash (System Scripts).

## My Technical Philosophy
- **Security by Default**: Every lab starts with a "Default Deny" posture. Access is only granted through secure, encrypted tunnels.
- **Documentation as Code**: Every project includes Standard Operating Procedures (SOPs) and Runbooks to ensure that infrastructure is not just automated, but maintainable.
- **Idempotency**: All automation is designed to be run multiple times without changing the result beyond the initial application, ensuring system stability.

## Roadmap
- Transition local VM labs to AWS/Cloud environments.
- Implement Terraform for automated resource provisioning.
- Develop CI/CD pipelines for automated testing of Ansible roles.

# AI-Assisted Development & Quality Assurance
While this suite was architected and driven by me, I utilized AI as a collaborative tool for code revisioning, best practice auditing, and logic verification. This partnership allowed for a rigorous development cycle:
- **Manual Oversight**: Every AI generated suggestion was manually reviewed, tested in a sandbox environment, and investigated for security implications before integration.
- **Edge Case Identification**: AI assisted in identifying potential failure points, such as the "unbound variable" errors common with set -u in Bash, leading to a more resilient final product.
- **Logic Refinement**: The collaborative process was used to refine complex system logic, such as implementing Custom File Descriptor 3 for conflict free bulk processing in the User Management scripts.
- **Security Auditing**: AI was used to peer review the Ansible Vault implementation and SSH hardening templates to ensure they met modern industry standards.

# Author
Wilberth Barrantes - SysAdmin / DevOps portfolio Project.
