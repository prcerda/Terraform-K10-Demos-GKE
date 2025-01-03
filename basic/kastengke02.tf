## Kasten namespace
resource "kubernetes_namespace" "kastenio_gke02" {
  provider   = kubernetes.gke02
  depends_on = [module.gke02,kubernetes_storage_class.storage_class_02]
  metadata {
    name = "kasten-io"
  }
}

## Kasten Helm
resource "helm_release" "k10_gke02" {
  provider   = helm.gke02
  depends_on = [kubernetes_namespace.kastenio_gke02]  
  name = "k10"
  namespace = kubernetes_namespace.kastenio_gke02.metadata.0.name
  repository = "https://charts.kasten.io/"
  chart      = "k10"
  
  set {
    name  = "externalGateway.create"
    value = true
  }

  set {
    name  = "secrets.googleApiKey"
    value = google_service_account_key.sakey.private_key
  }

  set {
    name  = "auth.basicAuth.enabled"
    value = true
  } 

  set {
    name  = "auth.basicAuth.htpasswd"
    value = "admin:${htpasswd_password.hash.apr1}"
  } 
}

## Getting Kasten LB Address
data "kubernetes_service_v1" "gateway-ext_gke02" {
  provider   = kubernetes.gke02
  depends_on = [helm_release.k10_gke02]
  metadata {
    name = "gateway-ext"
    namespace = "kasten-io"
  }
}

## Accepting EULA
resource "kubernetes_config_map" "eula_gke02" {
  provider   = kubernetes.gke02
  depends_on = [helm_release.k10_gke02]
  metadata {
    name = "k10-eula-info"
    namespace = "kasten-io"
  }
  data = {
    accepted = "true"
    company  = "Veeam"
    email = var.owner_gke
  }
}

## Kasten GCS Location Profile
resource "helm_release" "gcs-locprofile02" {
  provider   = helm.gke02
  depends_on = [helm_release.k10_gke02]
  name = "${var.cluster_name01}-gcs-locprofile"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "gcs-locprofile"  
  
  set {
    name  = "K10Location.bucketname"
    value = google_storage_bucket.repository.name
  }

  set {
    name  = "K10Location.clustername"
    value = var.cluster_name01
  }
  
  set {
    name  = "K10Location.projectid"
    value = var.project
  }

  set {
    name  = "K10Location.gcekey"
    value = google_service_account_key.sakey.private_key
  }

  set {
    name  = "K10Location.region"
    value = var.region01
  }      
}

## Kasten K10 Policy Preset
resource "helm_release" "k10-config-gke02" {
  provider   = helm.gke02
  depends_on = [helm_release.k10_gke02]
  name = "${var.cluster_name02}-k10-config"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "k10-config"  
  
  set {
    name  = "bucketname"
    value = google_storage_bucket.repository.name
  }

  set {
    name  = "clustername"
    value = var.cluster_name01
  }
}

## Kasten K10 - TransformSet
resource "helm_release" "k10-TransformSet-gke02" {
  provider   = helm.gke02
  depends_on = [helm_release.k10_gke02]
  name = "${var.cluster_name02}-k10-transformset"
  namespace = "kasten-io"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "k10-transformset-sc"  
  
  set {
    name  = "storageclass"
    value = "gke02-storage-class"
  }
}