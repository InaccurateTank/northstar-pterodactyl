#!/bin/sh

## Updating the installer
apk update
apk upgrade

## Building the wrapper
apk add --update --no-cache alpine-sdk git jq
git clone https://github.com/pg9182/northstar-dedicated.git /nsbuild
cd /nsbuild/src/nswrap
gcc -Wall -Wextra -Werror -Wno-trampolines -std=gnu11 -O3 -DNSWRAP_HASH="$(sha256sum nswrap.c | head -c64)" "nswrap.c" -o "/mnt/server/nswrap"
chmod +x /mnt/server/nswrap

## Installing Northstar
VERSION=$(curl -sL https://api.github.com/repos/R2Northstar/Northstar/releases/latest | jq -r ".tag_name") && \
curl -Lo /tmp/northstar.zip https://github.com/R2Northstar/Northstar/releases/download/$VERSION/Northstar.release.$VERSION.zip && \
unzip -o /tmp/northstar.zip -d /mnt/server/Northstar

## Setup config and link for accessibility
echo "+setplaylist private_match" > /mnt/server/Northstar/ns_startup_args_dedi.txt
ln -s /mnt/server/Northstar/ns_startup_args_dedi.txt /mnt/server
ln -s /mnt/server/Northstar/R2Northstar/mods/Northstar.CustomServers/mod/cfg/autoexec_ns_server.cfg /mnt/server

## Removing old .wine folder
rm -r /mnt/server/.wine