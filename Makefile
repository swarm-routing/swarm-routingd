# Copyright (c) 2026 Daniel Joppi (https://github.com/swarm-routing)
# SPDX-License-Identifier: MIT OR GPL-2.0-only
#
# swarm-routingd: the org's standard targets (swarm-routing/.github#11). Every org
# repo has these same target names, with this repo's own commands behind them;
# `org-sync check` verifies the names are present, never the recipes. Add
# repo-only targets at the end. `make help` lists everything with a `## ` note.

NS3_IMAGE ?= ghcr.io/swarm-routing/ns3-dev:latest-debug
PLATFORM  ?=
# container kind: the image's Dockerfile and its build arguments
DOCKERFILE ?= Dockerfile
BUILD_ARGS ?=

.DEFAULT_GOAL := help
.PHONY: help build test lint format check clean shell ci headers org-sync-check org-tools pre-push

help: ## list the targets
	@awk 'BEGIN{FS=":.*## "} /^[a-zA-Z0-9_-]+:.*## /{printf "  %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## build what this repo ships
	if [ -f CMakeLists.txt ]; then cmake -S . -B build && cmake --build build -j; else echo "make build: no CMakeLists.txt yet"; fi

test: ## the fast tests CI runs on every PR
	if [ -f CMakeLists.txt ]; then cmake -S . -B build && cmake --build build -j && ctest --test-dir build --output-on-failure; else echo "make test: no CMakeLists.txt yet"; fi

lint: ## static checks, no changes
	git ls-files "*.h" "*.cc" "*.cpp" "*.hpp" | xargs -r clang-format --dry-run --Werror

format: ## apply the formatters
	git ls-files "*.h" "*.cc" "*.cpp" "*.hpp" | xargs -r clang-format -i

clean: ## remove build outputs
	rm -rf build

shell: ## an interactive shell in the dev image with this repo at /src
	@command -v docker >/dev/null || { echo "make shell: docker not found (Docker Desktop, Colima, or docker.io)" >&2; exit 127; }
	docker run --rm -it -v "$(CURDIR):/src" -w /src $(if $(PLATFORM),--platform $(PLATFORM)) $(NS3_IMAGE) bash

headers: org-tools ## licence headers (org rule 1): the Go gate CI runs, in docker or built with go
	"$(ORG_DIR)/tools/checks/check-headers.sh" --dual 'src/ test/' --core core/ .

check: lint test headers org-sync-check ## everything CI gates on

ci: check ## exactly what CI runs

# The release asset reusable-release.yml publishes (.github/workflows/release.yml):
# the source tarball of HEAD, which the swarm-routingd vcpkg port builds from.
DIST_VERSION = $(shell cat VERSION)
.PHONY: dist
dist: ## the release asset: dist/swarm-routingd-<VERSION>.tar.gz, the source of HEAD
	mkdir -p dist
	git archive --format=tar.gz --prefix=swarm-routingd-$(DIST_VERSION)/ -o dist/swarm-routingd-$(DIST_VERSION).tar.gz HEAD
	tar -xzf dist/swarm-routingd-$(DIST_VERSION).tar.gz -C dist
	cmake -S dist/swarm-routingd-$(DIST_VERSION) -B dist/build && cmake --build dist/build -j && ctest --test-dir dist/build --output-on-failure
	rm -rf dist/build dist/swarm-routingd-$(DIST_VERSION)

# org-sync:begin org-tools
# The org tooling (check-headers, org-sync): a shallow clone, refreshed to ORG_REF,
# by default the template commit .github/org-sync.lock pins, as CI checks (#586).
ORG_DIR   ?= $(HOME)/.cache/swarm-routing/dotgithub
ORG_REF   ?= $(or $(shell sed -nE 's/^commit = "([0-9a-f]{40})"[[:space:]]*$$/\1/p' .github/org-sync.lock 2>/dev/null),main)
# make pre-push TITLE='type(scope): subject': the PR title rule of reusable-pr-title.yml
export TITLE
TITLE_RE  := ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: [^A-Z ](.*[^ ])?$$

.PHONY: org-tools org-sync-check pre-push

org-tools:  # the same templates CI checks against: refreshed to ORG_REF every time
	@[ -d "$(ORG_DIR)/.git" ] || { git init -q "$(ORG_DIR)" && git -C "$(ORG_DIR)" remote add origin https://github.com/swarm-routing/.github; }
	@git -C "$(ORG_DIR)" fetch -q --depth 1 origin $(ORG_REF) && git -C "$(ORG_DIR)" checkout -q --detach FETCH_HEAD

org-sync-check: org-tools ## org-managed files match the org templates
	python3 -I "$(ORG_DIR)/tools/org-sync/org_sync.py" check .

pre-push: check ## before every push: make check, then TITLE='type(scope): subject' (the PR title)
	@[ -n "$$TITLE" ] || { echo "make pre-push: pass TITLE='<the PR title>'" >&2; exit 2; }
	@printf '%s\n' "$$TITLE" | grep -Eq '$(TITLE_RE)' || { echo "PR title is not a lowercase Conventional Commit: $$TITLE" >&2; exit 1; }
	@echo "pre-push: ok ($$TITLE)"

.PHONY: doctor
doctor: ## this machine's tools against the versions CI runs (the org's tools/versions.env, go.mod), and the hosts the network steps need
	@$(MAKE) -s org-tools || echo "doctor: could not refresh $(ORG_DIR) (offline?): using it as it is" >&2
	@"$(ORG_DIR)/tools/doctor/doctor.sh" .
# org-sync:end org-tools
