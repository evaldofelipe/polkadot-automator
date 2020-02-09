# Global variables

variable "location" {
  description = "The GCP region where the resources should exist"
  default     = "us-east1-b"
}

variable "subnet_location" {
  description = "The GCP region where the subnet will be create"
  default     = "us-east1"
}

variable "project_name" {
  description = "the project ID found at console"
  default     = "polkadot-267705"
}

variable "cidr_allowed" {
  description = "Allowed CIDR for ssh conections"
  default     = "0.0.0.0/0"
}

variable "pub_key_path" {
  description = "your ssh key inside the container"
  default     = "/home/polkadot/.ssh/id_rsa.pub"
}
