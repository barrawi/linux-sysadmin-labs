output "instance_public_ips" {
  description = "Public IP addresses of production instances"
  value       = aws_instance.prod[*].public_ip
}

output "instance_hostnames" {
  description = "Hostnames of production instances"
  value       = aws_instance.prod[*].tags.Name
}
