provider "google" {
  project     = local.project_id
  region      = "us-central1"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 5.10.0"
    }
  }
  backend "gcs" {
    bucket = "bakatare-minecraft-tfstate"
    prefix = "terraform/state"
  }
}
