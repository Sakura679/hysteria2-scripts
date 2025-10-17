#!/bin/bash

# ================================
# Hysteria2 一键管理脚本
# 使用方式:
#   1、下载后使用
#   bash hysteria.sh install    安装并配置
#   bash hysteria.sh uninstall  卸载
#   2、直接远程调用
#   bash <(curl -Ls https://raw.githubusercontent.com/Sakura679/hysteria2-scripts/refs/heads/main/hysteria2_for_alpine.sh) install    安装并配置
#   bash <(curl -Ls https://raw.githubusercontent.com/Sakura679/hysteria2-scripts/refs/heads/main/hysteria2_for_alpine.sh) uninstall  卸载
# ================================

# 全局变量
PORT=40443
FAKE_DOMAIN=bing.com
CONFIG_DIR="/etc/hysteria"
BIN_PATH="/usr/local/bin/hysteria"
INIT_PATH="/etc/init.d/hysteria"
PID_FILE="/var/run/hysteria.pid"

# 随机密码生成
generate_random_password() {
  dd if=/dev/urandom bs=18 count=1 status=none | base64
}

# 写 Hysteria 配置
write_config() {
  local GENPASS="$1"
  cat << EOF > "$CONFIG_DIR/config.yaml"
listen: :$PORT

#有域名，使用CA证书
#acme:
#  domains:
#    - $FAKE_DOMAIN
#  email: xxx@gmail.com

#使用自签名证书
tls:
  cert: $CONFIG_DIR/server.crt
  key: $CONFIG_DIR/server.key

auth:
  type: password
  password: $GENPASS

masquerade:
  type: proxy
  proxy:
    url: https://$FAKE_DOMAIN/
    rewriteHost: true
EOF
}

# 写 OpenRC 自启动脚本
write_autostart() {
  cat << EOF > "$INIT_PATH"
#!/sbin/openrc-run

name="hysteria"

command="$BIN_PATH"
command_args="server --config $CONFIG_DIR/config.yaml"

pidfile="$PID_FILE"

command_background="yes"

depend() {
        need networking
}
EOF
  chmod +x "$INIT_PATH"
}

# 安装函数
install_hysteria() {
  apk update && apk upgrade
  apk add --no-cache wget curl git openssh openssl openrc

  echo "正在下载 Hysteria2..."
  mv /usr/local/bin/hysteria-linux-amd64 "$BIN_PATH"
  chmod +x "$BIN_PATH"

  echo "正在生成自签名证书 (有效期 825 天)..."
  mkdir -p "$CONFIG_DIR"
  openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) \
    -keyout "$CONFIG_DIR/server.key" -out "$CONFIG_DIR/server.crt" \
    -subj "/CN=$FAKE_DOMAIN" -days 825

  GENPASS="$(generate_random_password)"
  echo "正在写入配置文件..."
  write_config "$GENPASS"

  echo "正在配置自启动..."
  write_autostart
  rc-update add hysteria
  service hysteria start

  echo "------------------------------------------------------------------------"
  echo "hysteria2 已经安装完成"
  echo "默认端口： $PORT"
  echo "密码： $GENPASS"
  echo "伪装域名（SNI）： $FAKE_DOMAIN"
  echo "配置文件： $CONFIG_DIR/config.yaml"
  echo "已随系统自动启动"
  echo "查看状态： service hysteria status"
  echo "重启： service hysteria restart"
  echo
  echo "节点分享链接： hysteria2://$GENPASS@你的服务器IP:$PORT?sni=$FAKE_DOMAIN"
  echo "------------------------------------------------------------------------"
}

# 卸载函数
uninstall_hysteria() {
  echo "正在停止 hysteria 服务..."
  service hysteria stop 2>/dev/null

  echo "正在移除自启动..."
  rc-update del hysteria 2>/dev/null

  echo "正在删除文件..."
  rm -f "$BIN_PATH"
  rm -rf "$CONFIG_DIR"
  rm -f "$INIT_PATH"
  rm -f "$PID_FILE"

  echo "清理完成！"
  echo "hysteria2 已彻底卸载。"
}

# 主入口
case "$1" in
  install)
    install_hysteria
    ;;
  uninstall)
    uninstall_hysteria
    ;;
  *)
    echo "用法: $0 {install|uninstall}"
    exit 1
    ;;
esac
