# Terraform — k3d + task-manager + Observabilidade

Este diretório provisiona, via Terraform:

1. um cluster Kubernetes local com **k3d**;
2. a aplicação **task-manager** (+ Postgres) rodando nesse cluster;
3. a stack de observabilidade via **Helm**: `kube-prometheus-stack`
   (Prometheus + Grafana + kube-state-metrics + node-exporter) e
   `loki-stack` (Loki + Promtail);
4. um dashboard customizado do Grafana para o namespace `task-manager`,
   carregado automaticamente via ConfigMap + sidecar de dashboards.

## Pré-requisitos (na sua máquina)

- [Docker](https://docs.docker.com/get-docker/) rodando
- [k3d](https://k3d.io/) (`brew install k3d` / veja o site para outras SOs)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5

> Não é preciso instalar o Helm CLI: o provider `helm` do Terraform fala
> direto com a API do Kubernetes.

## Passo a passo

```bash
cd terraform
terraform init
terraform apply
```

O `apply` faz, nesta ordem: cria o cluster k3d → escreve o kubeconfig em
`terraform/.kube/kubeconfig-task-manager.yaml` → cria os namespaces →
builda a imagem da aplicação e importa para o k3d → sobe Postgres e
task-manager → instala kube-prometheus-stack e loki-stack via Helm →
publica o dashboard customizado no Grafana.

Isso pode levar alguns minutos (download dos charts/imagens na primeira
vez). Ao final, o Terraform imprime os outputs com os comandos prontos
para acessar a aplicação e o Grafana.

Para usar `kubectl`/`k9s` apontando para este cluster em qualquer
terminal:

```bash
export KUBECONFIG=$(terraform output -raw kubeconfig_path)
kubectl get pods -A
```

## Deliverables da atividade — como gerar cada print

### 1. Pasta terraform e os arquivos

```bash
ls -la terraform/
```
Print da listagem (tela inteira).

### 2. Saída do `terraform plan` (depois do primeiro `apply`)

Depois que o `terraform apply` acima terminar com sucesso, rode:

```bash
terraform plan
```

Deve mostrar que não há mudanças pendentes (infraestrutura já convergiu
para o estado desejado). Print da saída completa (tela inteira).

### 3. Aplicação rodando no navegador

```bash
kubectl port-forward svc/task-manager-service 3000:3000 -n task-manager \
  --kubeconfig .kube/kubeconfig-task-manager.yaml
```

Abra `http://localhost:3000` no navegador e tire o print (tela inteira,
com a barra de endereço visível). Pare o port-forward (Ctrl+C) antes do
próximo passo, já que ambos usam a porta 3000 local.

### 4. Grafana com um dashboard do Kubernetes aberto

```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring \
  --kubeconfig .kube/kubeconfig-task-manager.yaml
```

Abra `http://localhost:3000`, faça login (`admin` / `prom-operator`, ou
busque a senha com
`kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d`)
e abra:

- **Dashboards → Task Manager - Visão Geral** (o dashboard customizado
  que o Terraform publicou), ou
- qualquer um dos dashboards padrão de Kubernetes que já vêm com o
  chart (ex.: "Kubernetes / Compute Resources / Namespace (Pods)").

Print da tela inteira com o dashboard aberto.

## Encerrando / limpando

```bash
terraform destroy
```

Isso remove todos os recursos do Kubernetes criados pelo Terraform **e**
apaga o cluster k3d inteiro (via `k3d cluster delete`).

## Notas de design

- Não existe um provider Terraform oficial maduro para k3d, então o
  cluster é criado orquestrando a CLI do k3d via `null_resource` +
  `local-exec` (`k3d_cluster.tf`). É o padrão mais comum em labs desse
  tipo.
- A imagem da aplicação é buildada localmente (`docker build`) e
  importada para os nós do k3d com `k3d image import` — não é
  necessário nenhum registry para o cluster local funcionar
  (`image_build.tf`).
- Os manifests originais em `../k8s/` não tinham o Postgres; ele foi
  adicionado em `postgres.tf`, espelhando o `docker-compose.yml` do
  repositório.
- O datasource do Loki no Grafana já vem pré-configurado via
  `values/kube-prometheus-stack-values.yaml` (`additionalDataSources`),
  então não é preciso adicioná-lo manualmente na UI — mas o passo manual
  descrito no material da aula (`URL: http://loki:3100`) também funciona
  se preferir configurá-lo você mesmo.
