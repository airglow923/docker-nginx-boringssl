#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)

TAG="${1:-$(basename "$(dirname "$(pwd)")")}"

NGINX_VERSION="${2:-$(
    curl \
        --silent \
        --fail \
        https://hg.nginx.org/nginx/raw-file/default/src/core/nginx.h |
        sed -n 's/#define NGINX_VERSION\s*"\(.*\)"/\1/p'
)}"

cd "${ROOT_DIR}"

docker build -t "${TAG}" --progress=plain --build-arg NGINX_VERSION="${NGINX_VERSION}" .
