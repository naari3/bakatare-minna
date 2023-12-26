resource "google_compute_disk" "minecraft" {
  name  = "minecraft"
  type  = "pd-standard"
  zone  = local.zone
  image = "https://www.googleapis.com/compute/v1/projects/cos-cloud/global/images/cos-arm64-stable-109-17800-66-43"
}
