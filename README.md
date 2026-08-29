# Task Manager

Gerenciador de Tarefas (Task Manager) com Next.js 14 e PostgreSQL.

> Esta cópia do repositório já inclui `terraform/` (k3d + Helm +
> observabilidade) e `.github/workflows/ci.yml` (CI/CD). Veja
> [`terraform/README.md`](./terraform/README.md) para o passo a passo
> completo da atividade avaliativa.

## Demonstração

![Task Manager UI](https://via.placeholder.com/800x500?text=Task+Manager+UI)

## Funcionalidades

- **CRUD completo** de tarefas (Create, Read, Update, Delete)
- **Status das tarefas**: pendente, em-andamento, concluída
- **Prioridades**: baixa, média, alta
- **Dashboard**: estatísticas e filtros
- **API REST**: endpoints para integração
- **Health check**: endpoint para monitoramento

## Stack Tecnológica

- **Frontend**: Next.js 14 (App Router), Tailwind CSS
- **Backend**: Next.js API Routes
- **Banco de dados**: PostgreSQL 15
- **Containerização**: Docker, Docker Compose
- **Testes**: Jest

## Estrutura do Projeto

```
task-manager/
├── app/              # App Next.js (App Router)
│   ├── api/          # API Routes
│   ├── layout.js     # Layout raiz
│   ├── page.js       # Página principal (UI)
│   └── globals.css   # Estilos globais Tailwind
├── lib/              # Funções de banco de dados
│   ├── db.js         # Pool PostgreSQL
│   └── dbConfig.js   # Configuração de conexão
├── tests/            # Testes Jest para API
├── Dockerfile        # Build da imagem Docker
├── docker-compose.yml # Ambiente local com Docker Compose
├── next.config.js    # Config Next.js
├── tailwind.config.js # Config Tailwind CSS
└── package.json      # Dependências
```

## Instalação e Execução Local

### Pré-requisitos

- Docker e Docker Compose
- Node.js 20+ (opcional, para desenvolvimento local sem Docker)

### Com Docker Compose (Recomendado)

```bash
# Iniciar containers
docker compose up -d

# Acessar a aplicação
open http://localhost:3000

# Verificar health check
curl http://localhost:3000/api/health

# Se precisar resetar o banco de dados
docker compose down -v
docker compose up -d
```

### Desenvolvimento Local

```bash
# Instalar dependências
npm install

# Criar arquivo .env (baseado em .env.example)
cp .env.example .env

# Executar migrations e iniciar servidor
npm run dev
```

## API REST

### Endpoints

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/tasks` | Listar todas as tarefas |
| GET | `/api/tasks/:id` | Buscar tarefa por ID |
| POST | `/api/tasks` | Criar nova tarefa |
| PUT | `/api/tasks/:id` | Atualizar tarefa |
| DELETE | `/api/tasks/:id` | Deletar tarefa |
| GET | `/api/health` | Health check |

### Exemplo de Request

```bash
# Criar tarefa
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Minha tarefa","description":"Descrição","priority":"alta","status":"pendente"}'

# Listar tarefas
curl http://localhost:3000/api/tasks
```

## Testes

```bash
# Antes de rodar testes, iniciar o servidor
npm run dev &

# Rodar testes
npm test
```

> Nota: Os testes precisam que o servidor esteja rodando em `http://localhost:3000`

## Docker

### Build da Imagem

```bash
docker build -t task-manager .
```

### Executar com Docker

```bash
docker run -p 3000:3000 task-manager
```

## Kubernetes, Terraform, CI/CD e Observabilidade

- **`k8s/`**: manifests brutos de referência (ConfigMap, Deployment,
  Service) para `kubectl apply -f k8s/`.
- **`terraform/`**: provisiona um cluster k3d local, sobe a aplicação
  (+ Postgres) e instala Prometheus, Grafana, Loki e Promtail via Helm,
  com um dashboard do Grafana já publicado. Passo a passo completo em
  [`terraform/README.md`](./terraform/README.md).
- **`.github/workflows/ci.yml`**: testa a aplicação contra um Postgres
  de serviço e builda (e opcionalmente publica) a imagem Docker.

## Licença

MIT
