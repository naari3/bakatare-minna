locals {
  machine_type = "t2a-standard-3"
}

# プリエンプティブVMの作成
resource "google_compute_instance" "minecraft" {
  name         = "minecraft"
  machine_type = local.machine_type
  zone         = local.zone
  tags         = ["minecraft"]

  metadata_startup_script = <<EOF
# 新しいディスクを確認し、存在する場合はフォーマットしてマウント
DISK="/dev/sdb"
MOUNT_POINT="/mnt/mydisk"
FS_TYPE="ext4"
if ls $${DISK} 1> /dev/null 2>&1; then
  echo "フォーマットとマウントを開始: $${DISK}"
  # フォーマット
  mkfs -t $${FS_TYPE} $${DISK}
  # マウントポイントを作成
  mkdir -p $${MOUNT_POINT}
  # ファイルシステムをマウント
  mount -t $${FS_TYPE} $${DISK} $${MOUNT_POINT}
  # 再起動時に自動でマウントするようにfstabに追記
  echo "$${DISK} $${MOUNT_POINT} $${FS_TYPE} defaults 0 2" | tee -a /etc/fstab
  # スクリプトの実行をマーク
  touch /var/tmp/disk_setup_done
  docker run -d -p 25565:25565 -e EULA=TRUE -e VERSION=1.20.1 -v /var/minecraft:/data --name mc -e TYPE=FORGE -e FORGEVERSION=47.2.0 -e MEMORY=2G --rm=true itzg/minecraft-server:latest;
else
    echo "$${DISK} が存在しません"
fi
EOF

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

  allow_stopping_for_update = true
}
