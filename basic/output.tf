
output "gke_cluster_name" {
  value = " "
}
output "gke_cluster_name_01" {
  value = module.gke01.name
}
output "gke_cluster_name_02" {
  value = module.gke02.name
}

output "app_demo_urls" {
  value = " "
}
output "app_pacman_url" {
  description = "Pacman URL"
  value = "http://${data.kubernetes_service_v1.pacman.status.0.load_balancer.0.ingress.0.ip}"  
}
output "app_k10app_url" {
  description = "K10App URL"
  value = "http://${data.kubernetes_service_v1.k10app.status.0.load_balancer.0.ingress.0.ip}"  
}

output "k10_connection_data" {
  value = " "
}
output "k10url_gke01" {
  description = "Kasten K10 URL"
  value = "http://${data.kubernetes_service_v1.gateway-ext_gke01.status.0.load_balancer.0.ingress.0.ip}/k10/"
}
output "k10url_gke02" {
  description = "Kasten K10 URL"
  value = "http://${data.kubernetes_service_v1.gateway-ext_gke02.status.0.load_balancer.0.ingress.0.ip}/k10/"
}
output "k10_username" {
  value = "admin"
}
output "k10_password" {
  value = var.admin_password
}

output "kubeconfig" {
  value = " "
}
output "kubeconfig_gke01" {
  description = "Configure kubeconfig to access this cluster"
  value       = "gcloud container clusters get-credentials ${module.gke01.name} --region ${var.az01[0]}"
}
output "kubeconfig_gke02" {
  description = "Configure kubeconfig to access this cluster"
  value       = "gcloud container clusters get-credentials ${module.gke02.name} --region ${var.az02[0]}"
}

output "kubeconfig_endpoint01" {
  value     = module.gke01.endpoint
  sensitive = true
}

output "kubeconfig_ca01" {
  value     = module.gke01.ca_certificate
  sensitive = true
}
output "kubeconfig_endpoint02" {
  value     = module.gke02.endpoint
  sensitive = true
}

output "kubeconfig_ca02" {
  value     = module.gke02.ca_certificate
  sensitive = true
}


output "multicluster-blob" {
  value = " "
}
output "multicluster_global_gc_bucket_name" {
  description = "GCS Bucket name - Global"
  value = google_storage_bucket.repository_global.name
  sensitive = true
}

output "multicluster_global_gc_service_key" {
  description = "GCS Bucket - GCP Service Key"
  value = google_service_account_key.sakey.private_key
  sensitive = true
}

output "multicluster_global_gc_region" {
  description = "GCS Bucket - Region"
  value = var.region01
  sensitive = true
}

output "multicluster_global_gc_projectid" {
  description = "GCS Bucket - Project ID"
  value = var.project
  sensitive = true
}

