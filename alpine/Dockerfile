FROM alpine:latest

LABEL maintainer="Hyundeok Park <p.hyundeok76@gmail.com>"

ARG NGINX_VERSION
ARG RELEASE

ENV TMP_DIR /tmp/docker-nginx-boringssl

RUN addgroup -g 101 -S nginx
RUN adduser -S -D -H -u 101 \
    -h /var/cache/nginx \
    -s /sbin/nologin \
    -G nginx \
    -g nginx \
    nginx

# add public key for package signing
RUN wget -O /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub

RUN set -eux \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp \
    && ENVSUBST_DEPENDENCIES="$( \
        scanelf --needed --nobanner /tmp/envsubst | \
            awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | \
            sort -u | \
            xargs -r apk info --installed | \
            sort -u \
    )" \
    && apk add --no-cache $ENVSUBST_DEPENDENCIES \
    && apk del --no-network .gettext \
    && mv /tmp/envsubst /usr/local/bin

RUN apk add --no-cache --virtual .build-deps-boringssl \
    cmake \
    g++ \
    go \
    ninja \
    perl

RUN git clone https://github.com/google/boringssl "${TMP_DIR}/boringssl"
RUN cmake -GNinja -B "${TMP_DIR}/boringssl/build" "${TMP_DIR}/boringssl"
RUN cmake --build "${TMP_DIR}/boringssl/build"
RUN apk del --no-network .build-deps-boringssl

# alpine-sdk depends on abuild that depends on curl
RUN set -eux \
    && PKG_OSS_TARBALL="pkg-oss-${NGINX_VERSION}-${RELEASE}.tar.gz" \
    && cd "${TMP_DIR}" \
    && curl -sSf --tlsv1.2 --proto '=https' \
        "https://hg.nginx.org/pkg-oss/archive/${NGINX_VERSION}-${RELEASE}.tar.gz" \
        -o "${PKG_OSS_TARBALL}" \
    && tar -xf "${PKG_OSS_TARBALL}"

RUN set -eux \
    && cd "${TMP_DIR}"/pkg-oss-*/alpine \
    && sed -i 's/\(\s*--with-stream_ssl_preread_module\)/\1 \\/' Makefile \
    && sed -i \
        '/--with-stream_ssl_preread_module/a \ \
        --with-cc-opt="-I $(BORINGSSL_DIR)/include" \\\n \
        --with-ld-opt="-L $(BORINGSSL_DIR)/build/ssl -L $(BORINGSSL_DIR)/build/crypto"' \
        Makefile \
    && sed -i \
        '/make \$_make_opts/i \ \
        touch "${BORINGSSL_DIR}/include/openssl/ssl.h"' \
        alpine/APKBUILD-base.in

RUN chown nobody:nobody "${TMP_DIR}"
RUN chown -R nobody:nobody "${TMP_DIR}"/boringssl/include
RUN chown -R nobody:nobody "${TMP_DIR}"/pkg-oss-*

RUN apk add --no-cache --virtual .build-deps-nginx \
    alpine-sdk \
    bash \
    findutils \
    gcc \
    libc-dev \
    linux-headers \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev

RUN set -eux \
    && export APK_ARCH="$(cat /etc/apk/arch)" \
    && export BORINGSSL_DIR="${TMP_DIR}/boringssl" \
    && su nobody -s /bin/sh -c " \
        export HOME=\"${TMP_DIR}\" \
        && cd \"${TMP_DIR}\"/pkg-oss-*/alpine \
        && make base \
        && apk index \
            -o \"${TMP_DIR}/packages/alpine/${APK_ARCH}/APKINDEX.tar.gz\" \
            \"${TMP_DIR}/packages/alpine/${APK_ARCH}\"/*.apk \
        && abuild-sign \
            -k \"${TMP_DIR}/.abuild/abuild-key.rsa\" \
            \"${TMP_DIR}/packages/alpine/${APK_ARCH}/APKINDEX.tar.gz\""

RUN apk del --no-network .build-deps-nginx

RUN cp "${TMP_DIR}/.abuild/abuild-key.rsa.pub" /etc/apk/keys
RUN apk add \
    -X "${TMP_DIR}/packages/alpine" \
    --no-cache "nginx=${NGINX_VERSION}-r${RELEASE}"

RUN [ -n "${TMP_DIR}" ] && rm -rf "${TMP_DIR}"
RUN [ -n "/etc/apk/keys/abuild-key.rsa.pub" ] && rm -f /etc/apk/keys/abuild-key.rsa.pub
RUN [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ] && rm -f /etc/apk/keys/nginx_signing.rsa.pub

RUN apk add --no-cache tzdata

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir -p /docker-entrypoint.d

COPY docker-entrypoint.sh /
COPY docker-entrypoint.d /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80/tcp

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
