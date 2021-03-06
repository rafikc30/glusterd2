GOPATH := $(shell go env GOPATH)
GOBIN := '$(GOPATH)/bin'

.PHONY: all build check check-go check-reqs install vendor-update verify glusterd2 release check-protoc

all: build

build: check-go check-reqs vendor-update glusterd2

check: check-go check-reqs check-protoc

check-go:
	@./scripts/check-go.sh
	@echo

check-protoc:
	@./scripts/check-protoc.sh
	@echo

check-reqs:
	@./scripts/check-reqs.sh
	@echo

glusterd2:
	@./scripts/build.sh
	@echo

install: check-go check-reqs vendor-update
	@./scripts/build.sh $(GOBIN)
	@echo Setting CAP_SYS_ADMIN for glusterd2 \(requires sudo\)
	sudo setcap cap_sys_admin+ep $(GOBIN)/glusterd2
	@echo

vendor-update:
	@echo Updating vendored packages
	@GO15VENDOREXPERIMENT=1 glide install
	@echo

verify: check-reqs
	@GO15VENDOREXPERIMENT=1 gometalinter -D gotype -E gofmt --errors --deadline=5m -j 4 $$(GO15VENDOREXPERIMENT=1 glide nv)

test:
	@GO15VENDOREXPERIMENT=1 go test $$(GO15VENDOREXPERIMENT=1 glide nv)

release: check-go check-reqs vendor-update
	@./scripts/release.sh
