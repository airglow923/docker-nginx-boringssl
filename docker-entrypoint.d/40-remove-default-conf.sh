#!/bin/sh

set -eu

# remove default configuration to avoid error opening 80/tcp
rm /etc/nginx/conf.d/default.conf
