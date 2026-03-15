# Terraform — AWS Infrastructure Provisioning

This module provisions the cloud infrastructure that backs the Ansible bootstrap and CI/CD pipeline. A single `terraform apply` brings up a fully networked, Tailscale connected 3 node RHEL cluster on AWS, ready for Ansible to configure.

---

## What It Provisions

- **VPC** with a public subnet, internet gateway, and route table
- **Security Group** — SSH (22) and app port (8000) open; all other ingress blocked
- **3 x RHEL 10 EC2 instances** (t2.micro, free tier eligible)
- **First-boot automation via user_data** — sets hostname, creates the `devops` user, copies SSH authorized keys, and joins Tailscale automatically on launch

Once `terraform apply` completes, all 3 nodes appear in your Tailscale admin console tagged as `tag:prod` and are immediately reachable by the dynamic Ansible inventory — no manual SSH, no IP files to update.

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform installed (`terraform -v`)
- An existing EC2 key pair in your target region
- A Tailscale pre-authorized reusable auth key with `tag:prod`

---

## Usage

```bash
cd terraform/aws

# First time only
terraform init

# Review what will be created
terraform plan

# Provision infrastructure
terraform apply

# Tear down when done (important — avoid free tier charges)
terraform destroy
```

---

## Configuration

Copy the example vars file and fill in your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

| Variable | Description | Default |
|---|---|---|
| `aws_region` | AWS region to deploy into | `us-east-1` |
| `ami_id` | RHEL 10 AMI ID for your region | required |
| `instance_type` | EC2 instance type | `t2.micro` |
| `instance_count` | Number of nodes to provision | `3` |
| `key_name` | Name of your EC2 key pair | required |
| `project_name` | Tag prefix applied to all resources | `devops-lab` |
| `tailscale_authkey` | Pre-authorized Tailscale auth key | required (sensitive) |

> `terraform.tfvars` is gitignored. Never commit real values. Use `terraform.tfvars.example` as the reference template.

---

## How It Connects to Ansible

The user_data script runs on first boot and handles the bootstrap problem, how does Ansible reach a machine it has never seen before?

1. Terraform launches the instance
2. user_data creates the `devops` user, copies SSH keys from `ec2-user`, and runs `tailscale up --auth-key=... --advertise-tags=tag:prod`
3. The node joins the Tailscale mesh and becomes immediately reachable
4. The dynamic inventory script (`inventories/tailscale_inventory.py`) queries the Tailscale API, discovers all `tag:prod` nodes, and returns them as an Ansible host group
5. `ansible-playbook -i inventories/tailscale_inventory.py site.yml` configures everything from there

No static IP files. No manual intervention. Destroy and re-apply as many times as needed — the pipeline reconnects automatically.

---

## File Structure

```
terraform/
├── aws/
    ├── main.tf                  # VPC, subnet, security group, EC2 instances, user_data
    ├── variables.tf             # Variable declarations with types and descriptions
    ├── outputs.tf               # Public IPs and hostnames after apply
    ├── terraform.tfvars         # Your actual values (gitignored)
    └── terraform.tfvars.example # Template for the repo
```

---

## Cost

All resources are within the AWS free tier when using `t2.micro` instances (750 hrs/month for 12 months). Run `terraform destroy` when not actively using the lab to avoid accumulating hours across multiple instances.

---

## Feedback and Contributions
This project was developed as part of my **SysAdmin / DevOps Portfolio** to demonstrate technical proficiency in Linux automation and shell scripting. 
I am always looking to improve my workflows and code efficiency. If you have any feedback or suggestions, they are 100% appreciated! Feel free to reach out, constructive conversations and professional networking are always welcome.

---

# Author
Wilberth Barrantes - SysAdmin / DevOps Toolkit.
