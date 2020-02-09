provider "google" {
  project     = "${var.project_name}"
  region      = "${var.location}"
  credentials = "${file("/tmp/.gcp/credentials.json")}"
}

terraform {
  required_version = "0.11.13"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-polkadot-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "polkadot_subnet" {
  name          = "polkadot-subnetwork"
  ip_cidr_range = "10.100.10.0/27"
  region        = "${var.subnet_location}"
  network       = "${google_compute_network.vpc_network.self_link}"

  depends_on = ["google_compute_network.vpc_network"]
}

resource "google_compute_instance" "polkadot_vm" {
  name         = "polkadot-vm"
  machine_type = "n1-standard-1"
  zone         = "${var.location}"

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = "vpc-polkadot-network"
    subnetwork = "polkadot-subnetwork"

    access_config {
      // Ephemeral IP
    }
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "groupadd -r polkadot",
  #     "useradd -m -r -g polkadot polkadot",
  #     "usermod -aG sudo polkadot",
  #   ]
  # }

  metadata = {
    ssh-keys = "polkadot:${file(var.pub_key_path)}"
  }
  depends_on = ["google_compute_subnetwork.polkadot_subnet"]
}

resource "google_compute_firewall" "firewall_ssh" {
  name    = "allow-ssh-from-specified-cidr-range"
  project = "${var.project_name}"
  network = "vpc-polkadot-network"

  allow {
    protocol = "tcp"

    ports = [
      "22",
    ]
  }

  source_ranges = [
    "${var.cidr_allowed}",
  ]
}
