#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)

TAG="${1:-$(basename "$(dirname "$(pwd)")")}"

cd "${ROOT_DIR}"

NGINX_VERSION="$(
    curl \
        --silent \
        --fail https://hg.nginx.org/nginx-quic/raw-file/tip/src/core/nginx.h |
        sed -n 's/#define NGINX_VERSION\s*"\(.*\)"/\1/p'
)"

docker build -t "${TAG}" --build-arg NGINX_VERSION="${NGINX_VERSION}" .