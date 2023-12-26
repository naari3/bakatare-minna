locals {
  machine_type = "t2a-standard-2"
}

# プリエンプティブVMの作成
resource "google_compute_instance" "minecraft" {
  name         = "minecraft"
  machine_type = local.machine_type
  zone         = local.zone
  tags         = ["minecraft"]

  metadata_startup_script = "docker run -d -p 25565:25565 -e EULA=TRUE -e VERSION=1.20.1 -v /var/minecraft:/data --name mc -e TYPE=FORGE -e FORGEVERSION=47.2.0 -e MEMORY=2G --rm=true itzg/minecraft-server:latest;"

  boot_disk {
    auto_delete = false
    source      = google_compute_disk.minecraft.self_link
  }

  network_interface {
    network = google_compute_network.minecraft.name
    access_config {
      nat_ip = google_compute_address.minecraft.address
    }
  }

  service_account {
    email  = google_service_account.bakatare.email
    scopes = ["userinfo-email", "https://www.googleapis.com/auth/cloud-platform"]
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
