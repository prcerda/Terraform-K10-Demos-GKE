# Define Terraform provider
terraform {
  required_version = "~> 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.25.0, < 6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.12"   
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
    }    
  }
  provider_meta "google" {
  module_name = "blueprints/terraform/terraform-google-kubernetes-engine/v31.0.0"
  }  
}

provider "htpasswd" {
}
resource "htpasswd_password" "hash" {
  password = var.admin_password
}

# Define GCP provider
provider "google" {
  project     = var.project
  region      = var.region01
  zone        = var.az01[0]
}

data "google_client_config" "default" {
}

# Configure the Google provider 01
provider "helm" {
  alias = "gke01"
  kubernetes {  
    host                   = "https://${module.gke01.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke01.ca_certificate)
  }
}

provider "kubernetes" {
  alias = "gke01"
    host                   = "https://${module.gke01.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke01.ca_certificate)
}

# Configure the Google provider 02
provider "helm" {
  alias = "gke02"
  kubernetes {  
    host                   = "https://${module.gke02.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke02.ca_certificate)
  }
}

provider "kubernetes" {
  alias = "gke02"
    host                   = "https://${module.gke02.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke02.ca_certificate)
}

