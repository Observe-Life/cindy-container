# Cindy Linux 桌面端容器化（零源码改动）
# 底座：jlesage/baseimage-gui Debian 变体（glibc；内置 Xvfb/openbox/x11vnc/noVNC/NGINX/s6）
FROM jlesage/baseimage-gui:debian-12-v4.14.0

ARG CINDY_VERSION=0.1.121
ARG CINDY_DEB=cindy-0.1.121-amd64.deb
ARG CINDY_SHA256=941e55bc2381c87460c5c6087a48e55f4d503735982a7363bd4b7c808c2d2b14

# D-Bus 会话 + Secret Service + 官方安装器依赖 + 中文环境
RUN add-pkg dbus dbus-x11 gnome-keyring libsecret-1-0 libarchive-tools procps findutils util-linux locales && \
    sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# 与底座运行用户一致的普通用户（官方安装器拒绝 root）
RUN (id -u 1000 >/dev/null 2>&1 || useradd -u 1000 -m -d /config -s /bin/bash cindy) && \
    mkdir -p /config && chown 1000:1000 /config

COPY ${CINDY_DEB} /tmp/${CINDY_DEB}

USER 1000
ENV HOME=/config
# install-user.sh 取自官方仓库 v0.1.121 tag（与 .deb 同源）
RUN echo "${CINDY_SHA256}  /tmp/${CINDY_DEB}" | sha256sum -c - && \
    curl -fsSL "https://raw.githubusercontent.com/makecindy/cindy/v${CINDY_VERSION}/apps/desktop/resources/linux/install-user.sh" -o /tmp/install-user.sh && \
    bash /tmp/install-user.sh --install /tmp/${CINDY_DEB} ${CINDY_SHA256} /config/.local/opt/cindy && \
    rm -f /tmp/${CINDY_DEB} /tmp/install-user.sh && \
    ls -la /config/.local/opt/cindy/

USER root
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh
