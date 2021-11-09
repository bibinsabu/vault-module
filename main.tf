

data "template_file" "default" {
  count    = length(var.vault_server_names)
  template = file("${path.module}/templates/userdata-vault-server.tpl")
  vars = {
    tpl_vault_project    = var.gcloud-project,
    tpl_vault_node_name  = "${var.vault_server_names[count.index]}",
    tpl_vault_path       = "/opt/${var.vault_server_names[count.index]}",
    tpl_vault_zip_file   = var.vault_zip_file,
    tpl_vault_tag        = var.network-tag,
    tpl_vault_key_ring   = var.key_ring,
    tpl_vault_crypto_key = var.crypto_key
  }
}

resource "google_compute_instance" "vault" {
  name                    = "vault-server-${var.vault_server_names[count.index]}"
  count                   = length(var.vault_server_names)
  machine_type            = "${var.machine_type}"
  zone                    = var.gcloud-zone[count.index]
  tags                    = ["${var.network-tag}"]
  metadata_startup_script = data.template_file.default[count.index].rendered

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "default"
    network_ip = var.vault_server_private_ips[count.index]

    access_config {
      # Ephemeral IP
    }
  }

  allow_stopping_for_update = true

  # Service account with Cloud KMS roles for the Compute Instance
  service_account {
    email  = google_service_account.vault_kms_service_account.email
    scopes = ["cloud-platform", "compute-rw", "userinfo-email", "storage-ro"]
  }
}

