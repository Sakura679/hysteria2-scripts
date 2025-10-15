### 创建缺失文件（若系统中缺失则使用下方命令）
```
mkdir -p /run/openrc
touch /run/openrc/softlevel
```

# ================================
# Hysteria2 一键管理脚本

### 安装并配置
```
bash <(curl -Ls https://raw.githubusercontent.com/Sakura679/hysteria2-scripts/refs/heads/main/hysteria2_for_alpine.sh) install
```

### 卸载
```
bash <(curl -Ls https://raw.githubusercontent.com/Sakura679/hysteria2-scripts/refs/heads/main/hysteria2_for_alpine.sh) uninstall
```
# ================================

### 如果更新系统卡住，请更换镜像源
```
cat > /etc/apk/repositories <<'EOF'
https://mirrors.aliyun.com/alpine/v3.22/main/
https://mirrors.aliyun.com/alpine/v3.22/community/
EOF
```
