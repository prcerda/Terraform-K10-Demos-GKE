## Kasten namespace K10 - MultiCluster
resource "kubernetes_namespace" "kastenio-mc" {
  provider   = kubernetes.gke01
  metadata {
    name = "kasten-io-mc"
  }
}

## Kasten K10 - MultiCluster Bootstrap
resource "kubernetes_manifest" "bootstrap_kasten_io_mc" {
  provider   = kubernetes.gke01
  depends_on = [kubernetes_namespace.kastenio-mc]
  manifest = {
    "apiVersion" = "dist.kio.kasten.io/v1alpha1"
    "kind" = "Bootstrap"
    "metadata" = {
      "name" = "bootstrap-primary"
      "namespace" = "kasten-io-mc"
    }
    "spec" = {
      "clusters" = {
        "primary-cluster" = {
          "k10" = {
            "ingress" = {
              "url" = "${data.terraform_remote_state.gke01.outputs.k10url_gke01}"
            }
            "namespace" = "kasten-io"
            "releaseName" = "k10"
          }
          "name" = "k10-hol-primary"
          "primary" = true
        }
      }
    }
  }
}

## Kasten K10 - Multicluster Create Join Token - Primary
resource "kubernetes_secret" "join_token_secret" {
  provider   = kubernetes.gke01
  depends_on = [kubernetes_manifest.bootstrap_kasten_io_mc]   
  metadata {
    generate_name = "join-token-secret-"
    namespace = "kasten-io-mc"
  }
  type = "dist.kio.kasten.io/join-token"
}


## Kasten K10 - Multicluster Use Join Token - Secondary
resource "kubernetes_secret" "join_token_aks" {
  provider   = kubernetes.gke02
  depends_on = [kubernetes_secret.join_token_secret]   
  metadata {
    name = "mc-join"
    namespace = "kasten-io"
  }
  data = {
    token = kubernetes_secret.join_token_secret.data.token
  }  
}

## Kasten K10 - Multicluster Join Secondary Cluster
resource "kubernetes_config_map" "kasten-mc-secondary" {
  provider   = kubernetes.gke02
  metadata {
    name = "mc-join-config"
    namespace = "kasten-io"
  }
  data = {
    cluster-name    = "k10-hol-secondary"
    cluster-ingress = "${data.terraform_remote_state.gke01.outputs.k10url_gke02}"
    primary-ingress = "${data.terraform_remote_state.gke01.outputs.k10url_gke01}"
    allow-insecure-primary-ingress = true
  }
}

## Kasten K10 - Multi-Cluster Admin Role
resource "kubernetes_manifest" "k10clusterrolebinding_mc" {
  provider   = kubernetes.gke01
  manifest = {
    "apiVersion" = "auth.kio.kasten.io/v1alpha1"
    "kind" = "K10ClusterRoleBinding"
    "metadata" = {
      "name" = "admin-all-clusters"
      "namespace" = "kasten-io-mc"
    }
    "spec" = {
      "clusters" = [
        {
          "selector" = ""
        },
      ]
      "k10ClusterRole" = "k10-multi-cluster-admin"
      "subjects" = [
        {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind" = "User"
          "name" = "system:serviceaccount:kasten-io:k10-k10"
        },
      ]
    }
  }
}