output "gcs_bucket_global_name" {
  description = "GCS Bucket name - Global"
  value = data.terraform_remote_state.gke01.outputs.multicluster_global_gc_bucket_name
}

output "gcs_bucket_global_service_key" {
  description = "GCS Bucket Global - GCP Service Key"
  value = nonsensitive(base64decode(data.terraform_remote_state.gke01.outputs.multicluster_global_gc_service_key))

}

output "gcs_bucket_global_region" {
  description = "GCS Bucket Global - Region"
  value = data.terraform_remote_state.gke01.outputs.multicluster_global_gc_region
}

output "gcs_bucket_global_projectid" {
  description = "GCS Bucket Global - Project ID"
  value = data.terraform_remote_state.gke01.outputs.multicluster_global_gc_projectid
}