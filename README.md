# cindy-container

把 [Cindy](https://github.com/makecindy/cindy) 的 **Linux 桌面端**容器化部署到无显示器的 Linux 服务器，
供官手机 App 通过官方中继远程连接使用。**零源码改动**（构建时下载官方 .deb 与官方安装脚本）。

## 原理

- 底座 `jlesage/baseimage-gui`（Debian 变体）：Xvfb 虚拟屏幕 + Openbox + x11vnc + noVNC + NGINX + s6
- Cindy 用官方 `install-user.sh` 用户级安装（免 root、免 polkit），数据全在 `/config` 卷
- 凭据：容器内 D-Bus 会话总线 + gnome-keyring（启动时用 `KEYRING_PASS`/`KEYRING_PASS_FILE` 自动解锁）
- Electron 以 `--no-sandbox --password-store=gnome-libsecret` 启动（容器即隔离边界，selkies 官方同款做法）
- 手机连接走 Cindy 官方中继（同账号设备列表可见）；Web 界面仅用于首次登录与兜底操作

## 构建

推送本仓库即触发 GitHub Actions：下载官方 `cindy-<版本>-amd64.deb`（校验 SHA-256）→
构建并推送镜像到 `ghcr.io/observe-life/cindy-container`。

升级：改 workflow 的 `CINDY_VERSION`/`CINDY_SHA256`（取自官方 CDN `manifest-linux-x64.json` 的 `app` 节点）后重新推送。

## 运行（飞牛 NAS 示例）

```yaml
# /vol1/docker/cindy/docker-compose.yml 关键项
services:
  cindy:
    image: ghcr.io/observe-life/cindy-container:latest
    container_name: cindy
    restart: unless-stopped
    shm_size: "1gb"
    environment:
      - KEYRING_PASS_FILE=/run/secrets/keyring_pass
    secrets: [keyring_pass]
    volumes:
      - /vol1/docker/cindy/data:/config
    ports: ["5800:5800"]   # 仅内网
    networks: [backend]    # 机内互通地址：cindy:5800
```

首次使用：浏览器打开 `http://<NAS>:5800` → 登录 Cindy 账号 → 设置中开启「允许被控」→
手机 App 同账号登录即可在设备列表看到这台服务器。

## 注意

- 镜像内不含任何凭据；keyring 密码只经运行时 secrets 注入
- 5800 端口无认证，仅建议内网使用
- 官方服务端闭源：手机连接的控制面依赖官方云中继，本仓库无法替代
