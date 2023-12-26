locals {
  project_id                   = "bakatare-minecraft"
  region                       = "us-central1"
  zone                         = "us-central1-a"
  terraform_service_account_id = "tf-exec"
  terraform_service_account    = "${local.terraform_service_account_id}@${local.project_id}.iam.gserviceaccount.com"
}
