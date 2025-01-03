# Define Terraform provider
terraform {
  required_version = "~> 1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4"   
    }
  }
}

data "terraform_remote_state" "gke01" {
  backend = "local"

  config = {
    path = "../basic/terraform.tfstate"
  }
}


# Retrieve an access token as the Terraform runner
data "google_client_config" "default" {}

# Configure the Google provider 01
provider "kubernetes" {
  alias = "gke01"
    host                   = "https://${data.terraform_remote_state.gke01.outputs.kubeconfig_endpoint01}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.terraform_remote_state.gke01.outputs.kubeconfig_ca01)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
}

# Configure the Google provider 01
provider "kubernetes" {
  alias = "gke02"
    host                   = "https://${data.terraform_remote_state.gke01.outputs.kubeconfig_endpoint02}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.terraform_remote_state.gke01.outputs.kubeconfig_ca02)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
}
