# Cindy Linux 桌面端容器化（零源码改动）
# 底座：jlesage/baseimage-gui Debian 变体（内置 Xvfb/openbox/x11vnc/noVNC/NGINX/s6）
# 说明：该底座构建期无 /etc/passwd 条目，运行用户由底座按 USER_ID 生成；
#       官方安装器只要求非 root + HOME 可写，故直接以 uid 1000 安装，不 useradd。
FROM jlesage/baseimage-gui:debian-12-v4.14.0

ARG CINDY_VERSION=0.1.121
ARG CINDY_SHA256=941e55bc2381c87460c5c6087a48e55f4d503735982a7363bd4b7c808c2d2b14
ARG CINDY_DEB_URL=https://hotfix.cindy.com.cn/cindy/app/linux-x64/cindy-0.1.121-amd64.deb

# D-Bus 会话 + Secret Service + 官方安装器依赖 + Electron 运行库（对照官方 docs/linux.md）+ 中文环境
RUN add-pkg curl ca-certificates dbus dbus-x11 gnome-keyring libsecret-1-0 libarchive-tools \
    procps findutils util-linux locales desktop-file-utils xdg-utils \
    libnss3 libgtk-3-0 libasound2 libxss1 libxtst6 libnotify4 libdrm2 libgl1 && \
    sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

RUN mkdir -p /config && chown 1000:1000 /config

USER 1000
ENV HOME=/config LANG=zh_CN.UTF-8
# 同一层内完成：下载官方 .deb → 校验 → 官方安装器安装 → 清理（deb 不残留在镜像层）
RUN set -eu; \
    curl -fsSL "$CINDY_DEB_URL" -o /tmp/cindy.deb; \
    echo "${CINDY_SHA256}  /tmp/cindy.deb" | sha256sum -c -; \
    curl -fsSL "https://raw.githubusercontent.com/makecindy/cindy/v${CINDY_VERSION}/apps/desktop/resources/linux/install-user.sh" -o /tmp/install-user.sh; \
    bash /tmp/install-user.sh --install /tmp/cindy.deb "${CINDY_SHA256}" /config/.local/opt/cindy; \
    rm -f /tmp/cindy.deb /tmp/install-user.sh; \
    ls -la /config/.local/opt/cindy/

USER root
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh
