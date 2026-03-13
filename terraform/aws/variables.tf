variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of prod vms to create"
  type        = number
  default     = 3
}

variable "ami_id" {
  description = "AMI ID for the OS image"
  type        = string
}

variable "key_name" {
  description = "Name of the aws key pair for ssh access"
  type        = string
}

variable "project_name" {
  description = "Used to tag and name all resources"
  type        = string
  default     = "devops-lab"
}

variable "tailscale_authkey" {
  description = "Tailscale auth key for automatic node registration"
  type        = string
  sensitive   = true
}


