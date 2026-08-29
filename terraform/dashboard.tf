# O sidecar de dashboards do Grafana (habilitado em
# values/kube-prometheus-stack-values.yaml) observa ConfigMaps com o label
# grafana_dashboard = "1" em qualquer namespace e importa o JSON
# automaticamente — sem precisar clicar em "Import" na UI.

resource "kubernetes_config_map" "task_manager_dashboard" {
  metadata {
    name      = "task-manager-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "task-manager-dashboard.json" = file("${path.module}/dashboards/task-manager-dashboard.json")
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
