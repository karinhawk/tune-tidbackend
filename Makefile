.PHONY: install local lint lint-fix cfn-lint flake8 black black-fix isort isort-fix bandit safety test test-v build

# GITLAB_TOKEN :=$(if $(CI_JOB_TOKEN),$(CI_JOB_TOKEN),$(NPM_TOKEN))

.ONESHELL:

install:
	poetry install

update:
	poetry update

local: install
	poetry run pre-commit install

lint: flake8 black isort cfn-lint newline-check

lint-fix: black-fix isort-fix

cfn-lint:
	poetry run cfn-lint template.yaml

flake8:
	poetry run flake8

black:
	poetry run black --diff --check --preview .

black-fix:
	poetry run black --preview .

isort:
	poetry run isort --diff --check .

isort-fix:
	poetry run isort .

ruff:
	poetry run ruff check .

ruff-fix:
	poetry run ruff check --fix-only .

bandit:
	poetry run bandit -r src -q -n 3

safety:
	poetry export -f requirements.txt | poetry run safety check --stdin

newline-check:
	scripts/newline_check.sh

utest:
	poetry run pytest \
		--cov-report term:skip-covered \
		--cov-report html:reports \
		--cov-report xml:reports/coverage.xml \
		--junitxml=reports/unit_test_report.xml \
		--cov-fail-under=95 \
		--cov=src tests/unit_tests -ra -s

test-v:
	poetry run pytest \
		--cov-report term:skip-covered \
		--cov-report html:reports \
		--cov-report xml:reports/coverage.xml \
		--junitxml=reports/unit_test_report.xml \
		--cov-fail-under=95 \
		--cov=src tests/unit_tests -ra -s \
		-vvv

test: utest

.DELETE_ON_ERROR:
requirements.txt:
	poetry export --without-hashes --with-credentials -f requirements.txt -o requirements.txt
	SAM_CLI_TELEMETRY=0 \
		sam build -m requirements.txt -t template.yaml --debug --use-container
	rm requirements.txt

build: requirements.txt
