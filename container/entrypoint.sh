#!/bin/sh

## Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

## Work .wine folder if it doesn't exist
if [ ! -d ".wine" ]; then
    nswrap-wineprefix
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
fi

## Create exec merge folder if it doesn't exist already
if [ -d ".exec" ]; then
    rm .exec -r
fi
mkdir .exec
cp -dlr /mnt/titanfall/* .exec
cp -dlr /home/container/Northstar/* .exec

## Switch to container directory
cd /home/container || exit 1

## Start the server
export DISPLAY="xvfb"
export NSWRAP_TITLE="sn"
eval ./${STARTUP}