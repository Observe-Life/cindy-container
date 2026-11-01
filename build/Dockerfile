# Cindy Linux 桌面端容器化（零源码改动）
# 底座：jlesage/baseimage-gui Debian 变体（glibc；内置 Xvfb/openbox/x11vnc/noVNC/NGINX/s6）
# 注意：该底座构建期无 /etc/passwd 条目，用户由底座运行时按 USER_ID 生成；
#       官方安装器只要求非 root + HOME 可写，故直接以 uid 1000 安装，不 useradd。
FROM jlesage/baseimage-gui:debian-12-v4.14.0

ARG CINDY_VERSION=0.1.121
ARG CINDY_DEB=cindy-0.1.121-amd64.deb
ARG CINDY_SHA256=941e55bc2381c87460c5c6087a48e55f4d503735982a7363bd4b7c808c2d2b14

# D-Bus 会话 + Secret Service + 官方安装器依赖 + Electron 运行库（对照官方 docs/linux.md 清单）+ 中文环境
RUN add-pkg curl ca-certificates dbus dbus-x11 gnome-keyring libsecret-1-0 libarchive-tools \
    procps findutils util-linux locales desktop-file-utils xdg-utils \
    libnss3 libgtk-3-0 libasound2 libxss1 libxtst6 libnotify4 libdrm2 libgl1 && \
    sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# 数据目录归 uid 1000（与 compose 的 USER_ID 一致）
RUN mkdir -p /config && chown 1000:1000 /config

COPY ${CINDY_DEB} /tmp/${CINDY_DEB}

USER 1000
ENV HOME=/config
# install-user.sh 取自官方仓库对应 tag（与 .deb 同源）
RUN echo "${CINDY_SHA256}  /tmp/${CINDY_DEB}" | sha256sum -c - && \
    curl -fsSL "https://raw.githubusercontent.com/makecindy/cindy/v${CINDY_VERSION}/apps/desktop/resources/linux/install-user.sh" -o /tmp/install-user.sh && \
    bash /tmp/install-user.sh --install /tmp/${CINDY_DEB} ${CINDY_SHA256} /config/.local/opt/cindy && \
    rm -f /tmp/${CINDY_DEB} /tmp/install-user.sh && \
    ls -la /config/.local/opt/cindy/

USER root
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh
