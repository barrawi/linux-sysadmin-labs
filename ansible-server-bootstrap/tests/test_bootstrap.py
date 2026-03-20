"""
test_bootstrap.py
Testinfra post-deployment validation
Verifies that ansible roles are applied correctly to RHEL nodes
Wilberth Barrantes
"""

import pytest  # in case I need it later


def test_devops_user_exists(host):
    user = host.user("devops")
    assert user.exists
    assert "wheel" in user.groups


def test_ssh_root_login_disabled(host):
    # only readable by root
    cmd = host.run("sudo grep -q 'PermitRootLogin no' /etc/ssh/sshd_config")
    assert cmd.rc == 0


def test_ssh_password_auth_disabled(host):
    # only readable by root
    cmd = host.run(
        "sudo grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config"
    )
    assert cmd.rc == 0


def test_sshd_is_running(host):
    sshd = host.service("sshd")
    assert sshd.is_running
    assert sshd.is_enabled


def test_firewalld_is_running(host):
    firewalld = host.service("firewalld")
    assert firewalld.is_running
    assert firewalld.is_enabled


def test_nginx_is_running(host):
    nginx = host.service("nginx")
    assert nginx.is_running
    assert nginx.is_enabled


def test_tailscale_is_running(host):
    tailscale = host.service("tailscaled")
    assert tailscale.is_running
    assert tailscale.is_enabled


def test_podman_is_installed(host):
    podman = host.package("podman")
    assert podman.is_installed
