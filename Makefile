all: container-cross-push

# 0.0 shouldn't clobber any release builds
TAG ?= latest
HAPROXY_TAG = 0.1
# Helm uses SemVer2 versioning
CHART_VERSION = 1.0.0


binary: 
	hack/gobuild.sh cmd/kube-keepalived-vip

# build kube-keepalived-vip in docker
container: ;$(info $(M)...Begin to build the docker image.)  @ ## Build the docker image.
	DRY_RUN=true hack/docker_build.sh

container-push: ;$(info $(M)...Begin to build and push.)  @ ## Build and Push.
	hack/docker_build.sh

container-cross: ; $(info $(M)...Begin to build container images for multiple platforms.)  @ ## Build container images for multiple platforms. Currently, only linux/amd64,linux/arm64 are supported.
	DRY_RUN=true hack/docker_build_multiarch.sh

container-cross-push: ; $(info $(M)...Begin to build and push.)  @ ## Build and Push.
	hack/docker_build_multiarch.sh


# only build/compile keepalived binary
# https://github.com/acassen/keepalived/archive/refs/tags/v${VERSION}.tar.gz
keepalived:
	DRY_RUN=true COMPILE_ONLY=true hack/docker_build.sh

keepalived-push:
	COMPILE_ONLY=true hack/docker_build.sh

keepalived-cross: ; $(info $(M)...Begin to build container images for multiple platforms.)  @ ## Build container images for multiple platforms. Currently, only linux/amd64,linux/arm64 are supported.
	DRY_RUN=true COMPILE_ONLY=true hack/docker_build_multiarch.sh

keepalived-cross-push: ; $(info $(M)...Begin to build and push.)  @ ## Build and Push.
	COMPILE_ONLY=true hack/docker_build_multiarch.sh


.PHONY: chart
chart: chart/kube-keepalived-vip-$(CHART_VERSION).tgz

.PHONY: chart-subst
chart-subst: chart/kube-keepalived-vip/Chart.yaml.tmpl chart/kube-keepalived-vip/values.yaml.tmpl
	for file in Chart.yaml values.yaml; do cp -f "chart/kube-keepalived-vip/$$file.tmpl" "chart/kube-keepalived-vip/$$file"; done
	sed -i'.bak' -e 's|%%TAG%%|$(TAG)|g' -e 's|%%HAPROXY_TAG%%|$(HAPROXY_TAG)|g' chart/kube-keepalived-vip/values.yaml
	sed -i'.bak' -e 's|%%CHART_VERSION%%|$(CHART_VERSION)|g' chart/kube-keepalived-vip/Chart.yaml
	rm -f chart/kube-keepalived-vip/*.bak

# Requires helm
chart/kube-keepalived-vip-$(CHART_VERSION).tgz: chart-subst $(shell which helm) $(shell find chart/kube-keepalived-vip -type f)
	helm lint --strict chart/kube-keepalived-vip
	helm package --version '$(CHART_VERSION)' -d chart chart/kube-keepalived-vip

clean-up:
	./hack/cleanup.sh

.PHONY: fmt
fmt:
	go fmt ./pkg/... ./cmd/...

.PHONY: lint
lint:
	@hack/verify-golangci-lint.sh

.PHONY: test
test:
	@go test ./pkg/... ./cmd/... -covermode=atomic -coverprofile=coverage.txt

.PHONY: cover
cover:
	@go list -f '{{if len .TestGoFiles}}"go test -coverprofile={{.Dir}}/.coverprofile {{.ImportPath}}"{{end}}' ${GO_LIST_FILES} | xargs -L 1 sh -c
	gover
	goveralls -coverprofile=gover.coverprofile -service travis-ci

.PHONY: vet
vet:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go vet ./pkg/... ./cmd/...



