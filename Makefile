# ============================================================
#  hello-go — Makefile
# ============================================================

APP_NAME      := hello-go
IMAGE_NAME    := $(APP_NAME)
PORT          := 8080
GO_FILES      := $(shell find . -name '*.go' -not -path './vendor/*')

# ------------------------------------------------------------
# Docker Hub
# Uso: make dockerhub-push DOCKERHUB_USER=meuusuario
#      make dockerhub-push DOCKERHUB_USER=meuusuario TAG=v1.2.0
# ------------------------------------------------------------
DOCKERHUB_USER    ?= $(shell echo $$DOCKERHUB_USER)
DOCKERHUB_PASS    ?= $(shell echo $$DOCKERHUB_PASS)
TAG               ?= latest
DOCKERHUB_IMAGE   := $(DOCKERHUB_USER)/$(APP_NAME):$(TAG)

# ------------------------------------------------------------
# Auto-detecção de runtime de container (Docker ou Podman)
# Pode ser forçado: make up-detach RUNTIME=podman
# ------------------------------------------------------------
RUNTIME ?= $(shell \
	if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then \
		echo docker; \
	elif command -v podman >/dev/null 2>&1; then \
		echo podman; \
	else \
		echo docker; \
	fi)

# Compose: docker compose (plugin) ou podman-compose
COMPOSE ?= $(shell \
	if [ "$(RUNTIME)" = "podman" ]; then \
		echo "podman-compose"; \
	else \
		echo "docker compose"; \
	fi)

.DEFAULT_GOAL := help

# ------------------------------------------------------------
# Help
# ------------------------------------------------------------
.PHONY: help
help: ## Exibe esta mensagem de ajuda
	@echo "Runtime detectado: \033[33m$(RUNTIME)\033[0m  |  Compose: \033[33m$(COMPOSE)\033[0m"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

# ------------------------------------------------------------
# Desenvolvimento local (sem container)
# ------------------------------------------------------------
.PHONY: run
run: ## Executa a aplicação localmente
	go run ./...

.PHONY: build
build: ## Compila o binário local (./bin/hello-go)
	@mkdir -p bin
	CGO_ENABLED=0 go build -o bin/$(APP_NAME) .
	@echo "Binário gerado em bin/$(APP_NAME)"

.PHONY: clean
clean: ## Remove binários e artefatos locais
	@rm -rf bin/ coverage.out coverage.html
	@echo "Artefatos removidos"

# ------------------------------------------------------------
# Qualidade de código
# ------------------------------------------------------------
.PHONY: fmt
fmt: ## Formata o código com gofmt
	gofmt -w $(GO_FILES)

.PHONY: vet
vet: ## Executa go vet
	go vet ./...

.PHONY: lint
lint: ## Executa golangci-lint (requer instalação prévia)
	golangci-lint run ./...

.PHONY: test
test: ## Executa os testes
	go test -v ./...

.PHONY: test-cover
test-cover: ## Executa testes com relatório de cobertura HTML
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Relatório gerado em coverage.html"

.PHONY: check
check: fmt vet test ## Pipeline de qualidade: fmt + vet + test

# ------------------------------------------------------------
# Container (Docker ou Podman — usa RUNTIME detectado/definido)
# ------------------------------------------------------------
.PHONY: container-build
container-build: ## Build da imagem [docker|podman]
	$(RUNTIME) build -t $(IMAGE_NAME) .

.PHONY: container-run
container-run: ## Executa o container em foreground [docker|podman]
	$(RUNTIME) run --rm -p $(PORT):$(PORT) --name $(APP_NAME) $(IMAGE_NAME)

.PHONY: container-run-detach
container-run-detach: ## Executa o container em background [docker|podman]
	$(RUNTIME) run -d -p $(PORT):$(PORT) --name $(APP_NAME) $(IMAGE_NAME)

.PHONY: container-stop
container-stop: ## Para e remove o container [docker|podman]
	$(RUNTIME) stop $(APP_NAME) 2>/dev/null || true
	$(RUNTIME) rm   $(APP_NAME) 2>/dev/null || true

