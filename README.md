# hello-go

[![CI](https://github.com/leoluzh/hello-go/actions/workflows/ci.yml/badge.svg)](https://github.com/leoluzh/hello-go/actions)
[![Release Please](https://github.com/leoluzh/hello-go/actions/workflows/release-please.yml/badge.svg)](https://github.com/leoluzh/hello-go/actions)
[![Publish GHCR](https://github.com/leoluzh/hello-go/actions/workflows/publish.yml/badge.svg)](https://github.com/leoluzh/hello-go/actions)
[![Release Binaries](https://github.com/leoluzh/hello-go/actions/workflows/release-binaries.yml/badge.svg)](https://github.com/leoluzh/hello-go/actions)
[![CodeQL](https://github.com/leoluzh/hello-go/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/leoluzh/hello-go/actions)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/go-1.22+-00ADD8?logo=go)](go.mod)
[![Docker](https://img.shields.io/badge/docker-ready-2496ED?logo=docker)](Dockerfile)

Servidor HTTP "Hello World!" em Go, containerizado com Docker ou Podman e Docker Compose / podman-compose.

## Downloads & Imagens

### 📦 Binários — GitHub Releases

Os binários compilados para cada plataforma estão disponíveis na página de [Releases](https://github.com/leoluzh/hello-go/releases):

| Plataforma | Arquivo |
|---|---|
| Linux x86_64 | `hello-go_linux_amd64.tar.gz` |
| Linux ARM64 | `hello-go_linux_arm64.tar.gz` |
| macOS x86_64 | `hello-go_darwin_amd64.tar.gz` |
| macOS Apple Silicon | `hello-go_darwin_arm64.tar.gz` |
| Windows x86_64 | `hello-go_windows_amd64.zip` |

> Acesse a [última release](https://github.com/leoluzh/hello-go/releases/latest) para baixar a versão mais recente.

### 🐳 Imagem Docker — GitHub Container Registry (GHCR)

```bash
# última versão estável
docker pull ghcr.io/leoluzh/hello-go:latest

# versão específica
docker pull ghcr.io/leoluzh/hello-go:1.0.0

# branch main (builds de desenvolvimento)
docker pull ghcr.io/leoluzh/hello-go:main
```

🔗 Pacote no GHCR: [ghcr.io/leoluzh/hello-go](https://github.com/leoluzh/hello-go/pkgs/container/hello-go)

### 🐋 Imagem Docker — Docker Hub

```bash
# última versão estável
docker pull leoluzh/hello-go:latest

# versão específica
docker pull leoluzh/hello-go:1.0.0
```

🔗 Repositório no Docker Hub: [hub.docker.com/r/leoluzh/hello-go](https://hub.docker.com/r/leoluzh/hello-go)

### ▶️ Executar sem clonar o repositório

```bash
# Docker — GHCR
docker run -p 8080:8080 ghcr.io/leoluzh/hello-go:latest

# Docker — Docker Hub
docker run -p 8080:8080 leoluzh/hello-go:latest

# Podman — GHCR
podman run -p 8080:8080 ghcr.io/leoluzh/hello-go:latest

# Testar
curl http://localhost:8080
# Hello World!

curl http://localhost:8080/version
# version=1.0.0 commit=abc1234 built=2026-06-29T...
```

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

## Conventional Commits & CHANGELOG

Este projeto usa [Conventional Commits](https://www.conventionalcommits.org/pt-br/) para gerar o `CHANGELOG.md` e as versões automaticamente via Release Please.

### Formato

```
<tipo>(<escopo opcional>): <descrição>

<corpo opcional>

<rodapé opcional>
```

### Tipos e impacto na versão

| Tipo | Descrição | Versão |
|---|---|---|
| `feat` | nova funcionalidade | MINOR `1.x.0` |
| `fix` | correção de bug | PATCH `1.0.x` |
| `perf` | melhoria de performance | PATCH |
| `refactor` | refatoração sem mudança de comportamento | — |
| `docs` | apenas documentação | — |
| `chore` | manutenção, deps, configuração | — |
| `ci` | mudanças em CI/CD | — |
| `test` | testes | — |
| `feat!` ou `BREAKING CHANGE:` | quebra de compatibilidade | MAJOR `x.0.0` |

### Exemplos

```bash
git commit -m "feat: adiciona endpoint /health"
git commit -m "fix(http): corrige timeout na leitura do body"
git commit -m "docs: atualiza README com exemplos de uso"
git commit -m "feat!: remove suporte ao Go 1.20"

# Com corpo e rodapé
git commit -m "feat(auth): adiciona middleware JWT

Implementa validação de token JWT no handler principal.

Closes #42"
```

### Configurar template de commit localmente

```bash
git config commit.template .github/commit-template.txt
```

### Fluxo automático

```
commits na main (feat/fix/...)
    → Release Please analisa os commits
        → abre PR com CHANGELOG.md atualizado + bump de versão
            → merge do PR
                → cria tag v1.x.x + GitHub Release
                    → publica imagem no GHCR e Docker Hub
```

## GitHub Actions & GHCR

### Workflows disponíveis

| Arquivo | Trigger | Descrição |
|---|---|---|
| `ci.yml` | push/PR em `main` e `feature/**` | Lint, testes, build do binário e validação da imagem |
| `publish.yml` | push em `main` ou tag `v*.*.*` | Publica imagem no **GHCR** (ghcr.io) |
| `publish-dockerhub.yml` | tag `v*.*.*` ou `workflow_dispatch` | Publica imagem no **Docker Hub** |

### Secrets necessários no repositório

Acesse **Settings → Secrets and variables → Actions** e adicione:

| Secret | Descrição |
|---|---|
| `DOCKERHUB_USERNAME` | Usuário do Docker Hub |
| `DOCKERHUB_TOKEN` | Access Token do Docker Hub |

> O `GITHUB_TOKEN` para o GHCR é gerado automaticamente pelo Actions — não precisa configurar.

### Tags geradas automaticamente

**GHCR (`publish.yml`):**
```
ghcr.io/usuario/hello-go:main          # push na branch main
ghcr.io/usuario/hello-go:1.2.3         # tag v1.2.3
ghcr.io/usuario/hello-go:1.2           # major.minor
ghcr.io/usuario/hello-go:latest        # junto com semver tag
ghcr.io/usuario/hello-go:sha-abc1234   # SHA do commit
ghcr.io/usuario/hello-go:pr-42         # pull request
```

**Docker Hub (`publish-dockerhub.yml`):**
```
usuario/hello-go:1.2.3    # tag v1.2.3
usuario/hello-go:1.2      # major.minor
usuario/hello-go:latest   # junto com semver tag
```

### Fluxo de release

```bash
git tag v1.0.0
git push origin v1.0.0
# → dispara publish.yml (GHCR) e publish-dockerhub.yml (Docker Hub) automaticamente
```

### Publicar manualmente via Makefile

```bash
# GHCR
make ghcr-release GITHUB_USER=meuusuario GITHUB_TOKEN=ghp_xxx TAG=v1.0.0

# Docker Hub
make dockerhub-release DOCKERHUB_USER=meuusuario TAG=v1.0.0
```

### Comandos GHCR — agnósticos

| Comando | Descrição |
|---|---|
| `make ghcr-login` | Login no GHCR `[docker\|podman]` |
| `make ghcr-logout` | Logout do GHCR `[docker\|podman]` |
| `make ghcr-build` | Build com tag `ghcr.io/usuario/app:tag` `[docker\|podman]` |
| `make ghcr-tag` | Tag da imagem local para o GHCR `[docker\|podman]` |
| `make ghcr-push` | Tag + push para o GHCR `[docker\|podman]` |
| `make ghcr-build-push` | Build + push em um único comando `[docker\|podman]` |
| `make ghcr-release` | Build + push com `TAG` + atualiza `latest` `[docker\|podman]` |

### Comandos GHCR — Docker e Podman explícitos

| Comando | Descrição |
|---|---|
| `make docker-ghcr-login` | Login no GHCR com Docker |
| `make docker-ghcr-build-push` | Build + push com Docker |
| `make docker-ghcr-release` | Build + push com `TAG` + `latest` com Docker |
| `make podman-ghcr-login` | Login no GHCR com Podman |
| `make podman-ghcr-build-push` | Build + push com Podman |
| `make podman-ghcr-release` | Build + push com `TAG` + `latest` com Podman |

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