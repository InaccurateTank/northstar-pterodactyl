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

FROM build AS build-northstar
RUN ulimit -n 1024; cd /nsbuild/src/main/northstar && abuild -r

FROM build AS build-nswrap
RUN ulimit -n 1024; cd /nsbuild/src/main/nswrap && abuild -r

FROM build AS build-entrypoint
RUN ulimit -n 1024; cd /nsbuild/src/main/entrypoint && abuild -r

FROM base
RUN apk add --no-cache gnutls tzdata ca-certificates
RUN --mount=from=build-wine,source=/nsbuild/packages/main/x86_64,target=/nsbuild/wine \
    apk add --no-cache --allow-untrusted /nsbuild/wine/northstar-dedicated-wine-[0-9]*-r*.apk xvfb
RUN --mount=from=build-northstar,source=/nsbuild/packages/main/x86_64,target=/nsbuild/northstar \
    apk add --no-cache --allow-untrusted /nsbuild/northstar/*.apk
RUN --mount=from=build-nswrap,source=/nsbuild/packages/main/x86_64,target=/nsbuild/nswrap \
    --mount=from=build-entrypoint,source=/nsbuild/packages/main/x86_64,target=/nsbuild/entrypoint \
    apk add --no-cache --allow-untrusted /nsbuild/nswrap/*.apk /nsbuild/entrypoint/*.apk
RUN rm -r /nsbuild

# silence Xvfb xkbcomp warnings by working around the bug (present in libX11 1.7.2) fixed in libX11 1.8 by https://gitlab.freedesktop.org/xorg/lib/libx11/-/merge_requests/79
RUN echo 'partial xkb_symbols "evdev" {};' > /usr/share/X11/xkb/symbols/inet

RUN adduser -D container && \
    mkdir /mnt/titanfall /mnt/navs /mnt/mods
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

ENV WINEPREFIX="/home/container/.wine"
RUN nswrap-wineprefix && \
    for x in \
        /home/container/.wine/drive_c/"Program Files"/"Common Files"/System/*/* \
        /home/container/.wine/drive_c/windows/* \
        /home/container/.wine/drive_c/windows/system32/* \
        /home/container/.wine/drive_c/windows/system32/drivers/* \
        /home/container/.wine/drive_c/windows/system32/wbem/* \
        /home/container/.wine/drive_c/windows/system32/spool/drivers/x64/*/* \
        /home/container/.wine/drive_c/windows/system32/Speech/common/* \
        /home/container/.wine/drive_c/windows/winsxs/*/* \
    ; do \
        orig="/usr/lib/wine/x86_64-windows/$(basename "$x")"; \
        if cmp -s "$orig" "$x"; then ln -sf "$orig" "$x"; fi; \
    done && \
    for x in \
        /home/container/.wine/drive_c/windows/globalization/sorting/*.nls \
        /home/container/.wine/drive_c/windows/system32/*.nls \
    ; do \
        orig="/usr/share/wine/nls/$(basename "$x")"; \
        if cmp -s "$orig" "$x"; then ln -sf "$orig" "$x"; fi; \
    done

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]