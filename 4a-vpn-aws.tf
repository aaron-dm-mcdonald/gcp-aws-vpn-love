# Defines the VPN customer gateway representing the peer VPN gateway/interface** (ie GCP VPN Gateway)
resource "aws_customer_gateway" "this" {
  bgp_asn    = 65000                               #  used for routing
  ip_address = google_compute_address.this.address # Public IP of the peer VPN gateway (GCP side)
  type       = "ipsec.1"                           # Type of VPN connection (IPSec)

  tags = {
    Name = var.name
  }

  depends_on = [google_compute_address.this] # Wait until GCP IP is allocated
}

# Creates the AWS VPN gateway (VGW), which is attached to the AWS VPC
resource "aws_vpn_gateway" "this" {
  vpc_id = module.aws_network.vpc_id # Attaches to the specified AWS VPC

  tags = {
    Name = var.name
  }
}

# Propagates routes from the VGW to a route table (so subnets using this table can route via the VPN)
resource "aws_vpn_gateway_route_propagation" "public" {
  vpn_gateway_id = aws_vpn_gateway.this.id                  # Link to VGW
  route_table_id = module.aws_network.public_route_table_id # Target route table 
}

# Propagates routes from the VGW to a route table (so subnets using this table can route via the VPN)
resource "aws_vpn_gateway_route_propagation" "private" {
  vpn_gateway_id = aws_vpn_gateway.this.id                   # Link to VGW
  route_table_id = module.aws_network.private_route_table_id # Target route table 
}

# Creates the VPN connection between AWS VGW and the Customer Gateway (ie GCP VPN Gateway)
resource "aws_vpn_connection" "this" {
  vpn_gateway_id       = aws_vpn_gateway.this.id        # Link to AWS VGW
  customer_gateway_id  = aws_customer_gateway.this.id   # Link to peer gateway
  type                 = aws_customer_gateway.this.type # Should be "ipsec.1"
  static_routes_only   = true                           # Not using BGP; static routes will be manually added
  tunnel1_ike_versions = ["ikev1"]                      # Encryption protocol for the IPSec tunnel

  tags = {
    Name = var.name
  }
}

# Defines a static route over the VPN to reach the peer network (e.g., GCP subnet)
resource "aws_vpn_connection_route" "this" {
  vpn_connection_id      = aws_vpn_connection.this.id # The VPN connection created above
  destination_cidr_block = var.gcp_config.subnet_cidr # The peer CIDR block (GCP)
}

# Security group allowing all inbound traffic *from the GCP subnet*, and allowing all outbound traffic
# Typically applied to EC2 instances communicating over VPN
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "${var.name} allow all traffic"
  vpc_id      = module.aws_network.vpc_id # Attach to AWS VPC

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                         # All protocols
    cidr_blocks = [var.gcp_config.subnet_cidr] # Allow from GCP subnet only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic (any CIDR from VPC)
  }

  tags = {
    Name = "${var.name}-sg"
  }
}
