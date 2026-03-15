#!/bin/bash

# destroy_localvms.sh 
# script to delete locally created VMs
# Wilberth Barrantes Calderon
# Tested on Arch

set -euo pipefail # exit on error, nounset, pipeline fail

 
# --- configuration ---
IMAGES_DIR="/home/w/.local/share/libvirt/images"
VM_COUNT=${1:-3} # default 3
PROJECT_NAME="devops-lab"
 
echo ">>> Destroying local VMs..."
 
for i in $(seq 1 $VM_COUNT); do
    VM_NAME="${PROJECT_NAME}-prod-local0${i}"
    VM_DISK="${IMAGES_DIR}/${VM_NAME}.qcow2"
 
    echo "    Stopping $VM_NAME..."
    virsh -c qemu:///session destroy "$VM_NAME" 2>/dev/null || true
 
    echo "    Undefining $VM_NAME..."
    virsh -c qemu:///session undefine "$VM_NAME" 2>/dev/null || true
 
    echo "    Deleting disk $VM_DISK..."
    rm -f "$VM_DISK"
 
    echo "    $VM_NAME destroyed."
done
 
echo ""
echo "All local VMs destroyed." 
