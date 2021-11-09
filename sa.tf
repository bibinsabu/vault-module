resource "google_service_account" "vault_kms_service_account" {
  account_id   = "vault-gcpkms"
  display_name = "Vault KMS for auto-unseal"
}

resource "google_project_iam_binding" "project" {
  project = "${var.gcloud-project}"
  role    = "roles/editor"
    members = [
      "serviceAccount:${google_service_account.vault_kms_service_account.email}"
    ]
  }
