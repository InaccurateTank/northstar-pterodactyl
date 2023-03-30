FROM        --platform=$TARGETOS/$TARGETARCH alpine:latest AS base

LABEL       author="InaccurateTank" maintainer="inaccuratetank@outlook.com"
# LABEL       org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL       org.opencontainers.image.licenses=MIT

FROM base AS build
RUN apk -U add alpine-sdk git sudo
RUN adduser -Dh /nsbuild nsbuild && \
    adduser nsbuild abuild && \
    echo 'nsbuild ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nsbuild

USER nsbuild
RUN mkdir -p /nsbuild/src/ /nsbuild/packages/main && \
    abuild-keygen -ain && \
    git clone https://github.com/pg9182/northstar-dedicated.git /tmp/repo && \
    mv /tmp/repo/src /nsbuild/src/main

FROM build AS build-wine
RUN ulimit -n 1024; cd /nsbuild/src/main/wine && abuild -r

FROM base
RUN apk add --no-cache gnutls tzdata ca-certificates
RUN --mount=from=build-wine,source=/nsbuild/packages/main/x86_64,target=/nsbuild/wine \
    apk add --no-cache --allow-untrusted /nsbuild/wine/northstar-dedicated-wine-[0-9]*-r*.apk xvfb

# silence Xvfb xkbcomp warnings by working around the bug (present in libX11 1.7.2) fixed in libX11 1.8 by https://gitlab.freedesktop.org/xorg/lib/libx11/-/merge_requests/79
RUN echo 'partial xkb_symbols "evdev" {};' > /usr/share/X11/xkb/symbols/inet

ENV WINEPREFIX="/home/container/.wine"