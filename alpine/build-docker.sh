#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)

TAG="${1:-$(basename "$(dirname "$(pwd)")")}"

cd "${ROOT_DIR}"

NGINX_VERSION="$(
    curl \
        --silent \
        --fail \
        https://hg.nginx.org/nginx/raw-file/default/src/core/nginx.h |
        sed -n 's/#define NGINX_VERSION\s*"\(.*\)"/\1/p'
)"

docker build -t "${TAG}" --progress=plain --build-arg NGINX_VERSION="${NGINX_VERSION}" .
