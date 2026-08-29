# Constrói a imagem da aplicação a partir do Dockerfile na raiz do repo
# (um nível acima da pasta terraform/) e a importa para dentro dos nós do
# k3d com `k3d image import`, para que o cluster local não precise puxar
# a imagem de nenhum registry.
#
# Os triggers usam hash de conteúdo (Dockerfile + código-fonte da app),
# não um timestamp: assim, um `terraform plan` rodado logo após o
# `apply` (sem mudanças no código) fica limpo, e o build/import só roda
# de novo quando algo realmente muda.

locals {
  app_source_files = sort(concat(
    fileset("${path.module}/..", "app/**"),
    fileset("${path.module}/..", "lib/**"),
    fileset("${path.module}/..", "public/**"),
  ))

  app_source_hash = sha1(join("", [
    for f in local.app_source_files : filesha1("${path.module}/../${f}")
  ]))
}

resource "null_resource" "app_image" {
  triggers = {
    dockerfile_hash   = filesha1("${path.module}/../Dockerfile")
    package_json_hash = filesha1("${path.module}/../package.json")
    source_hash       = local.app_source_hash
    image_name        = var.app_image_name
    cluster_name      = var.cluster_name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      docker build -t "${var.app_image_name}" "${path.module}/.."
      k3d image import "${var.app_image_name}" -c "${var.cluster_name}"
    EOT
  }

  depends_on = [null_resource.k3d_cluster]
}
