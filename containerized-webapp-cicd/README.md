# Containerized Webapp & Redis Toolkit (Secure DevOps Pattern)

## Project Overview

This project demonstrates a production hardened approach to containerizing a Python Flask application and a Redis cache. Moving beyond a simple "Hello World," this lab focuses on Multi-Stage Builds, Non Privileged User Security, Automated Testing, and a full CI/CD pipeline using GitHub Actions.

The goal is to provide a "Development to Production" blueprint that reduces image size, minimizes the attack surface, enforces test driven quality gates, and ensures data persistence.

---

## Key DevOps Features

- **Multi-Stage Dockerfile**: Uses a Python 3.11 "Builder" image to compile dependencies and a Red Hat UBI9 minimal "Runtime" image to serve the app resulting in an 82% image size reduction from 1.55GB down to 286MB.
- **CI/CD Pipeline**: GitHub Actions workflow automatically runs the test suite and builds the Docker image on every push to `main`. Broken code is caught before it can be deployed.
- **Test-Driven Development**: pytest test suite with fakeredis for fully isolated, dependency free testing. Redis is injected via Flask config so test infrastructure stays completely separate from production code.
- **Docker Hub Integration**: On a successful build, the pipeline automatically tags and pushes the image to Docker Hub using encrypted GitHub Secrets for authentication no credentials are ever stored in the codebase.
- **Security Hardening**:
  - Runs as a non root `webuser` (UID 1001).
  - No unnecessary tools (like `ping` or `curl`) included in the final image to prevent lateral movement.
  - Secrets managed via `.env` file, excluded from version control.
- **Internal Service Networking**: App and Redis communicate over a private bridge network, never exposed to the host.
- **Environment Parity**: `.env` file support for dynamic port mapping and configuration across environments.
- **Persistent Storage**: Named volumes ensure Redis data survives container restarts.

---

## Project Structure

```
devops-automation-toolkit
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions CI pipeline
containerized-webapp-ci/
├── app/
│   ├── __init__.py
│   ├── main.py             # Flask app
│   ├── requirements.txt    # Production dependencies
│   └── templates/
│       └── index.html      # Web dashboard
├── tests/
│   └── test_app.py         # pytest test suite
├── Dockerfile              # Multi-stage build
├── docker-compose.yml      # Service definitions
├── pytest.ini              # pytest configuration
└── .env                    # Local environment variables (not committed)
```

---

## CI/CD Pipeline

Every push to `main` triggers the following automated workflow:

```
push to main
      ↓
Checkout repo
      ↓
Set up Python 3.11
      ↓
Install dependencies
      ↓
Run pytest ← fails here if tests break, build is blocked
      ↓
Log in to Docker Hub
      ↓
Build Docker image
      ↓
Push to Docker Hub ← image is publicly available automatically
```

This ensures no broken code ever reaches the build stage.


---

## How to Run Locally

**Requirements**: Docker and Docker Compose installed. Your user should be part of the `docker` group to run without `sudo`.

### Configuration
Create a `.env` file in the root directory:

```bash
APP_PORT=8001
FLASK_ENV=Development
REDIS_HOST=cache
REDIS_PORT=6379
```

### Run Tests First

```bash
pytest tests/
```

### Deployment

Build and launch the stack in detached mode:

```bash
docker compose up -d --build
```

### Verification

| Endpoint | URL |
|---|---|
| Web Dashboard | `http://localhost:8001/` |
| JSON Metadata | `http://localhost:8001/json` |
| Health Check | `http://localhost:8001/health` |

---

## Troubleshooting & Debugging

Since this is a hardened image, standard tools are missing. Use these methods for debugging:

**Check Redis Connection via Python**:
```bash
docker compose exec webapp python3.11 -c "import socket; s = socket.socket(); print(s.connect_ex(('cache', 6379)))"
```
**Check Container Logs**:
```bash
docker compose logs -f webapp
```
**Check GitHub Actions pipeline:**

Go to the **Actions** tab on the GitHub repository to see live pipeline output for every push.

---

## AI-Assisted Development & Quality Assurance

Consistent with modern DevOps workflows, this project utilized AI as a collaborative "pair programmer" for:

* **Security Auditing**: Verifying the ubi-minimal implementation and non-root user permissions.

* **Logic Verification**: Debugging Docker networking and port-forwarding issues.

* **Documentation**: Refining technical explanations and architecture diagrams.

Every AI generated suggestion was manually reviewed, tested in a sandbox environment, and investigated it for security implications before integration.

---

## Feedback and Contributions

This project is part of my DevOps / Automation Portfolio. I am constantly looking to refine my infrastructure patterns. If you have suggestions regarding compliance, image optimization, or CI/CD integration, your feedback is highly appreciated. Constructive conversations and professional networking are always welcome.

## Author
Wilberth Barrantes - *DevOps / Automation Toolkit*

