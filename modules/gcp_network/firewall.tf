# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall


resource "google_compute_firewall" "ssh" {
  name    = "${google_compute_network.main.name}-allow-lizzo-ssh"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "ping" {
  name    = "${google_compute_network.main.name}-allow-ping"
  network = google_compute_network.main.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}