.PHONY: container-push
container-push: ## Publica a imagem no registry [docker|podman]
	$(RUNTIME) push $(IMAGE_NAME)

.PHONY: container-clean
container-clean: ## Remove a imagem local [docker|podman]
	$(RUNTIME) rmi $(IMAGE_NAME) 2>/dev/null || true
	@echo "Imagem $(IMAGE_NAME) removida"

.PHONY: container-inspect
container-inspect: ## Inspeciona o container em execução [docker|podman]
	$(RUNTIME) inspect $(APP_NAME)

.PHONY: container-shell
container-shell: ## Abre shell no container em execução [docker|podman]
	$(RUNTIME) exec -it $(APP_NAME) /bin/sh

# ------------------------------------------------------------
# Docker (atalhos explícitos — força RUNTIME=docker)
# ------------------------------------------------------------
.PHONY: docker-build
docker-build: ## Build da imagem com Docker
	docker build -t $(IMAGE_NAME) .

.PHONY: docker-run
docker-run: ## Executa o container com Docker
	docker run --rm -p $(PORT):$(PORT) --name $(APP_NAME) $(IMAGE_NAME)

.PHONY: docker-stop
docker-stop: ## Para e remove o container com Docker
	docker stop $(APP_NAME) 2>/dev/null || true
	docker rm   $(APP_NAME) 2>/dev/null || true

.PHONY: docker-push
docker-push: ## Publica a imagem com Docker
	docker push $(IMAGE_NAME)

.PHONY: docker-clean
docker-clean: ## Remove a imagem local com Docker
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

# ------------------------------------------------------------
# Podman (atalhos explícitos — força RUNTIME=podman)
# ------------------------------------------------------------
.PHONY: podman-build
podman-build: ## Build da imagem com Podman
	podman build -t $(IMAGE_NAME) .

.PHONY: podman-run
podman-run: ## Executa o container com Podman
	podman run --rm -p $(PORT):$(PORT) --name $(APP_NAME) $(IMAGE_NAME)

.PHONY: podman-run-detach
podman-run-detach: ## Executa o container em background com Podman
	podman run -d -p $(PORT):$(PORT) --name $(APP_NAME) $(IMAGE_NAME)

.PHONY: podman-stop
podman-stop: ## Para e remove o container com Podman
	podman stop $(APP_NAME) 2>/dev/null || true
	podman rm   $(APP_NAME) 2>/dev/null || true

.PHONY: podman-push
podman-push: ## Publica a imagem com Podman
	podman push $(IMAGE_NAME)

.PHONY: podman-clean
podman-clean: ## Remove a imagem local com Podman
	podman rmi $(IMAGE_NAME) 2>/dev/null || true

.PHONY: podman-generate-systemd
podman-generate-systemd: ## Gera unit systemd para o container (Podman)
	@mkdir -p systemd
	podman generate systemd --name $(APP_NAME) --files --new
	@mv container-$(APP_NAME).service systemd/ 2>/dev/null || true
	@echo "Unit gerada em systemd/container-$(APP_NAME).service"

.PHONY: podman-pod-create
podman-pod-create: ## Cria um pod Podman com a porta exposta
	podman pod create --name $(APP_NAME)-pod -p $(PORT):$(PORT)

.PHONY: podman-pod-run
podman-pod-run: ## Executa o container dentro do pod
	podman run -d --pod $(APP_NAME)-pod --name $(APP_NAME) $(IMAGE_NAME)

.PHONY: podman-pod-stop
podman-pod-stop: ## Para e remove o pod
	podman pod stop $(APP_NAME)-pod 2>/dev/null || true
	podman pod rm   $(APP_NAME)-pod 2>/dev/null || true

# ------------------------------------------------------------
# Docker Hub — agnóstico (usa RUNTIME detectado/definido)
# ------------------------------------------------------------
.PHONY: dockerhub-check-user
dockerhub-check-user:
	@[ -n "$(DOCKERHUB_USER)" ] || { echo "\033[31mErro: defina DOCKERHUB_USER (ex: make dockerhub-push DOCKERHUB_USER=meuusuario)\033[0m"; exit 1; }

