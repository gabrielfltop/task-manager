terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# O kubeconfig só existe depois que o null_resource.k3d_cluster roda.
# Referenciar seu atributo aqui força o Terraform a esperar o cluster
# subir antes de tentar configurar estes providers.
provider "kubernetes" {
  config_path = null_resource.k3d_cluster.id != "" ? local.kubeconfig_path : local.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = null_resource.k3d_cluster.id != "" ? local.kubeconfig_path : local.kubeconfig_path
  }
}
