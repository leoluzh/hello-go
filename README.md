# hello-go

Servidor HTTP "Hello World!" em Go, containerizado com Docker ou Podman e Docker Compose / podman-compose.

## Pré-requisitos

- [Go 1.22+](https://go.dev/dl/) *(apenas para desenvolvimento local)*
- **Docker** ou **Podman** *(o Makefile detecta automaticamente)*
- **Docker Compose** ou **podman-compose**
- [Make](https://www.gnu.org/software/make/)

## Estrutura

```
hello-go/
├── main.go             # Servidor HTTP (porta 8080)
├── go.mod              # Módulo Go
├── Dockerfile          # Multi-stage build (builder + scratch)
├── docker-compose.yml  # Orquestração dos serviços
├── .dockerignore
├── Makefile            # Automação de tarefas
└── README.md
```

## Quickstart

```bash
# Sobe a aplicação (Docker ou Podman detectado automaticamente)
make up

# Testa o endpoint
make ping
# Hello World!

# Para os serviços
make down
```

## Runtime de container

O Makefile **detecta automaticamente** se Docker ou Podman está disponível.  
Você também pode forçar o runtime via variável:

```bash
make container-build RUNTIME=podman
make up              RUNTIME=docker
```

## Comandos disponíveis

### Desenvolvimento local

| Comando | Descrição |
|---|---|
| `make run` | Executa a aplicação localmente (`go run`) |
| `make build` | Compila o binário em `bin/hello-go` |
| `make clean` | Remove binários e artefatos locais |

### Qualidade de código

| Comando | Descrição |
|---|---|
| `make fmt` | Formata o código com `gofmt` |
| `make vet` | Executa `go vet` |
| `make lint` | Executa `golangci-lint` *(requer instalação)* |
| `make test` | Roda os testes com `-v` |
| `make test-cover` | Testes + relatório de cobertura HTML |
| `make check` | Pipeline completo: `fmt` + `vet` + `test` |

### Container — agnóstico (Docker ou Podman)

Usam o runtime detectado automaticamente ou definido via `RUNTIME=`.

| Comando | Descrição |
|---|---|
| `make container-build` | Build da imagem |
| `make container-run` | Executa o container em foreground |
| `make container-run-detach` | Executa o container em background |
| `make container-stop` | Para e remove o container |
| `make container-push` | Publica a imagem no registry |
| `make container-clean` | Remove a imagem local |
| `make container-inspect` | Inspeciona o container em execução |
| `make container-shell` | Abre shell no container em execução |

### Docker — atalhos explícitos

| Comando | Descrição |
|---|---|
| `make docker-build` | Build da imagem com Docker |
| `make docker-run` | Executa o container com Docker |
| `make docker-stop` | Para e remove o container com Docker |
| `make docker-push` | Publica a imagem com Docker |
| `make docker-clean` | Remove a imagem local com Docker |

### Podman — atalhos explícitos

| Comando | Descrição |
|---|---|
| `make podman-build` | Build da imagem com Podman |
| `make podman-run` | Executa o container com Podman |
| `make podman-run-detach` | Executa o container em background com Podman |
| `make podman-stop` | Para e remove o container com Podman |
| `make podman-push` | Publica a imagem com Podman |
| `make podman-clean` | Remove a imagem local com Podman |
| `make podman-generate-systemd` | Gera unit systemd para o container |
| `make podman-pod-create` | Cria um pod com a porta exposta |
| `make podman-pod-run` | Executa o container dentro do pod |
| `make podman-pod-stop` | Para e remove o pod |

### Compose (Docker Compose ou podman-compose)

| Comando | Descrição |
|---|---|
| `make up` | Build + sobe em foreground |
| `make up-detach` | Build + sobe em background |
| `make down` | Para e remove os serviços |
| `make down-volumes` | Para os serviços e remove volumes |
| `make logs` | Exibe logs em tempo real |
| `make ps` | Lista containers em execução |
| `make restart` | Reinicia os serviços |

### Utilitários

| Comando | Descrição |
|---|---|
| `make ping` | Testa o endpoint `localhost:8080` |
| `make tidy` | Executa `go mod tidy` |
| `make deps` | Baixa dependências do projeto |
| `make info` | Exibe runtime detectado e informações do projeto |
| `make help` | Lista todos os comandos disponíveis |

## Publicar no Docker Hub

### Variáveis

| Variável | Descrição | Padrão |
|---|---|---|
| `DOCKERHUB_USER` | Usuário do Docker Hub | *(obrigatório)* |
| `DOCKERHUB_PASS` | Senha / Access Token *(opcional — usa login interativo se omitido)* | — |
| `TAG` | Tag da imagem | `latest` |

> **Recomendado:** use um [Access Token](https://hub.docker.com/settings/security) em vez da senha.

### Fluxo completo (runtime auto-detectado)

```bash
# 1. Login
make dockerhub-login DOCKERHUB_USER=meuusuario

# 2. Build + push (tag latest)
make dockerhub-build-push DOCKERHUB_USER=meuusuario

# 3. Release com versão + atualiza latest
make dockerhub-release DOCKERHUB_USER=meuusuario TAG=v1.0.0

# 4. Logout
make dockerhub-logout
```

### Com senha via variável de ambiente

```bash
export DOCKERHUB_USER=meuusuario
export DOCKERHUB_PASS=meu-access-token

make dockerhub-build-push
make dockerhub-release TAG=v1.0.0
```

### Comandos Docker Hub — agnósticos

| Comando | Descrição |
|---|---|
| `make dockerhub-login` | Login no Docker Hub `[docker\|podman]` |
| `make dockerhub-logout` | Logout do Docker Hub `[docker\|podman]` |
| `make dockerhub-build` | Build com tag `usuario/app:tag` `[docker\|podman]` |
| `make dockerhub-tag` | Tag da imagem local para o Docker Hub `[docker\|podman]` |
| `make dockerhub-push` | Tag + push para o Docker Hub `[docker\|podman]` |
| `make dockerhub-build-push` | Build + tag + push em um único comando `[docker\|podman]` |
| `make dockerhub-release` | Build + push com `TAG` + atualiza `latest` `[docker\|podman]` |

### Comandos Docker Hub — Docker explícito

| Comando | Descrição |
|---|---|
| `make docker-dockerhub-login` | Login no Docker Hub com Docker |
| `make docker-dockerhub-build-push` | Build + push com Docker |
| `make docker-dockerhub-release` | Build + push com `TAG` + `latest` com Docker |

### Comandos Docker Hub — Podman explícito

| Comando | Descrição |
|---|---|
| `make podman-dockerhub-login` | Login no Docker Hub com Podman |
| `make podman-dockerhub-build-push` | Build + push com Podman |
| `make podman-dockerhub-release` | Build + push com `TAG` + `latest` com Podman |

## Dockerfile

O build utiliza estratégia **multi-stage**:

1. **builder** — compila o binário estático com `golang:1.22-alpine`
2. **runtime** — copia apenas o binário para uma imagem `scratch`

Resultado: imagem final com ~5 MB, sem sistema operacional ou dependências desnecessárias.  
Compatível com Docker e Podman sem alterações.

## Endpoint

| Método | Path | Resposta |
|---|---|---|
| `GET` | `/` | `Hello World!` |
