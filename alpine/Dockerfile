FROM alpine:latest

LABEL maintainer="Hyundeok Park <p.hyundeok76@gmail.com>"

ARG NGINX_VERSION
ARG RELEASE=1

ENV TMP_DIR /tmp/docker-nginx-boringssl

RUN apk add --no-cache --virtual .nginx-deps \
    alpine-sdk \
    bash \
    cmake \
    findutils \
    g++ \
    gcc \
    go \
    libc-dev \
    linux-headers \
    make \
    mercurial \
    ninja \
    openssl \
    openssl-dev \
    pcre2-dev \
    perl \
    rsync \
    zlib-dev

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
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin

RUN apk add --no-cache tzdata

RUN addgroup -g 101 -S nginx
RUN adduser -S -D -H -u 101 \
    -h /var/cache/nginx \
    -s /sbin/nologin \
    -G nginx \
    -g nginx \
    nginx

RUN git clone https://github.com/google/boringssl "${TMP_DIR}/boringssl"
RUN cmake -GNinja -B "${TMP_DIR}/boringssl/build" "${TMP_DIR}/boringssl"
RUN cmake --build "${TMP_DIR}/boringssl/build"

RUN set -eux \
    && PKG_OSS_TARBALL="pkg-oss-${NGINX_VERSION}-${RELEASE}.tar.gz" \
    && cd "${TMP_DIR}" \
    && curl -o "${PKG_OSS_TARBALL}" \
        -fS "https://hg.nginx.org/pkg-oss/archive/${NGINX_VERSION}-${RELEASE}.tar.gz" \
    && tar -xf "${PKG_OSS_TARBALL}"

RUN set -eux \
    && cd "${TMP_DIR}"/pkg-oss-*/alpine \
    && sed -i 's/\(\s*--with-stream_ssl_preread_module\)/\1 \\/' Makefile \
    && sed -i \
        '/--with-stream_ssl_preread_module/a \ \
        --with-http_v3_module \\\n \
        --with-cc-opt="-I $(BORINGSSL_DIR)/include" \\\n \
        --with-ld-opt="-L $(BORINGSSL_DIR)/build/ssl -L $(BORINGSSL_DIR)/build/crypto"' \
        Makefile \
    && sed -i \
        '/prepare() {/a \ \
        hg clone -b quic https://hg.nginx.org/nginx-quic "${TMP_DIR}/nginx-quic" \n \
        rsync -r "${TMP_DIR}/nginx-quic/" "$builddir"' \
        APKBUILD-base.in \
    && sed -i \
        '/make \$_make_opts/i \ \
        touch "${BORINGSSL_DIR}/include/openssl/ssl.h"' \
        APKBUILD-base.in

RUN chown nobody:nobody "${TMP_DIR}"
RUN chown -R nobody:nobody "${TMP_DIR}"/boringssl/include
RUN chown -R nobody:nobody "${TMP_DIR}"/pkg-oss-*

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

RUN cp "${TMP_DIR}/.abuild/abuild-key.rsa.pub" /etc/apk/keys

RUN apk add \
    -X "${TMP_DIR}/packages/alpine" \
    --no-cache "nginx=${NGINX_VERSION}-r${RELEASE}"

RUN apk del .nginx-deps

RUN [ -n "${TMP_DIR}" ] && rm -rf "${TMP_DIR}"
RUN [ -n "/etc/apk/keys/abuild-key.rsa.pub" ] && rm -f /etc/apk/keys/abuild-key.rsa.pub
RUN [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ] && rm -f /etc/apk/keys/nginx_signing.rsa.pub

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir -p /docker-entrypoint.d

COPY docker-entrypoint.sh /
COPY docker-entrypoint.d /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80/tcp

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
