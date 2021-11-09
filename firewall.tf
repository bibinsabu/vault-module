# Add the firewall rules to access vault UI
resource "google_compute_firewall" "ssh_firewall" {
  name          = "vault-firewall"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network-tag}"]
  allow {
    protocol = "tcp"
    ports    = ["22", "8200", "8201"]
  }
}