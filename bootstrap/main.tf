locals {
  github_repository            = "naari3/bakatare-minna"
  project_id                   = "bakatare-minecraft"
  region                       = "us-central1"
  terraform_service_account_id = "tf-exec"
  terraform_service_account    = "${local.terraform_service_account_id}@${local.project_id}.iam.gserviceaccount.com"

  services = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com"
  ])
}

provider "google" {
  project     = local.project_id
  region      = "us-central1"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.22.0"
    }
  }
  backend "gcs" {
    bucket = "bakatare-minecraft-tfstate"
    prefix = "bootstrap-terraform/state"
  }
}

resource "google_project_service" "enable_api" {
  for_each                   = local.services
  project                    = local.project_id
  service                    = each.value
  disable_dependent_services = true
}

resource "google_iam_workload_identity_pool" "bakatare_pool" {
  provider                  = google-beta
  project                   = local.project_id
  workload_identity_pool_id = "bakatare-pool"
  display_name              = "bakatare-pool"
  description               = "GitHub Actions で使用"
}

resource "google_iam_workload_identity_pool_provider" "bakatare_prdr" {
  provider                           = google-beta
  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.bakatare_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "bakatare-prdr"
  display_name                       = "bakatare-prdr"
  description                        = "GitHub Actions で使用"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "terraform_sa" {
  account_id   = local.terraform_service_account_id
  display_name = "terraform_sa"
}

resource "google_project_iam_member" "terraform_sa_owner" {
  project = local.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_service_account_iam_member" "terraform_sa" {
  service_account_id = google_service_account.terraform_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.bakatare_pool.name}/attribute.repository/${local.github_repository}"
}
