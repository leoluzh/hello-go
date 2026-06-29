# hello-go

Servidor HTTP "Hello World!" em Go, containerizado com Docker e Docker Compose.

## Pré-requisitos

- [Go 1.22+](https://go.dev/dl/) *(apenas para desenvolvimento local)*
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)
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
# Sobe a aplicação com Docker Compose
make up

# Testa o endpoint
make ping
# Hello World!

# Para os serviços
make down
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

### Docker

| Comando | Descrição |
|---|---|
| `make docker-build` | Build da imagem Docker |
| `make docker-run` | Executa o container diretamente |
| `make docker-stop` | Para e remove o container |
| `make docker-push` | Publica a imagem no registry |
| `make docker-clean` | Remove a imagem local |

### Docker Compose

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
| `make info` | Exibe informações do projeto |
| `make help` | Lista todos os comandos disponíveis |

## Dockerfile

O build utiliza estratégia **multi-stage**:

1. **builder** — compila o binário estático com `golang:1.22-alpine`
2. **runtime** — copia apenas o binário para uma imagem `scratch`

Resultado: imagem final com ~5 MB, sem sistema operacional ou dependências desnecessárias.

## Endpoint

| Método | Path | Resposta |
|---|---|---|
| `GET` | `/` | `Hello World!` |
