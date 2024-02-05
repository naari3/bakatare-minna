provider "google" {
  project = local.project_id
  region  = "us-central1"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.15.0"
    }
  }
  required_version = ">= 1.6.0"
  backend "gcs" {
    bucket = "bakatare-minecraft-tfstate"
    prefix = "terraform/state"
  }
}
