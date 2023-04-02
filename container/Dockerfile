FROM        --platform=$TARGETOS/$TARGETARCH docker.io/alpine:latest AS base

LABEL       author="InaccurateTank" maintainer="inaccuratetank@outlook.com"
LABEL       org.opencontainers.image.source="https://github.com/InaccurateTank/northstar-pterodactyl"
LABEL       org.opencontainers.image.licenses=MIT

FROM base AS build

RUN         apk -U add alpine-sdk git sudo
RUN         adduser -Dh /nsbuild nsbuild && \
            adduser nsbuild abuild && \
            echo 'nsbuild ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nsbuild

# Build custom wine from https://github.com/pg9182/northstar-dedicated/tree/master/src/wine
USER        nsbuild
RUN         mkdir -p /nsbuild/src/ /nsbuild/packages/main && \
            abuild-keygen -ain && \
            git clone https://github.com/pg9182/northstar-dedicated.git /tmp/repo && \
            mv /tmp/repo/src /nsbuild/src/main && \
            ulimit -n 1024; \
            cd /nsbuild/src/main/wine && abuild -r

FROM base
COPY        --chmod=0755 --from=build /nsbuild/src/main/nswrap/nswrap-wineprefix /usr/local/bin/nswrap-wineprefix

RUN         apk add --no-cache gnutls tzdata ca-certificates
RUN         --mount=from=build,source=/nsbuild/packages/main/x86_64,target=/nsbuild/wine \
            apk add --no-cache --allow-untrusted /nsbuild/wine/northstar-dedicated-wine-[0-9]*-r*.apk xvfb

# silence Xvfb xkbcomp warnings by working around the bug (present in libX11 1.7.2) fixed in libX11 1.8 by https://gitlab.freedesktop.org/xorg/lib/libx11/-/merge_requests/79
RUN         echo 'partial xkb_symbols "evdev" {};' > /usr/share/X11/xkb/symbols/inet

# Setup user and working directory
RUN         adduser -D container && \
            mkdir -p /mnt/titanfall
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

ENV         WINEPREFIX="/home/container/.wine"

## Copy over and execute entrypoint.sh
COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/sh", "/entrypoint.sh" ]