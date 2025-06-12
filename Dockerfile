# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="zimmra"

# title
ENV TITLE="Cursor AI"

# reduce errors and warnings
ENV DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/dbus-session" \
    DISPLAY=:1 \
    ELECTRON_DISABLE_GPU_SANDBOX=1 \
    ELECTRON_DISABLE_SECURITY_WARNINGS=1 \
    ELECTRON_DISABLE_SANDBOX=1 \
    ELECTRON_NO_SANDBOX=1 \
    CHROME_DEVEL_SANDBOX="" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    __GL_SYNC_TO_VBLANK=0

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://www.cursor.com/apple-touch-icon.png && \
   echo "**** install packages ****" && \
   apt-get update && \
   apt-get install -y \
     python3-xdg \
     libatk1.0 \
     libatk-bridge2.0 \
     libgtk-3-0 \
     libnss3 \
     libportaudio2 \
     xdotool \
     dbus-x11 && \
  echo "**** install Cursor ****" && \
  cd /tmp && \
  CURSOR_DOWNLOAD_URL=$(curl -s \
    'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable' \
    | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4) && \
  curl -o \
    /tmp/cursor.app -L \
    "$CURSOR_DOWNLOAD_URL" && \
  chmod +x /tmp/cursor.app && \
  ./cursor.app --appimage-extract && \
  mv squashfs-root /opt/cursor && \
#   ln -s \
#     /usr/lib/x86_64-linux-gnu/libportaudio.so.2 \
#     /usr/lib/x86_64-linux-gnu/libportaudio.so && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config