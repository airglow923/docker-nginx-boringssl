FROM alpine:latest

LABEL maintainer="Hyundeok Park <p.hyundeok76@gmail.com>"

RUN mkdir -p /tmp/deps
COPY deps /tmp/deps

RUN mkdir -p /tmp/scripts
COPY scripts /tmp/scripts
RUN /tmp/scripts/00-*

RUN rm -rf /tmp/scripts
RUN rm -rf /tmp/deps

COPY docker-entrypoint.sh /
COPY docker-entrypoint.d /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]

