# Não existe um provider Terraform oficial e maduro para o k3d, então o
# padrão adotado aqui (comum em labs com k3d/kind) é fazer o Terraform
# orquestrar a CLI do k3d via local-exec. O null_resource abaixo:
#   1. cria o cluster k3d (se ainda não existir);
#   2. escreve o kubeconfig do cluster em um arquivo local, usado pelos
#      providers kubernetes/helm (ver providers.tf);
#   3. no `terraform destroy`, apaga o cluster inteiro.

resource "null_resource" "k3d_cluster" {
  triggers = {
    cluster_name = var.cluster_name
    agents       = var.k3d_agents
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail

      if k3d cluster list | awk '{print $1}' | grep -qx "${var.cluster_name}"; then
        echo "Cluster '${var.cluster_name}' já existe, pulando criação."
      else
        k3d cluster create "${var.cluster_name}" \
          --agents ${var.k3d_agents} \
          --wait
      fi

      mkdir -p "$(dirname "${var.kubeconfig_path}")"
      k3d kubeconfig write "${var.cluster_name}" --output "${var.kubeconfig_path}"
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = "k3d cluster delete \"${self.triggers.cluster_name}\" || true"
  }
}
