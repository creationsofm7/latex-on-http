## -------------------------------
## Running Python app ##
## -------------------------------
install:
	poetry install

start:
	poetry run gunicorn --workers=2 --threads=8 --bind=0.0.0.0:8080 app:app

debug:
	poetry run python app.py --verbose --debug


## -------------------------------
## Running cache app ##
## -------------------------------
start-cache:
	poetry run python app_cache.py

debug-cache:
	poetry run python -u app_cache.py --debug

## -------------------------------
## Docker build/images ##
## -------------------------------
docker-pull-yoant-texlive-debian:
	docker pull yoant/docker-texlive:debian

docker-build-tl-distrib-debian:
	docker build -f container/tl-distrib-debian.Dockerfile -t yoant/latexonhttp-tl-distrib:debian .

docker-build-python-debian:
	docker build -f container/python-debian.Dockerfile -t yoant/latexonhttp-python:debian .

docker-build-main:
	docker build -f Dockerfile -t latexonhttp:latest .

docker-build-all-debian: docker-pull-yoant-texlive-debian docker-build-tl-distrib-debian docker-build-python-debian docker-build-main

docker-build-all: docker-build-all-debian

## -------------------------------
## Docker push/images ##
## -------------------------------
docker-push-tl-distrib-debian:
	docker push yoant/latexonhttp-tl-distrib:debian

docker-push-python-debian:
	docker push yoant/latexonhttp-python:debian

## -------------------------------
## ECR push/images ##
## -------------------------------
ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_REGISTRY)

ecr-push-all:
	./container/ecr_push.sh

ecr-push-tl-distrib:
	$(MAKE) ecr-login
	docker tag yoant/latexonhttp-tl-distrib:debian $(ECR_REGISTRY)/$(ECR_REPOSITORY_TL_DISTRIB):debian
	docker tag yoant/latexonhttp-tl-distrib:debian $(ECR_REGISTRY)/$(ECR_REPOSITORY_TL_DISTRIB):latest
	docker push $(ECR_REGISTRY)/$(ECR_REPOSITORY_TL_DISTRIB):debian
	docker push $(ECR_REGISTRY)/$(ECR_REPOSITORY_TL_DISTRIB):latest

ecr-push-python:
	$(MAKE) ecr-login
	docker tag yoant/latexonhttp-python:debian $(ECR_REGISTRY)/$(ECR_REPOSITORY_PYTHON):debian
	docker tag yoant/latexonhttp-python:debian $(ECR_REGISTRY)/$(ECR_REPOSITORY_PYTHON):latest
	docker push $(ECR_REGISTRY)/$(ECR_REPOSITORY_PYTHON):debian
	docker push $(ECR_REGISTRY)/$(ECR_REPOSITORY_PYTHON):latest

ecr-push-main:
	$(MAKE) ecr-login
	docker tag latexonhttp:latest $(ECR_REGISTRY)/$(ECR_REPOSITORY_MAIN):latest
	docker push $(ECR_REGISTRY)/$(ECR_REPOSITORY_MAIN):latest


## -------------------------------
## Docker Compose for dev ##
## -------------------------------
dev:
	docker-compose up

dev-build:
	docker-compose build --no-cache

dev-sh-latex:
	docker-compose exec latex /bin/bash

set-permissions-migrations:
	chown -R $(SUDO_USER):$(SUDO_USER) ./tools/migrations

## -------------------------------
## Tests ##
## -------------------------------
test:
	poetry run pytest -vv

test-x:
	poetry run pytest -vv -x

test-docker-compose: test-docker-compose-start
	sleep 3
	make test
	sleep 2
	make test-docker-compose-stop

test-docker-compose-up:
	docker compose -f docker-compose.test.yml -p latex-on-http-test up

test-docker-compose-bash:
	docker compose -f docker-compose.test.yml -p latex-on-http-test exec -it latex bash

test-docker-compose-start:
	docker compose -f docker-compose.test.yml -p latex-on-http-test up --no-start
	docker compose -f docker-compose.test.yml -p latex-on-http-test start

test-docker-compose-stop:
	docker compose -f docker-compose.test.yml -p latex-on-http-test stop

test-docker-compose-rm:
	docker compose -f docker-compose.test.yml -p latex-on-http-test rm

test-docker-compose-build:
	docker compose -f docker-compose.test.yml -p latex-on-http-test build

test-docker-compose-build-no-cache:
	docker compose -f docker-compose.test.yml -p latex-on-http-test build --no-cache

## -------------------------------
## Code conventions and formatting ##
## -------------------------------
format:
	poetry run black .
