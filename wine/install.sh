#!/bin/sh
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
done
for x in \
  /home/container/.wine/drive_c/windows/globalization/sorting/*.nls \
  /home/container/.wine/drive_c/windows/system32/*.nls \
; do \
  orig="/usr/share/wine/nls/$(basename "$x")"; \
  if cmp -s "$orig" "$x"; then ln -sf "$orig" "$x"; fi; \
done
mkdir mods