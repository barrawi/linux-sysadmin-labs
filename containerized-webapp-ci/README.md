# Containerized Webapp & Redis Toolkit (Secure DevOps Pattern)

## Project Overview
This project demonstrates a production hardened approach to containerizing a Python Flask application and a Redis cache. Moving beyond a simple "Hello World," this lab focuses on Multi Stage Builds, Non privileged User Security, and Internal Service Networking using Docker Compose.

The goal is to provide a "Development to Production" blueprint that reduces image size, minimizes the attack surface, and ensures data persistence.

## Key DevOps Features

* **Multi-Stage Dockerfile**: Uses a Python 3.11 "Builder" image to compile dependencies and a Red Hat ubi-minimal "Runtime" image to serve the app, resulting in a lightweight, secure final image.

* **Security Hardening**: 

    * Runs as a non-root webuser (UID 1001).

    * No unnecessary tools (like ping or curl) included in the final image to prevent lateral movement.

* **Environment Parity**: Uses .env file support for dynamic port mapping and configuration.

* **Persistent Storage**: Configured with named volumes to ensure Redis data survives container restarts.

## Project Structure

* `app/`: Contains the Flask source code, templates, and requirements.

* `Dockerfile`: The two-stage build recipe.

* `docker-compose.yml`: Defines the services, networking, and volumes.

* `.env`: Local environment variables (Port and App Environment).

## How to Run Locally
* Docker and Docker Compose installed (Tested on Arch Linux).

* Your user should be part of the docker group to run commands without sudo (Otherwise just add sudo before the commands).

### Configuration
Create a `.env` file in the root directory:

```bash
APP_PORT=8001
APP_ENV=Development
```
### Deployment
Build and launch the stack in detached mode:
```bash
docker compose up -d --build
```
### Verification
Access the different endpoints to verify the stack:
* Web Dashboard: `http://localhost:8001/`
* JSON Metadata: `http://localhost:8001/json`
* Health Check: `http://localhost:8001/health`

## Troubleshooting & Debugging

Since this is a hardened image, standard tools are missing. Use these "DevOps" methods for debugging:

**Check Redis Connection via Python**:
```bash
docker compose exec webapp python3.11 -c "import socket; s = socket.socket(); print(s.connect_ex(('cache', 6379)))"
```
**Check Container Logs**:
```bash
docker compose logs -f webapp
```
## AI-Assisted Development & Quality Assurance
Consistent with modern DevOps workflows, this project utilized AI as a collaborative "pair programmer" for:

* **Security Auditing**: Verifying the ubi-minimal implementation and non-root user permissions.

* **Logic Verification**: Debugging Docker networking and port-forwarding issues.

* **Documentation**: Refining technical explanations and architecture diagrams.

Every AI generated suggestion was manually reviewed, tested in a sandbox environment, and investigated it implications before integration.

## Feedback and Contributions
This project is part of my *DevOps / Automation Portfolio*. I am constantly looking to refine my infrastructure patterns. If you have suggestions regarding compliance, image optimization, or CI/CD integration, your feedback is highly appreciated! Constructive conversations and professional networking are always welcome.

## Author
Wilberth Barrantes - *DevOps / Automation Portfolio*

