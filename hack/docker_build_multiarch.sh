#!/usr/bin/env bash

set -ex
set -o pipefail

OPENELB_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
source "${OPENELB_ROOT}/hack/lib/init.sh"

# push to kubesphere with default latest tag
REPO=${REPO:-kubesphere}
VERSION=${VERSION:-2.2.8}
PUSH=${PUSH:-}
COMPILE_ONLY=${COMPILE_ONLY:-}
if [[ -n "${COMPILE_ONLY:-}" ]]; then
  TAG=${TAG:-${VERSION}}
else
  TAG=${TAG:-latest}
fi

# support other container tools. e.g. podman
CONTAINER_CLI=${CONTAINER_CLI:-docker}
CONTAINER_BUILDER=${CONTAINER_BUILDER:-"buildx build"}

# If set, just building, no pushing
if [[ -z "${DRY_RUN:-}" ]]; then
  PUSH="--push"
fi

# supported platforms
PLATFORMS=linux/amd64,linux/arm64


# shellcheck disable=SC2086 # inteneded splitting of CONTAINER_BUILDER
if [[ -n "${COMPILE_ONLY:-}" ]]; then
${CONTAINER_CLI} ${CONTAINER_BUILDER} \
  --platform ${PLATFORMS} \
  --build-arg VERSION="${VERSION}" \
  ${PUSH} \
  -f build/keepalived/Dockerfile \
  -t "${REPO}"/build-keepalived:"${TAG}" .

else
${CONTAINER_CLI} ${CONTAINER_BUILDER} \
  --platform ${PLATFORMS} \
  ${PUSH} \
  -f build/kube-keepalived/Dockerfile \
  -t "${REPO}"/kube-keepalived-vip:"${TAG}" .

fi


