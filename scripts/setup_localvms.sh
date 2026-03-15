#!/bin/bash

# setup_localvms.sh
# This script will generate vms based on a gold-machine image, copy the volumes and set tailscale on them
# Wilberth Barrantes Calderon
# Tested on Arch

set -euo pipefail #  exit on error, nounset, pipeline fail

# --- configuration ---
BASE_IMAGE="/home/w/.local/share/libvirt/images/gold-machine.qcow2"
IMAGES_DIR="/home/w/.local/share/libvirt/images"
SSH_KEY_FILE="$HOME/.ssh/devops-lab-key.pem"
TAILSCALE_AUTHKEY="${TAILSCALE_AUTHKEY:-}"
VM_COUNT=${1:-3} # default 3
VM_MEMORY=2048
VM_VCPUS=2
PROJECT_NAME="devops-lab"

# --- error validation ---
if [[ ! -f "$BASE_IMAGE" ]]; then
    echo "Error: Base image not found at $BASE_IMAGE"
    exit 1
fi

if [[ ! -f "$SSH_KEY_FILE" ]]; then
    echo "Error: SSH key not found at $SSH_KEY_FILE"
    exit 1
fi

if [[ -z "$TAILSCALE_AUTHKEY" ]]; then
    echo "Error: TAILSCALE_AUTHKEY environment variable is not set"
    echo "Usage: TAILSCALE_AUTHKEY=tskey-auth-... ./scripts/setup-local-vms.sh"
    exit 1
fi

SSH_PUBLIC_KEY=$(ssh-keygen -y -f "$SSH_KEY_FILE")

# --- create cloud-init user-data ---

# ssh key is written to /tmp/ passed to virt-install and then deleted
create_user_data() {
    local hostname=$1
    cat <<EOF
#cloud-config
hostname: ${hostname}
users:
  - name: devops
    groups: wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${SSH_PUBLIC_KEY} 
runcmd:
  - hostnamectl set-hostname ${hostname}
  - curl -fsSL https://tailscale.com/install.sh | sh
  - tailscale up --auth-key=${TAILSCALE_AUTHKEY} --advertise-tags=tag:prod --reset --hostname=${hostname}
EOF
}

# --- provision VMs ---
for i in $(seq 1 $VM_COUNT); do
    VM_NAME="${PROJECT_NAME}-prod-local0${i}"
    VM_DISK="${IMAGES_DIR}/${VM_NAME}.qcow2"
    USERDATA_FILE="/tmp/${VM_NAME}-userdata.yaml"

    echo ">>> Setting up $VM_NAME..."

    # skip if already running
    if virsh -c qemu:///session dominfo "$VM_NAME" &>/dev/null; then
        echo "    $VM_NAME already exists, skipping."
        continue
    fi

    # copy base image
    echo "    Copying base image..."
    cp "$BASE_IMAGE" "$VM_DISK"
    chmod 644 "$VM_DISK"

    # write cloud-init user-data
    create_user_data "$VM_NAME" > "$USERDATA_FILE"

    # create and boot VM
    echo "    Creating VM..."
    virt-install \
        --connect qemu:///session \
        --name "$VM_NAME" \
        --memory $VM_MEMORY \
        --vcpus $VM_VCPUS \
        --disk "$VM_DISK",format=qcow2 \
        --import \
        --os-variant rhel10.0 \
        --network bridge:nm-bridge \
        --cloud-init user-data="$USERDATA_FILE" \
        --noautoconsole \
        --wait 0

    # clean up temp file
    rm -f "$USERDATA_FILE"

    echo "$VM_NAME created and booting."
done

echo ""
echo "All VMs created. Waiting for Tailscale to register nodes..."
echo "Check your Tailscale admin console for prod-local01, prod-local02, prod-local03."
echo ""
echo "Once nodes appear, run Ansible:"
echo "  cd ansible-server-bootstrap"
echo "  ansible-playbook -i inventories/tailscale_inventory.py site.yml"
