##################################################################################
# VARIABLES
##################################################################################

variable "region" {
  default = "us-east1"
}
variable "project" {
  default = "prime-keel-109719"
}
variable "network_name1"{}
variable "network_name2"{}
variable "network_name3"{}

##################################################################################
# PROVIDERS
##################################################################################

provider "google" {
 credentials = file("D:\\Learning\\Terraform\\prime-keel-109719-a36ce534feaa.json")
 project     = var.project
 region      = var.region
}

##################################################################################
# DATA Sources
##################################################################################

data "google_compute_zones" "available" {
}

##################################################################################
# RESOURCES
##################################################################################


resource "google_compute_network" "vpc_network" {
  name = var.network_name1
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "vpc_network1" {
  name = var.network_name2
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "vpc_network2" {
  name = var.network_name3
  auto_create_subnetworks = "false"
}
resource "google_compute_subnetwork" "mgmt_network" {
  name          = "mgmt-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_subnetwork" "control_network" {
  name          = "control-subnetwork"
  ip_cidr_range = "10.3.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network1.name
}

resource "google_compute_subnetwork" "wan_network" {
  name          = "wan-subnetwork"
  ip_cidr_range = "10.4.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network2.name
}

resource "google_compute_instance" "default" {

  name         = "testinstance"
  machine_type = "n1-standard-4"
  zone         = "us-east1-b"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork= google_compute_subnetwork.mgmt_network.name

    access_config {
    }
  }

  network_interface {
    network = google_compute_network.vpc_network1.name
    subnetwork=google_compute_subnetwork.control_network.name 
  }
  
  network_interface {
    network = google_compute_network.vpc_network2.name
    subnetwork=google_compute_subnetwork.wan_network.name
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

}