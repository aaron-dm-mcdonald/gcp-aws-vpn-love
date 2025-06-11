output "aws_bastion" {
  value =  {
    ssh_command = module.aws_bastion.ssh_command
    ec2_instance_private_ip = module.aws_bastion.private_ip
    ec2_instance_public_ip = module.aws_bastion.public_ip
    }
 
}

output "gcp_bastion" {
  value = {
    ssh_command = module.gcp_bastion.ssh_command
    vm_internal_ip = module.gcp_bastion.internal_ip
    vm_external_ip = module.gcp_bastion.external_ip
    }
}

output "vpn_gateway_ips" {
  description = "Public IPs of AWS VPN tunnels and GCP VPN gateway"

  value = {
    aws_tunnel_1 = aws_vpn_connection.this.tunnel1_address
    aws_tunnel_2 = aws_vpn_connection.this.tunnel2_address
    gcp_gateway  = google_compute_address.this.address
  }
}