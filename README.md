# Linux SysAdmin & DevOps Portfolio Toolkit

[![CI Pipeline](https://github.com/barrawi/devops-automation-toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/barrawi/devops-automation-toolkit/actions/workflows/ci.yml)

This repository serves as a collection of labs and projects focused on Infrastructure-as-Code (IaC), Linux System Hardening, CI/CD Automation, and Containerization.

The goal of these labs is to demonstrate a production-ready approach to managing Linux environments prioritizing security, idempotency, and comprehensive documentation
<img width="1220" height="30" alt="image" src="https://github.com/user-attachments/assets/bcb5f4d4-3673-4c89-8a74-e3ba9beb7988" />

---

## Core projects

### Cloud Infrastructure Provisioning (Terraform + AWS)
Terraform module that provisions a fully networked, Tailscale connected 3 node RHEL 10 cluster on AWS from scratch. A single `terraform apply` delivers production-ready nodes that are immediately reachable by the Ansible pipeline, no manual SSH, no IP files to maintain.
- **Infrastructure as Code**: VPC, public subnet, internet gateway, security groups, and 3 EC2 instances defined entirely in HCL — reproducible and version-controlled.
- **First-Boot Automation**: user_data script handles the bootstrap problem — creates the `devops` user, configures SSH, and joins Tailscale automatically on launch before Ansible ever connects.
- **Zero Static Configuration**: Destroy and re-apply as many times as needed. The dynamic inventory reconnects to new nodes automatically via Tailscale tags — no IP updates required.
- **Free Tier Aware**: Configured for t2.micro instances within AWS free tier limits.
<img width="886" height="95" alt="image" src="https://github.com/user-attachments/assets/dbfe25e9-f61b-4255-81fa-13e854d06ce7" />

---

### Automated Server Bootstrap (Ansible)
A multi role project that transforms a fresh RHEL installation into a hardened, production-ready node and serves as the deployment backbone for the containerized webapp.
- **Zero-Trust Networking**: Integrated Tailscale (WireGuard) to establish secure, encrypted management tunnels. All CI/CD traffic flows through the Tailscale mesh — VMs are completely dark on the public LAN.
- **Security Hardening**: Automated OpenSSH configuration (disabling root login, enforcing key-based auth) and firewalld zone-based segmentation.
- **Dynamic Inventory**: Custom Python script queries the Tailscale API at runtime to discover prod VMs by tag — no static IP files to maintain. IP changes are handled automatically.
- **Automated Deployment Key Management**: Ansible generates an ed25519 SSH key pair locally, distributes the public key to all prod VMs, and stores the private key for use by GitHub Actions — zero manual key management.
- **Continuous Deployment**: GitHub Actions SSHes into all 3 prod VMs via Tailscale on every successful push to `main`, pulls the latest image from Docker Hub, and restarts the stack with podman-compose.
- **Web Orchestration**: Dynamic deployment of Nginx using Jinja2 templates and Ansible Facts.
- **Post-Deployment Validation**: Testinfra test suite verifies every Ansible role applied correctly — SSH hardening, firewall, Nginx, Tailscale, Podman, and user configuration confirmed across all nodes after every provisioning run.

<img width="1275" height="55" alt="image" src="https://github.com/user-attachments/assets/f2ba7d06-18f1-43dd-ac68-8ce3a118f196" />

---

### Kubernetes Container Orchestration
The containerized Flask + Redis application deployed to a Kubernetes cluster — demonstrating production grade container orchestration with load balancing, service discovery, and Ingress routing.
- **Multi-Replica Deployment**: Flask app runs as 2 replicas with automatic load balancing across pods. Kubernetes restarts failed pods automatically with no manual intervention.
- **Service Discovery**: Pods communicate via stable service names rather than dynamic IPs — Redis is reachable as `redis-service` regardless of pod restarts or rescheduling.
- **Nginx Ingress**: External traffic routed through an Nginx Ingress controller on port 80 — no hardcoded NodePorts or manual Nginx configuration required.
- **ConfigMap-driven Configuration**: Environment variables decoupled from the container image and injected at runtime — configuration changes without image rebuilds.
- **Rolling Updates**: Kubernetes replaces pods one at a time during deployments — zero downtime updates out of the box.
- **Observability**: Prometheus and Grafana deployed via Helm into a dedicated `monitoring` namespace. Real-time metrics scraping from all pods and Kubernetes components via kubelet/cAdvisor, visualized in Grafana dashboards.
- **CI/CD Validated**: Kubernetes manifests are automatically applied to a kind cluster on every push via GitHub Actions — ensuring manifests are always valid and pods start correctly before any code reaches production.
<img width="791" height="92" alt="image" src="https://github.com/user-attachments/assets/82b3d0f9-8873-40e0-9524-c91ba4f3ada5" />

---

### Containerized Web App with CI/CD Pipeline
A Flask web application containerized with Docker and deployed through a fully automated CI/CD pipeline to a 3 node production cluster.
- **Containerization**: Multi stage Docker build using RHEL UBI9 minimal image to reduce attack surface and image size. App runs as a non privileged user.
- **CI/CD Pipeline**: GitHub Actions workflow runs tests, validates Kubernetes manifests against a live kind cluster, builds and pushes the Docker image, and deploys to all 3 prod VMs via Tailscale on every push to `main` — broken code and broken infrastructure config are both caught before deployment.
- **Automated Image Publishing**: Pipeline pushes the production image to Docker Hub on every successful build. Credentials managed securely via GitHub Secrets, never stored in code.
- **Test-Driven**: pytest test suite with fakeredis for isolated, dependency free testing. Redis connection is injected via Flask config to keep test code fully separate from production code.
- **Redis Integration**: Redis health check exposed via `/json` endpoint. Graceful fallback handling ensures the app never crashes when Redis is unavailable.
- **Security**: Secrets managed via `.env` file, excluded from version control. Non-root container user enforced at the Docker level.

<img width="963" height="160" alt="image" src="https://github.com/user-attachments/assets/59e15a94-a736-46d3-b75a-0edfe1c2aa30" />

*Multi-stage build reduced the final image size by 82% — from 1.55GB(my-webapp:v1) down to 286MB(webapp:prod) — by separating the build environment from the runtime image and using RHEL UBI9 minimal as the production base.*

---

### Local VM Management (Bash)
Shell scripts that replace Terraform for local KVM VM provisioning — spin up a full 3 node lab environment from a single command using cloud-init for first-boot automation.
- **Single Command Setup**: `setup-local-vms.sh` copies the base image, provisions VMs with cloud-init, creates the devops user, injects SSH keys, and joins Tailscale automatically.
- **Parity with Cloud**: Local VMs join the same Tailscale mesh as cloud nodes — the dynamic Ansible inventory discovers them automatically with no configuration changes.
- **Clean Teardown**: `destroy-local-vms.sh` stops, undefines, and removes all VM disks cleanly.
- **Configurable Count**: Pass a number to create or destroy exactly as many VMs as needed.
<img width="619" height="24" alt="image" src="https://github.com/user-attachments/assets/8513caed-d5d0-4fc4-8d8e-f7ae5dd8a6cd" />

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
| Operating Systems | Red Hat Enterprise Linux 10, CentOS 9 Stream, Arch Linux (Controller) |
| Cloud | AWS (EC2, VPC, Security Groups) |
| Infrastructure as Code | Terraform |
| Container Orchestration | Kubernetes (minikube), kubectl, Nginx Ingress |
| Automation | Ansible (Roles, Playbooks, Vault, Handlers, Dynamic Inventory) |
| Containerization | Docker, Podman, podman-compose |
| CI/CD | GitHub Actions |
| Testing | pytest, Testinfra, fakeredis |
| Container Registry | Docker Hub |
| Security | Tailscale/WireGuard, SSH Hardening, Firewalld, Ansible Vault |
| Languages | Python (Flask, pytest), Bash, HCL |
| Databases | Redis |
| Networking | Zero Trust VPN Overlay, Zone-based Firewall, AWS VPC, Kubernetes Ingress |
| Monitoring | Prometheus, Grafana, Helm |

---

## My Technical Philosophy

- **Security by Default**: Every lab starts with a "Default Deny" posture. Access is only granted through secure, encrypted tunnels.
- **Documentation as Code**: Every project includes Standard Operating Procedures (SOPs) and Runbooks to ensure that infrastructure is not just automated, but maintainable.
- **Idempotency**: All automation is designed to be run multiple times without changing the result beyond the initial application, ensuring system stability.
- **Shift Left Testing**: Tests run automatically at the earliest possible stage — on every push, before any deployment — so bugs are caught cheaply and fast.
- **Dynamic over Static**: Infrastructure should adapt automatically. Static IP files and hardcoded values are replaced with dynamic discovery wherever possible.

---

## Roadmap

- Thinking about it...

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
