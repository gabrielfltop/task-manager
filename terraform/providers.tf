# O kubeconfig referenciado aqui só passa a existir depois que o
# null_resource.k3d_cluster roda (veja k3d_cluster.tf). Por isso, todo
# recurso kubernetes_* / helm_release neste projeto declara
# `depends_on = [null_resource.k3d_cluster]`, garantindo que o cluster
# já exista antes de qualquer chamada à API do Kubernetes.

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}
