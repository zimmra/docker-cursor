# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG GHDESKTOP_VERSION
ARG CURSOR_VERSION
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

COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://www.cursor.com/apple-touch-icon.png && \
   echo "**** install packages ****" && \
   apt-get update && \
   apt-get install -y \
     python3-xdg \
     git \
     ssh-askpass \
     thunar \
     libatk1.0 \
     libatk-bridge2.0 \
     libgtk-3-0 \
     libnss3 \
     libportaudio2 \
     xdotool \
     dbus-x11 && \
  echo "**** install Cursor ****" && \
  cd /tmp && \
  if [ -n "${CURSOR_VERSION}" ]; then \
    echo "**** using specified Cursor version: ${CURSOR_VERSION} ****" && \
    CURSOR_API_RESPONSE=$(curl -s 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable') && \
    CURSOR_DOWNLOAD_URL=$(echo "$CURSOR_API_RESPONSE" | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4); \
  else \
    echo "**** fetching latest Cursor version ****" && \
    CURSOR_DOWNLOAD_URL=$(curl -s \
      'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable' \
      | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4); \
  fi && \
  curl -o \
    /tmp/cursor.app -L \
    "$CURSOR_DOWNLOAD_URL" && \
  chmod +x /tmp/cursor.app && \
  ./cursor.app --appimage-extract && \
  mv squashfs-root /opt/cursor && \
#   ln -s \
#     /usr/lib/x86_64-linux-gnu/libportaudio.so.2 \
#     /usr/lib/x86_64-linux-gnu/libportaudio.so && \
echo "**** install firefox and github-desktop ****" && \
apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 738BEB9321D1AAEC13EA9391AEBDF4819BE21867 && \
echo \
  "deb https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu noble main" > \
  /etc/apt/sources.list.d/firefox.list && \
apt-get update && \
apt-get install -y --no-install-recommends \
  firefox \
  ^firefox-locale && \
echo "**** default firefox settings ****" && \
FIREFOX_SETTING="/usr/lib/firefox/browser/defaults/preferences/firefox.js" && \
echo 'pref("datareporting.policy.firstRunURL", "");' > ${FIREFOX_SETTING} && \
echo 'pref("datareporting.policy.dataSubmissionEnabled", false);' >> ${FIREFOX_SETTING} && \
echo 'pref("datareporting.healthreport.service.enabled", false);' >> ${FIREFOX_SETTING} && \
echo 'pref("datareporting.healthreport.uploadEnabled", false);' >> ${FIREFOX_SETTING} && \
echo 'pref("trailhead.firstrun.branches", "nofirstrun-empty");' >> ${FIREFOX_SETTING} && \
echo 'pref("browser.aboutwelcome.enabled", false);' >> ${FIREFOX_SETTING} && \
echo "**** install github-desktop ****" && \
if [ -z ${GHDESKTOP_VERSION+x} ]; then \
  GHDESKTOP_VERSION=$(curl -sX GET "https://api.github.com/repos/shiftkey/desktop/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]'); \
fi && \
curl -o \
  /tmp/ghdesktop.deb -L \
  "https://github.com/shiftkey/desktop/releases/download/${GHDESKTOP_VERSION}/GitHubDesktop-linux-amd64-${GHDESKTOP_VERSION#release-}.deb" && \
apt install --no-install-recommends -y /tmp/ghdesktop.deb && \

echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# fix permissions for executable files
RUN chmod +x /usr/bin/github-desktop

# ports and volumes
EXPOSE 3000

VOLUME /config