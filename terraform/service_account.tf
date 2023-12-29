resource "google_service_account" "bakatare" {
  account_id   = "bakatare"
  display_name = "bakatare"
}

resource "google_project_iam_member" "instance_admin" {
  project = local.project_id
  role    = "roles/compute.instanceAdmin"
  member  = google_service_account.bakatare.member
}

resource "google_project_iam_member" "service_account_user" {
  project = local.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = google_service_account.bakatare.member
}
