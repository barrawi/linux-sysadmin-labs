# Linux SysAdmin & DevOps Portfolio Toolkit
This repository serves as a collection of labs and projects focused on Infrastructure-as-Code (IaC), Linux System Hardening, CI/CD Automation, and Containerization.

The goal of these labs is to demonstrate a production-ready approach to managing Linux environments prioritizing security, idempotency, and comprehensive documentation
<img width="1220" height="30" alt="image" src="https://github.com/user-attachments/assets/bcb5f4d4-3673-4c89-8a74-e3ba9beb7988" />

---

## Core projects

### Automated Server Bootstrap (Ansible)
A multi role project that transforms a fresh CentOS 9 installation into a hardened, production ready node.
- **Zero-Trust Networking**: Integrated Tailscale (WireGuard) to establish secure, encrypted management tunnels.
- **Security Hardening**: Automated OpenSSH configuration (disabling root login, enforcing key-based auth) and firewalld orchestration.
- **Web Orchestration**: Dynamic deployment of Nginx using Jinja2 templates and Ansible Facts.
<img width="1275" height="55" alt="image" src="https://github.com/user-attachments/assets/f2ba7d06-18f1-43dd-ac68-8ce3a118f196" />

---


### Containerized Web App with CI/CD Pipeline
A Flask web application containerized with Docker and deployed through a fully automated CI/CD pipeline.
- **Containerization**: Multi stage Docker build using RHEL UBI9 minimal image to reduce attack surface and image size. App runs as a non privileged user.
- **CI/CD Pipeline**: GitHub Actions workflow automatically runs tests and builds the Docker image on every push to `main` — broken code is caught before it can be deployed.
- **Automated Image Publishing**: The GitHub Actions pipeline automatically pushes the production image to Docker Hub on every successful build credentials managed securely via GitHub Secrets, never stored in code.
- **Test-Driven**: pytest test suite with fakeredis for isolated, dependency-free testing. Redis connection is injected via Flask config to keep test code fully separate from production code.
- **Redis Integration**: Redis health check exposed via `/json` endpoint. Graceful fallback handling ensures the app never crashes when Redis is unavailable.
- **Security**: Secrets managed via `.env` file, excluded from version control. Non root container user enforced at the Docker level.
<img width="963" height="160" alt="image" src="https://github.com/user-attachments/assets/59e15a94-a736-46d3-b75a-0edfe1c2aa30" />

*Multi-stage build reduced the final image size by 82% — from 1.55GB(my-webapp:v1) down to 286MB(webapp:prod) — by separating the build environment from the runtime image and using RHEL UBI9 minimal as the production base.*


---

### User Lifecycle Automation Toolkit (Bash)
A small suite of defensive shell scripts designed for enterprise-scale user management.
- **Safety First**: Implemented set -euo pipefail and root-privilege validation to ensure script reliability.
- **Idempotent Logic**: Scripts verify existing system states (e.g., checking if a user exists or is logged in) before execution to prevent system errors.
- **Auditability**: All actions are logged to /var/log/user_administration.log with timestamps and actor IDs.
<img width="804" height="25" alt="image" src="https://github.com/user-attachments/assets/90487df9-8cc6-49db-9c5d-b1aec4ff1180" />

---

### AI-Collaborative Content Exporter (Python)
A custom utility built to facilitate secure code auditing and AI collaboration.
- **Security Filtering**: Automatically detects and redacts sensitive data and Ansible Vault headers during export.
- **Pattern Matching**: Respects `.gitignore` patterns and filters by file extension to provide clean, relevant technical context.
<img width="405" height="396" alt="image" src="https://github.com/user-attachments/assets/6cc3f449-91d2-4df2-be8f-4ed0156ba811" />

---

## My Technical Stack

| Category | Tools |
|---|---|
| Operating Systems | Red Hat / CentOS 9 Stream, Arch Linux (Controller) |
| Automation | Ansible (Roles, Playbooks, Vault, Handlers) |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Container Registry | Docker Hub |
| Security | Tailscale/WireGuard, SSH Hardening, Firewalld |
| Languages | Python (Flask, pytest), Bash |
| Databases | Redis |

---

## My Technical Philosophy
- **Security by Default**: Every lab starts with a "Default Deny" posture. Access is only granted through secure, encrypted tunnels.
- **Documentation as Code**: Every project includes Standard Operating Procedures (SOPs) and Runbooks to ensure that infrastructure is not just automated, but maintainable.
- **Idempotency**: All automation is designed to be run multiple times without changing the result beyond the initial application, ensuring system stability.
- **Shift Left Testing**: Tests run automatically at the earliest possible stage — on every push, before any deployment — so bugs are caught cheaply and fast.

---

## Roadmap

- Transition local VM labs to AWS/Cloud environments.
- Implement Terraform for automated resource provisioning.
- Add automated deployment step to CI/CD pipeline (push to main → auto-deploy to server).
- Expand test coverage with Testinfra for post deployment server validation.

---

## AI-Assisted Development & Quality Assurance
While this suite was architected and driven by me, I utilized AI as a collaborative tool for code revisioning, best practice auditing, and logic verification. This partnership allowed for a rigorous development cycle:
- **Manual Oversight**: Every AI generated suggestion was manually reviewed, tested in a sandbox environment, and investigated for security implications before integration.
- **Edge Case Identification**: AI assisted in identifying potential failure points, such as the "unbound variable" errors common with `set -u` in Bash, leading to a more resilient final product.
- **Logic Refinement**: The collaborative process was used to refine complex system logic, such as implementing Custom File Descriptor 3 for conflict free bulk processing in the User Management scripts.
- **Security Auditing**: AI was used to peer review the Ansible Vault implementation and SSH hardening templates to ensure they met modern industry standards.

---

## Feedback and Contributions
This project was developed as part of my **SysAdmin / DevOps Portfolio** to demonstrate technical proficiency in Linux automation and shell scripting. 
I am always looking to improve my workflows and code efficiency. If you have any feedback or suggestions, they are 100% appreciated! Feel free to reach out, constructive conversations and professional networking are always welcome.

---

# Author
Wilberth Barrantes - SysAdmin / DevOps Toolkit.
