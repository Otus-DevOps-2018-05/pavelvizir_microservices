provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "docker-host" {
  count        = "${var.node_count}"
  zone         = "${var.zone}"
  name         = "${var.name}-${count.index}"
  machine_type = "${var.machine_type}"
  tags         = ["${var.name}"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  metadata {
    ssh-keys = "${var.user}:${file(var.public_key)}"
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_firewall" "firewall_docker-host" {
  name    = "allow-${var.name}-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292","22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.name}"]
}
