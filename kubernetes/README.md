# Kubernetes — Container Orchestration
 
This folder contains the Kubernetes manifests for deploying the containerized Flask + Redis application to a cluster. The same application deployed via Docker Compose and the CI/CD pipeline is here managed by Kubernetes — providing automatic restarts, load balancing, and traffic routing via Nginx Ingress.
 
---
 
## What It Deploys
 
- **Flask app** — 2 replicas, load balanced via Ingress
- **Redis** — single instance, internal only
- **Nginx Ingress** — routes external traffic to the Flask service
- **ConfigMap** — injects environment configuration into containers
- **Resource limits** —  CPU and memory requests/limits defined for all containers
- **Health probes** —  liveness and readiness probes on Flask (HTTP) and Redis (TCP)
- **Prometheus + Grafana** — monitoring stack deployed via Helm, scraping metrics from all pods and Kubernetes components.
 
---
 
## Prerequisites
 
- A running Kubernetes cluster (minikube for local development)
- `kubectl` configured to talk to the cluster
- Flask image available on Docker Hub (`barrawi/containerized-webapp:latest`)
 
**For local development with minikube:**
```bash
minikube start --driver=docker
minikube addons enable ingress
```
 
Add the local domain to your hosts file:
```bash
echo "$(minikube ip) flask.local" | sudo tee -a /etc/hosts
```
Install Helm
```bash
sudo pacman -S helm
```
Add Prometheus community charts
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
Install monitoring stack
```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```
Add Grafana to hosts file
```bash
echo "$(minikube ip) grafana.local" | sudo tee -a /etc/hosts
```
---
 
## Usage
 
**Deploy everything:**
```bash
kubectl apply -f .
```
 
**Check status:**
```bash
kubectl get all
kubectl get ingress
```
 
**Access the app:**
```bash
# Via Ingress (after hosts file entry)
curl -H "Host: flask.local" http://$(minikube ip)
 
# Via port-forward (no hosts file needed)
kubectl port-forward service/flask-service 5000:5000
```
 
**Tear down:**
```bash
kubectl delete -f .
```
 
---
 
## File Structure
 
```
kubernetes/
├── configmap.yml           # App environment variables
├── redis-deployment.yml    # Redis container definition
├── redis-service.yml       # Redis internal ClusterIP service
├── flask-deployment.yml    # Flask app, 2 replicas
├── flask-service.yml       # Flask NodePort service
├── ingress.yml             # Nginx Ingress routing rules
└── monitoring-ingress.yml  # Grafana Ingress routing rules
```
 
---
 
## Key Concepts Demonstrated
 
**Load balancing** — 2 Flask replicas run simultaneously. Kubernetes distributes traffic between them automatically. Each request may be handled by a different pod — visible in the `Container Hostname` field of the app response.
 
**Service discovery** — Flask finds Redis using the service name `redis-service` as the hostname. Pod IPs are dynamic and change on restart — services provide a stable internal address.
 
**Ingress** — Nginx Ingress controller handles external traffic routing on port 80. Rules are defined in YAML, no manual Nginx configuration required.
 
**ConfigMap** — environment variables are defined separately from the container image and injected at runtime. Configuration changes don't require rebuilding the image.
 
**Self-healing** — if a pod crashes Kubernetes automatically restarts it. If a node fails pods are rescheduled to healthy nodes.
 
**Resource management** —  CPU and memory requests/limits defined for every container. Requests guarantee minimum resources for scheduling, limits prevent any single container from consuming excessive resources.

**Health probes** — liveness probes restart unresponsive pods automatically. Readiness probes remove pods from the load balancer during startup or degraded states, ensuring traffic only reaches healthy instances.

**Observability** ─ Prometheus and Grafana deployed via Helm into a dedicated `monitoring` namespace. Prometheus scrapes container and Kubernetes metrics via kubelet/cAdvisor. Grafana visualizes CPU, memory, and resource usage per pod and namespace in real time.

---
 
# Author
Wilberth Barrantes - SysAdmin / DevOps Toolkit.
