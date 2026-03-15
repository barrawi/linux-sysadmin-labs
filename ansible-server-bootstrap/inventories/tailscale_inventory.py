#!/usr/bin/env python3
"""
Dynamic Ansible inventory using Tailscale API
Returns all devices tagged with 'tag:prod' as a host group
Wilberth Barrantes
"""

import json
import os
import sys
import urllib.request

# read enviroment vars
TAILSCALE_API_KEY = os.environ.get("TAILSCALE_API_KEY")
TAILSCALE_TAILNET = os.environ.get(
    "TAILSCALE_TAILNET", "-"
)  # - uses defaul tailnet
PROD_TAG = os.environ.get("TAILSCALE_PROD_TAG", "tag:prod")
ANSIBLE_USER = os.environ.get("ANSIBLE_USER", "devops")


# http reques to tailscale api
def get_devices():
    headers = {
        "Authorization": f"Bearer {TAILSCALE_API_KEY}",
        "User-Agent": "Ansible-Dynamic-Inventory-1.0",
    }  # using headers actually solved the issue haha
    url = (
        f"https://api.tailscale.com/api/v2/tailnet/{TAILSCALE_TAILNET}/devices"
    )

    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=5) as response:
            return json.loads(response.read().decode()).get("devices", [])
    except Exception as e:
        print(f"ERROR: Fetching devices failed: {e}", file=sys.stderr)
        sys.exit(1)


# loops through every device tailscale returned searching gor the tag
def build_inventory(devices):
    hosts = {}
    groups = {}

    for device in devices:
        # only include devices tagged as prod
        tags = device.get("tags", [])
        if not tags:
            continue

        name = device["hostname"]
        ip = device["addresses"][0]  # first address is always tailscale ip

        if name.startswith("github-"):  # avoid runner
            continue

        hosts[name] = {
            "ansible_host": ip,
            "ansible_user": ANSIBLE_USER,  # dehardcoded
        }

        # add host to a new group per tag
        for tag in tags:
            group_name = tag.replace(":", "_")  # remove colons for ansible
            if group_name not in groups:
                groups[group_name] = {"hosts": []}
            groups[group_name]["hosts"].append(name)

    groups["webservers"] = {"hosts": list(hosts.keys())}

    # grab hostname and ip, add to dictionary
    inventory = {
        **groups,
        "_meta": {"hostvars": hosts},
    }
    return inventory


def main():
    if not TAILSCALE_API_KEY:
        print(
            "Error: TAILSCALE_API_KEY enviroment variable not set",
            file=sys.stderr,
        )
        sys.exit(1)

    # ansible passes --list or --host
    if len(sys.argv) > 1 and sys.argv[1] == "--host":
        print(json.dumps({}))
        return

    devices = get_devices()
    inventory = build_inventory(devices)
    print(json.dumps(inventory, indent=2))


if __name__ == "__main__":
    main()
