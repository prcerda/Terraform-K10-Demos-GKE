#Storage Account in GCS
resource "google_storage_bucket" "repository" {
  name          = "gcs-hol-${local.saString}"
  location      = var.region01
  storage_class = "STANDARD"
  force_destroy = true
  uniform_bucket_level_access = true
  public_access_prevention = "enforced"
  labels = {
    owner = var.owner_gke
    activity = var.activity
  }
}

# Create storage account Global
resource "google_storage_bucket" "repository_global" {
  name          = "gcs-hol-global-${local.saString}"
  location      = var.region01
  storage_class = "STANDARD"
  force_destroy = true
  uniform_bucket_level_access = true
  public_access_prevention = "enforced"
  labels = {
    owner = var.owner_gke
    activity = var.activity
  }
}

