# Núcleo obrigatório da atividade: kube-prometheus-stack (Prometheus +
# Grafana + kube-state-metrics + node-exporter, com os dashboards padrão
# do Kubernetes já inclusos) e loki-stack (Loki + Promtail), instalados
# via Helm a partir do Terraform.

resource "helm_release" "kube_prometheus_stack" {
  name       = var.grafana_release_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.kube_prometheus_stack_chart_version # null = última versão

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values/kube-prometheus-stack-values.yaml")
  ]

  depends_on = [
    null_resource.k3d_cluster,
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "loki_stack" {
  name       = var.loki_release_name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.loki_stack_chart_version # null = última versão

  timeout = 600
  wait    = true

  values = [
    file("${path.module}/values/loki-stack-values.yaml")
  ]

  depends_on = [
    null_resource.k3d_cluster,
    kubernetes_namespace.monitoring,
  ]
}