.PHONY: dockerhub-login
dockerhub-login: dockerhub-check-user ## Login no Docker Hub [docker|podman]
	@if [ -n "$(DOCKERHUB_PASS)" ]; then \
		echo "$(DOCKERHUB_PASS)" | $(RUNTIME) login docker.io -u $(DOCKERHUB_USER) --password-stdin; \
	else \
		$(RUNTIME) login docker.io -u $(DOCKERHUB_USER); \
	fi

.PHONY: dockerhub-logout
dockerhub-logout: ## Logout do Docker Hub [docker|podman]
	$(RUNTIME) logout docker.io

.PHONY: dockerhub-build
dockerhub-build: dockerhub-check-user ## Build da imagem já com a tag do Docker Hub [docker|podman]
	$(RUNTIME) build -t $(DOCKERHUB_IMAGE) .
	@echo "Imagem criada: $(DOCKERHUB_IMAGE)"

.PHONY: dockerhub-tag
dockerhub-tag: dockerhub-check-user ## Tag da imagem local para o Docker Hub [docker|podman]
	$(RUNTIME) tag $(IMAGE_NAME) $(DOCKERHUB_IMAGE)
	@echo "Tag aplicada: $(IMAGE_NAME) → $(DOCKERHUB_IMAGE)"

.PHONY: dockerhub-push
dockerhub-push: dockerhub-check-user dockerhub-tag ## Tag + push para o Docker Hub [docker|podman]
	$(RUNTIME) push $(DOCKERHUB_IMAGE)
	@echo "Publicado: https://hub.docker.com/r/$(DOCKERHUB_USER)/$(APP_NAME)"

.PHONY: dockerhub-build-push
dockerhub-build-push: dockerhub-check-user ## Build + tag + push em um único comando [docker|podman]
	$(MAKE) dockerhub-build DOCKERHUB_USER=$(DOCKERHUB_USER) TAG=$(TAG)
	$(MAKE) dockerhub-push  DOCKERHUB_USER=$(DOCKERHUB_USER) TAG=$(TAG)

.PHONY: dockerhub-release
dockerhub-release: dockerhub-check-user ## Publica com TAG e também atualiza 'latest' [docker|podman]
	@[ "$(TAG)" != "latest" ] || { echo "\033[31mErro: defina TAG (ex: make dockerhub-release TAG=v1.0.0 DOCKERHUB_USER=...)\033[0m"; exit 1; }
	$(MAKE) dockerhub-build-push DOCKERHUB_USER=$(DOCKERHUB_USER) TAG=$(TAG)
	$(RUNTIME) tag $(DOCKERHUB_IMAGE) $(DOCKERHUB_USER)/$(APP_NAME):latest
	$(RUNTIME) push $(DOCKERHUB_USER)/$(APP_NAME):latest
	@echo "Publicado com TAG=$(TAG) e latest"

# ------------------------------------------------------------
# Docker Hub — Docker explícito
# ------------------------------------------------------------
.PHONY: docker-dockerhub-login
docker-dockerhub-login: dockerhub-check-user ## Login no Docker Hub com Docker
	@if [ -n "$(DOCKERHUB_PASS)" ]; then \
		echo "$(DOCKERHUB_PASS)" | docker login -u $(DOCKERHUB_USER) --password-stdin; \
	else \
		docker login -u $(DOCKERHUB_USER); \
	fi

.PHONY: docker-dockerhub-build-push
docker-dockerhub-build-push: dockerhub-check-user ## Build + push para o Docker Hub com Docker
	docker build -t $(DOCKERHUB_USER)/$(APP_NAME):$(TAG) .
	docker push $(DOCKERHUB_USER)/$(APP_NAME):$(TAG)
	@echo "Publicado: https://hub.docker.com/r/$(DOCKERHUB_USER)/$(APP_NAME)"

