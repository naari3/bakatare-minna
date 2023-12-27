resource "google_compute_disk" "minecraft" {
  name = "minecraft"
  type = "pd-standard"
  zone = local.zone
  size = 50
}
