# Local VM Management Scripts

Helper scripts for managing the local KVM environment. These scripts replace Terraform for local VM provisioning — Terraform manages cloud infrastructure (AWS), these scripts handle the local lab.

---

## Scripts

### `setup-local-vms.sh`
Copies the base image, creates KVM virtual machines, and bootstraps each one with cloud-init — devops user, SSH key, hostname, and Tailscale registration. Accepts an optional count argument, defaults to 3.

```bash
# Create 3 VMs (default)
TAILSCALE_AUTHKEY=tskey-auth-... ./scripts/setup-local-vms.sh

# Create 2 VMs
TAILSCALE_AUTHKEY=tskey-auth-... ./scripts/setup-local-vms.sh 2
```

Once VMs are up and registered in Tailscale, run Ansible:
```bash
cd ansible-server-bootstrap
ansible-playbook -i inventories/tailscale_inventory.py site.yml
```

### `destroy-local-vms.sh`
Stops and undefines VMs and deletes their disk images. Accepts an optional count argument, defaults to 3.

```bash
# Destroy 3 VMs (default)
./scripts/destroy-local-vms.sh

# Destroy 2 VMs
./scripts/destroy-local-vms.sh 2
```

---

## Prerequisites

- `virt-install` and `libvirt` installed and running
- Base image at `/home/w/.local/share/libvirt/images/gold-machine.qcow2`
- SSH key at `~/.ssh/devops-lab-key.pem`
- `TAILSCALE_AUTHKEY` environment variable set at runtime (never stored in code)

---

## How It Works

```
setup-local-vms.sh
  └── copies gold-machine.qcow2 per VM
  └── runs virt-install with cloud-init
      └── cloud-init sets hostname
      └── cloud-init creates devops user + SSH key
      └── cloud-init installs and joins Tailscale (tag:prod)
          └── dynamic inventory discovers VMs automatically
              └── Ansible configures everything from there
```

---

# Author
Wilberth Barrantes - SysAdmin / DevOps Toolkit.
