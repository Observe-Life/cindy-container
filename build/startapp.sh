#!/bin/bash
# Cindy 启动：D-Bus 会话总线 + 解锁 keyring（Secret Service）+ 无沙箱 + 显式凭据后端
set -e
PREFIX="${CINDY_PREFIX:-/opt/cindy-build/.local/opt/cindy}"
LAUNCH="$PREFIX/current/launch"
[ -x "$LAUNCH" ] || { echo "[startapp] launcher 缺失: $LAUNCH"; ls -la "$PREFIX" || true; exit 1; }

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval "$(dbus-launch --sh-syntax)"
fi

# 密钥来源：KEYRING_PASS 环境变量，或 KEYRING_PASS_FILE（docker secrets）
if [ -z "$KEYRING_PASS" ] && [ -n "$KEYRING_PASS_FILE" ] && [ -r "$KEYRING_PASS_FILE" ]; then
  KEYRING_PASS="$(tr -d '[:space:]' < "$KEYRING_PASS_FILE")"
fi

if [ -n "$KEYRING_PASS" ]; then
  # 无 keyring 时用该密码创建 default keyring 并解锁；libsecret 经 session bus 使用
  ( echo -n "$KEYRING_PASS" | gnome-keyring-daemon -r --unlock --components=secrets >/dev/null 2>&1 & )
  sleep 1
else
  echo "[startapp] 警告: 未提供 keyring 密码, Cindy 将无法保存登录态" >&2
fi

cd /config
exec "$LAUNCH" --no-sandbox --password-store=gnome-libsecret "$@"
