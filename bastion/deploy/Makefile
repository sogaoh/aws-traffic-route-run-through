.PHONY: help up upb down prune build tag push buildx-setup buildx-build ecr-login ecr-pub-login

help:
	cat Makefile

up:
	docker compose up -d
upb:
	docker compose up -d --build
down:
	docker compose down --remove-orphans
prune:
	docker system prune --volumes


# ECR build -> push
#ARCH := --platform linux/amd64
ARCH := --platform linux/arm64
APPLICATION := bastion
NOW := $(shell date "+%Y%m%d-%H%M")
BLDARG_TZ := --build-arg=TZ=Asia/Tokyo
BLDARG_SLEEP_SECONDS := --build-arg=SLEEP_SECONDS=900
AWS_ACCOUNT_ID ?= $(shell echo $$AWS_ACCOUNT_ID)
AWS_REGION := ap-northeast-1
TAG := latest
DOCKERFILE := Dockerfile
PLATFORMS := linux/amd64,linux/arm64
BUILDER_NAME := multiarch-builder

build:
	docker build $(ARCH) --no-cache -t $(APPLICATION):$(TAG) -f ./container/$(DOCKERFILE) $(BLDARG_TZ) $(BLDARG_SLEEP_SECONDS) .
tag:
	docker tag $(APPLICATION):$(TAG) "$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APPLICATION):$(TAG)"
push:
	docker push "$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APPLICATION):$(TAG)"

buildx-setup:
	@if ! docker buildx inspect $(BUILDER_NAME) > /dev/null 2>&1; then \
		echo "Creating new builder: $(BUILDER_NAME)"; \
		docker buildx create --use --name $(BUILDER_NAME); \
	else \
		echo "Builder $(BUILDER_NAME) already exists, using it"; \
		docker buildx use $(BUILDER_NAME); \
	fi

buildx-build: buildx-setup
	docker buildx build \
		--builder $(BUILDER_NAME) \
		--platform $(PLATFORMS) \
		--no-cache \
		--provenance=false \
		-t $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APPLICATION):$(TAG) \
		-f ./container/$(DOCKERFILE) \
		$(BLDARG_TZ) \
		$(BLDARG_SLEEP_SECONDS) \
		--push \
		.


ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
ecr-pub-login:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