.PHONY: docker-dockerhub-release
docker-dockerhub-release: dockerhub-check-user ## Build + push com TAG + atualiza latest com Docker
	@[ "$(TAG)" != "latest" ] || { echo "\033[31mErro: defina TAG (ex: make docker-dockerhub-release TAG=v1.0.0 DOCKERHUB_USER=...)\033[0m"; exit 1; }
	docker build -t $(DOCKERHUB_USER)/$(APP_NAME):$(TAG) .
	docker push $(DOCKERHUB_USER)/$(APP_NAME):$(TAG)
	docker tag  $(DOCKERHUB_USER)/$(APP_NAME):$(TAG) $(DOCKERHUB_USER)/$(APP_NAME):latest
	docker push $(DOCKERHUB_USER)/$(APP_NAME):latest
	@echo "Publicado com TAG=$(TAG) e latest"

# ------------------------------------------------------------
# Docker Hub — Podman explícito
# ------------------------------------------------------------
.PHONY: podman-dockerhub-login
podman-dockerhub-login: dockerhub-check-user ## Login no Docker Hub com Podman
	@if [ -n "$(DOCKERHUB_PASS)" ]; then \
		echo "$(DOCKERHUB_PASS)" | podman login docker.io -u $(DOCKERHUB_USER) --password-stdin; \
	else \
		podman login docker.io -u $(DOCKERHUB_USER); \
	fi

.PHONY: podman-dockerhub-build-push
podman-dockerhub-build-push: dockerhub-check-user ## Build + push para o Docker Hub com Podman
	podman build -t $(DOCKERHUB_USER)/$(APP_NAME):$(TAG) .
	podman push docker.io/$(DOCKERHUB_USER)/$(APP_NAME):$(TAG)
	@echo "Publicado: https://hub.docker.com/r/$(DOCKERHUB_USER)/$(APP_NAME)"

.PHONY: podman-dockerhub-release
podman-dockerhub-release: dockerhub-check-user ## Build + push com TAG + atualiza latest com Podman
	@[ "$(TAG)" != "latest" ] || { echo "\033[31mErro: defina TAG (ex: make podman-dockerhub-release TAG=v1.0.0 DOCKERHUB_USER=...)\033[0m"; exit 1; }
	podman build -t $(DOCKERHUB_USER)/$(APP_NAME):$(TAG) .
	podman push docker.io/$(DOCKERHUB_USER)/$(APP_NAME):$(TAG)
	podman tag  docker.io/$(DOCKERHUB_USER)/$(APP_NAME):$(TAG) docker.io/$(DOCKERHUB_USER)/$(APP_NAME):latest
	podman push docker.io/$(DOCKERHUB_USER)/$(APP_NAME):latest
	@echo "Publicado com TAG=$(TAG) e latest"

# ------------------------------------------------------------
# Compose (Docker Compose ou podman-compose — usa COMPOSE detectado)
# ------------------------------------------------------------
.PHONY: up
up: ## Sobe os serviços em foreground [docker compose|podman-compose]
	$(COMPOSE) up --build

.PHONY: up-detach
up-detach: ## Sobe os serviços em background [docker compose|podman-compose]
	$(COMPOSE) up --build -d

.PHONY: down
down: ## Para e remove os serviços [docker compose|podman-compose]
	$(COMPOSE) down

.PHONY: down-volumes
down-volumes: ## Para serviços e remove volumes [docker compose|podman-compose]
	$(COMPOSE) down -v

.PHONY: logs
logs: ## Exibe logs em tempo real [docker compose|podman-compose]
	$(COMPOSE) logs -f

.PHONY: ps
ps: ## Lista os containers em execução [docker compose|podman-compose]
	$(COMPOSE) ps

.PHONY: restart
restart: down up-detach ## Reinicia os serviços

# ------------------------------------------------------------
# Utilitários
# ------------------------------------------------------------
.PHONY: ping
ping: ## Testa o endpoint da aplicação
	@curl -sf http://localhost:$(PORT) && echo "" || echo "Serviço indisponível em localhost:$(PORT)"

.PHONY: tidy
tidy: ## Executa go mod tidy
	go mod tidy

.PHONY: deps
deps: ## Baixa as dependências do projeto
	go mod download

.PHONY: info
info: ## Exibe informações do projeto e runtime detectado
	@echo "App:     $(APP_NAME)"
	@echo "Image:   $(IMAGE_NAME)"
	@echo "Port:    $(PORT)"
	@echo "Runtime: $(RUNTIME)"
	@echo "Compose: $(COMPOSE)"
	@go version