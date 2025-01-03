## Network components
resource "google_compute_network" "vpc_network_02" {
  project                 = var.project
  name                    = "vpc-${var.cluster_name02}-${local.saString}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-02" {
  name          = "subnet-hol-02-${local.saString}"
  ip_cidr_range = var.subnet_cidr_block_ipv4
  region        = var.region02
  network       = google_compute_network.vpc_network_02.id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
  }  
  secondary_ip_range = [
    {
      range_name    = "ip-range-pods-${local.saString}"
      ip_cidr_range = "192.168.0.0/18"
    },
    {
      range_name    = "ip-range-svc-${local.saString}"
      ip_cidr_range = "192.168.64.0/18"
    }
  ]
}


# GKE cluster
module "gke02" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 31.0"
  project_id                        = var.project
  name                              = "hol-${var.cluster_name02}-${local.saString}"
  regional                          = false
  region                            = var.region02
  zones                             = var.az02
  network                           = google_compute_network.vpc_network_02.name
  subnetwork                        = google_compute_subnetwork.subnet-02.name
  ip_range_pods                     = "ip-range-pods-${local.saString}"
  ip_range_services                 = "ip-range-svc-${local.saString}"
  create_service_account            = true
  service_account_name              = "sa-${var.cluster_name02}-${local.saString}"
  deletion_protection               = false
  remove_default_node_pool          = true
  disable_legacy_metadata_endpoints = true
  http_load_balancing               = true
  network_policy                    = false
  horizontal_pod_autoscaling        = true
  filestore_csi_driver              = true
  dns_cache                         = false  
  # kubernetes_version                = "1.29"
  cluster_resource_labels = {
    owner = var.owner_gke
    activity = var.activity
  }  

  node_pools = [
    {
      name                        = "pool-01-${var.cluster_name02}"
      machine_type                = var.machine_type
      node_locations              = var.az02[0]
      autoscaling                 = true
      initial_node_count          = var.gke_num_nodes
      disk_type                   = "pd-standard"
      auto_upgrade                = true
      auto_repair                 = true
      preemptible                 = false

    },
  ]

  node_pools_labels = {
    all = {
      owner = var.owner_gke
      activity = var.activity
    }
  }  
}

# Storage Class Region 2
resource "kubernetes_storage_class" "storage_class_02" {
provider   = kubernetes.gke02
depends_on = [module.gke02]
  metadata {
    name = "gke02-storage-class"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "pd-balanced"
  }
}

## GCE Disk VolumeSnapshotClass
resource "helm_release" "gc-volumesnapclass-02" {
  provider   = helm.gke02
  depends_on = [module.gke02]
  name = "gc-volumesnapclass"
  create_namespace = true
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "gc-volumesnapclass"  
}


