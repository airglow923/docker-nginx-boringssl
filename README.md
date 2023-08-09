This repository is based on
[nginxinc/docker-nginx](https://github.com/nginxinc/docker-nginx) with
modifications to use [BoringSSL](https://github.com/google/boringssl) and QUIC.

Usage:

```docker
FROM airglow923/nginx-boringssl:tagname
```

Also, there is a variation with
[mitchellkrogza/nginx-ultimate-bad-bot-blocker](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker)
installed, which is tagged `NGINX_VERSION-ngxblocker`.

For example, if you want to get an image for NGINX 1.25.1 with
`nginx-ultimate-bad-bot-blocker`, please use the following image:

```docker
FROM airglow923/nginx-boringssl:1.25.1-ngxblocker
```
