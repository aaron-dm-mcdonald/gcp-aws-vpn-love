# Creates a Classic (non-HA) VPN gateway in GCP, bound to a specific VPC network
# resource "google_compute_vpn_gateway" "this" {
#    name    = var.name
#    network = data.google_compute_network.network.id  # GCP VPC to attach to
# }

# Creates the first VPN tunnel to AWS, establishing IPSec 
# resource "google_compute_vpn_tunnel" "tunnel1" {
#   name                    = "${var.name}-tunnel1"
#   peer_ip                 = aws_vpn_connection.this.tunnel1_address  # AWS side public IP
#   shared_secret           = aws_vpn_connection.this.tunnel1_preshared_key  # Shared key for IPSec
#   target_vpn_gateway      = google_compute_vpn_gateway.this.id
#   ike_version             = 1  # Specifies IKEv1
#   local_traffic_selector  = [ "0.0.0.0/0" ]  # What GCP sends over VPN
#   remote_traffic_selector = [ "0.0.0.0/0" ]  # What is allowed from the peer side

#   depends_on = [
#    google_compute_forwarding_rule.esp,
#    google_compute_forwarding_rule.udp500,
#    google_compute_forwarding_rule.udp4500,
#    google_compute_vpn_gateway.this,
#  ]
# }

# Creates the second tunnel for redundancy (AWS VGW always provides 2 tunnels)
# resource "google_compute_vpn_tunnel" "tunnel2" {
#   name                    = "${var.name}-tunnel2"
#   peer_ip                 = aws_vpn_connection.this.tunnel2_address
#   shared_secret           = aws_vpn_connection.this.tunnel2_preshared_key
#   target_vpn_gateway      = google_compute_vpn_gateway.this.id
#   ike_version             = 1
#   local_traffic_selector  = [ "0.0.0.0/0" ]
#   remote_traffic_selector = [ "0.0.0.0/0" ]

#   depends_on = [
#    google_compute_forwarding_rule.esp,
#    google_compute_forwarding_rule.udp500,
#    google_compute_forwarding_rule.udp4500,
#    google_compute_vpn_gateway.this,
#  ]
# }

# Enables ESP protocol forwarding to the VPN gateway (used by IPSec for encryption)
# resource "google_compute_forwarding_rule" "esp" {
#   name        = "${var.name}-esp"
#   ip_protocol = "ESP"  # Protocol 50, used by IPSec
#   ip_address  = google_compute_address.this.address  # Static public IP
#   target      = google_compute_vpn_gateway.this.id
# }

# Enables UDP 500 forwarding (for IKE negotiations in IPSec)
# resource "google_compute_forwarding_rule" "udp500" {
#   name        = "${var.name}-udp500"
#   ip_protocol = "UDP"
#   port_range  = "500"
#   ip_address  = google_compute_address.this.address
#   target      = google_compute_vpn_gateway.this.id
# }

# Enables UDP 4500 forwarding (for NAT-T for IPSec.... whatever that is)
# resource "google_compute_forwarding_rule" "udp4500" {
#   name        = "${var.name}-udp4500"
#   ip_protocol = "UDP"
#   port_range  = "4500"
#   ip_address  = google_compute_address.this.address
#   target      = google_compute_vpn_gateway.this.id
# }

# Creates a custom route in GCP that sends traffic to the AWS CIDR over the VPN tunnel
# resource "google_compute_route" "this" {
#   name       = "${var.name}-route"
#   network    = google_compute_network.network.name  # VPC to apply route in
#   dest_range = aws_vpc.this.cidr_block  # Destination CIDR (AWS side)
#   priority   = 1000

#   next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id  # Send traffic through tunnel1
# }

# Opens firewall access in GCP for all protocols *from the AWS CIDR range*
# resource "google_compute_firewall" "this" {
#   name    = "${var.name}"
#   network = google_compute_network.network.name

#   allow {
#     protocol = "all"  # Allow all traffic
#   }

#   priority = 1000
#   source_ranges = [ aws_vpc.this.cidr_block ]  # AWS VPC CIDR
# }
