resource "google_dns_managed_zone" "bakatare" {
  name     = "bakatare-zone"
  dns_name = "bakatare.naari3.net."
}

resource "google_dns_record_set" "a" {
  name         = "bakatare.naari3.net."
  type         = "A"
  ttl          = 5
  managed_zone = google_dns_managed_zone.bakatare.name
  rrdatas      = [google_compute_address.minecraft.address]
}
