variable "cluster_name" {
  description = "Nome do cluster k3d"
  type        = string
  default     = "task-manager-cluster"
}

variable "k3d_agents" {
  description = "Número de nós agentes (workers) do cluster k3d"
  type        = number
  default     = 1
}

variable "kubeconfig_path" {
  description = "Caminho local onde o kubeconfig do cluster k3d será escrito pelo k3d"
  type        = string
  default     = "./.kube/kubeconfig-task-manager.yaml"
}

variable "app_namespace" {
  description = "Namespace Kubernetes da aplicação task-manager"
  type        = string
  default     = "task-manager"
}

variable "monitoring_namespace" {
  description = "Namespace Kubernetes da stack de observabilidade"
  type        = string
  default     = "monitoring"
}

variable "app_image_name" {
  description = "Nome:tag da imagem Docker da aplicação, construída localmente e importada para o k3d"
  type        = string
  default     = "task-manager:v1"
}

variable "app_replicas" {
  description = "Número de réplicas do Deployment da aplicação"
  type        = number
  default     = 2
}

variable "app_node_port" {
  description = "NodePort exposto pelo Service da aplicação"
  type        = number
  default     = 30080
}

variable "postgres_user" {
  description = "Usuário do banco PostgreSQL"
  type        = string
  default     = "admin"
}

variable "postgres_password" {
  description = "Senha do banco PostgreSQL"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "postgres_db" {
  description = "Nome do banco de dados PostgreSQL"
  type        = string
  default     = "task_manager"
}

variable "postgres_storage_size" {
  description = "Tamanho do volume persistente do PostgreSQL"
  type        = string
  default     = "1Gi"
}

# Deixe como null para o Helm usar a versão mais recente disponível do chart.
# Fixe uma versão (ex: "62.7.0") se quiser builds reprodutíveis.
variable "kube_prometheus_stack_chart_version" {
  description = "Versão do chart kube-prometheus-stack (null = mais recente)"
  type        = string
  default     = null
}

variable "loki_stack_chart_version" {
  description = "Versão do chart loki-stack (null = mais recente)"
  type        = string
  default     = null
}

variable "grafana_release_name" {
  description = "Nome do release Helm do kube-prometheus-stack (define o nome do Service do Grafana: <nome>-grafana)"
  type        = string
  default     = "monitoring"
}

variable "loki_release_name" {
  description = "Nome do release Helm do loki-stack (define o nome do Service do Loki: <nome>)"
  type        = string
  default     = "loki"
}
