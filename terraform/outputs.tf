output "kubeconfig_path" {
  description = "Caminho do kubeconfig gerado para o cluster k3d"
  value       = var.kubeconfig_path
}

output "export_kubeconfig" {
  description = "Comando para usar este cluster com kubectl/k9s diretamente"
  value       = "export KUBECONFIG=$(terraform output -raw kubeconfig_path)"
}

output "access_app" {
  description = "Como abrir a aplicação no navegador"
  value       = "kubectl port-forward svc/task-manager-service 3000:3000 -n ${var.app_namespace} --kubeconfig ${var.kubeconfig_path}   # depois abra http://localhost:3000"
}

output "access_grafana" {
  description = "Como abrir o Grafana no navegador"
  value       = "kubectl port-forward svc/${var.grafana_release_name}-grafana 3000:80 -n ${var.monitoring_namespace} --kubeconfig ${var.kubeconfig_path}   # depois abra http://localhost:3000 (login: admin / prom-operator)"
}
