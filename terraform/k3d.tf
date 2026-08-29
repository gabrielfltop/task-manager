locals {
  kubeconfig_path = "${path.module}/kubeconfig"
}

# Sobe o cluster k3d, mapeia o NodePort do task-manager para o host
# e escreve um kubeconfig isolado (não mexe no seu ~/.kube/config).
# Cada provisioner roda um único comando, sem "set -e" nem heredoc,
# para funcionar igual no cmd.exe do Windows, no PowerShell e no bash.
resource "null_resource" "k3d_cluster" {
  triggers = {
    cluster_name = var.cluster_name
    node_port    = var.node_port
  }

  provisioner "local-exec" {
    command = "k3d cluster create ${var.cluster_name} --agents 1 -p ${var.node_port}:${var.node_port}@server:0 --kubeconfig-update-default=false --kubeconfig-switch-context=false --wait"
  }

  provisioner "local-exec" {
    command = "k3d kubeconfig get ${var.cluster_name} > ${local.kubeconfig_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.cluster_name}"
  }
}

# Build da imagem do task-manager e import direto no containerd do k3d
# (sem precisar de registry externo).
resource "null_resource" "task_manager_image" {
  depends_on = [null_resource.k3d_cluster]

  triggers = {
    dockerfile_hash = filesha256("${var.task_manager_context_path}/Dockerfile")
    cluster_name    = var.cluster_name
    image           = var.task_manager_image
  }

  provisioner "local-exec" {
    command = "docker build --progress=plain -t ${var.task_manager_image} ${var.task_manager_context_path}"
  }

  provisioner "local-exec" {
    command = "k3d image import ${var.task_manager_image} -c ${var.cluster_name}"
  }
}
