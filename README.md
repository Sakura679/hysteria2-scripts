### 创建缺失文件（若系统中缺失则使用下方命令）
```
mkdir -p /run/openrc
touch /run/openrc/softlevel
```
### debian系统
安装
```
bash <(curl -fsSL https://get.hy2.sh/)
```

自签证书
```
openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt -subj "/CN=bing.com" -days 36500 && sudo chown hysteria /etc/hysteria/server.key && sudo chown hysteria /etc/hysteria/server.crt
```

配置
```
cat > /etc/hysteria/config.yaml <<'EOF'
listen: :40443

#acme:
#  domains:
#    - ak-hk01.fxhacc.ip-ddns.com
#  email: k0uyhock@deepmails.org

tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key

auth:
  type: password
  password: 542adf56e21f97
  
masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
EOF
```

设置开机自启
```
systemctl enable hysteria-server.service
```

重启Hysteria2
```
systemctl restart hysteria-server.service
```

查看Hysteria2状态
```
systemctl status hysteria-server.service
```

停止Hysteria2
```
systemctl stop hysteria-server.service
```

### alpine系统
安装
```
bash <(curl -Ls https://raw.githubusercontent.com/Sakura679/hysteria2-scripts/refs/heads/main/hysteria2_for_alpine.sh) install
```
卸载
```
bash <(curl -Ls https://raw.githubusercontent.com/Sakura679/hysteria2-scripts/refs/heads/main/hysteria2_for_alpine.sh) uninstall
```

### 如果更新系统卡住，请更换镜像源
```
cat > /etc/apk/repositories <<'EOF'
https://mirrors.aliyun.com/alpine/v3.22/main/
https://mirrors.aliyun.com/alpine/v3.22/community/
EOF
```
