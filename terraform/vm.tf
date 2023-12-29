locals {
  machine_type = "t2a-standard-4"
}

# プリエンプティブVMの作成
resource "google_compute_instance" "minecraft" {
  name         = "minecraft"
  machine_type = local.machine_type
  zone         = local.zone
  tags         = ["minecraft"]

  metadata_startup_script = <<EOF
# 新しいディスクを確認し、存在する場合はフォーマットしてマウントする!!!
DISK="/dev/disk/by-id/google-minecraft"
MOUNT_POINT="/mnt/stateful_partition/minecraft"
FS_TYPE="ext4"

# マウントポイントを作成
mkdir -p "$${MOUNT_POINT}"

# ディスクがフォーマットされているか確認
if ! blkid "$${DISK}" > /dev/null 2>&1; then
    echo "Formatting disk $${DISK}"
    # ディスクをフォーマット
    mkfs.ext4 -F "$${DISK}"
fi

# ディスクをマウント
echo "Mounting disk $${DISK} at $${MOUNT_POINT}"
mount -t "$${FS_TYPE}" "$${DISK}" "$${MOUNT_POINT}"

# 自動マウントの設定
if ! grep -qs "$${MOUNT_POINT} " /etc/fstab; then
    echo "Adding $${MOUNT_POINT} to /etc/fstab"
    echo "$${DISK} $${MOUNT_POINT} $${FS_TYPE} defaults 0 2" >> /etc/fstab
fi

apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu focal stable"
apt-get install -y docker-ce
apt-get install docker-compose-plugin
systemctl start docker
systemctl enable docker

git clone https://github.com/naari3/bakatare-minna ~/bakatare-minna
cd ~/bakatare-minna/docker
docker compose up -d
EOF

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts-arm64"
      size  = 10
      type  = "pd-standard"
    }
  }

  attached_disk {
    source      = google_compute_disk.world_data.id
    mode        = "READ_WRITE"
    device_name = "minecraft"
  }

  network_interface {
    network = google_compute_network.minecraft.name
    #trivy:ignore:AVD-GCP-0031
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
