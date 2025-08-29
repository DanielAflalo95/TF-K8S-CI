terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32" # recent stable release
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}
