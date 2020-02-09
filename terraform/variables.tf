# Global variables

variable "location" {
  description = "The GCP region where the resources should exist"
  default     = "us-east1-b"
}

variable "project_name" {
  description = "the project ID found at console"
  default     = "polkadot-267705"
}
