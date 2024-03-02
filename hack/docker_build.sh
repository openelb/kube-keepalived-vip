#!/usr/bin/env bash

set -ex
set -o pipefail

OPENELB_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
source "${OPENELB_ROOT}/hack/lib/init.sh"

# push to kubesphere with default latest tag
REPO=${REPO:-kubesphere}
VERSION=${VERSION:-2.2.8}
COMPILE_ONLY=${COMPILE_ONLY:-}
if [[ -n "${COMPILE_ONLY:-}" ]]; then
  TAG=${TAG:-${VERSION}}
else
  TAG=${TAG:-latest}
fi

# If set, just building, no pushing
DRY_RUN=${DRY_RUN:-}

# support other container tools. e.g. podman
CONTAINER_CLI=${CONTAINER_CLI:-docker}
CONTAINER_BUILDER=${CONTAINER_BUILDER:-build}

# use host os and arch as default target os and arch
TARGETOS=${TARGETOS:-$(kube::util::host_os)}
TARGETARCH=${TARGETARCH:-$(kube::util::host_arch)}


if [[ -n "${COMPILE_ONLY:-}" ]]; then
${CONTAINER_CLI} "${CONTAINER_BUILDER}" \
  --build-arg TARGETARCH="${TARGETARCH}" \
  --build-arg TARGETOS="${TARGETOS}" \
  --build-arg VERSION="${VERSION}" \
  --output type=docker \
  -f build/keepalived/Dockerfile \
  -t "${REPO}"/build-keepalived:"${TAG}" .
else
${CONTAINER_CLI} "${CONTAINER_BUILDER}" \
  --build-arg "TARGETARCH=${TARGETARCH}" \
  --build-arg "TARGETOS=${TARGETOS}" \
  --output type=docker \
  -f build/kube-keepalived/Dockerfile \
  -t "${REPO}"/kube-keepalived-vip:"${TAG}" .
fi

if [[ -z "${DRY_RUN:-}" ]]; then
  if [[ -n "${COMPILE_ONLY:-}" ]]; then
    ${CONTAINER_CLI} push "${REPO}"/build-keepalived:"${TAG}"
  else
    ${CONTAINER_CLI} push "${REPO}"/kube-keepalived-vip:"${TAG}"
  fi
fi
