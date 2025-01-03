# Service Account for K10 for GCP
resource "google_service_account" "k10-sa" {
  account_id   = "sa-k10-hol-${local.saString}"
  display_name = "sa-k10-hol-${local.saString}"
}

#Creating SA Key for K10
resource "google_service_account_key" "sakey" {
  service_account_id = google_service_account.k10-sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

#Assigning IAM Roles to K10 Service Account
resource "google_project_iam_member" "kasten-default" {
  project = var.project
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.k10-sa.email}"
}

resource "google_project_iam_member" "kasten-locprofile" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.k10-sa.email}"
}
