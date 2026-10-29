#!/bin/sh
set -e
# Railway 注入 $PORT，公网域名由 Railway 提供 TLS（443 -> 本容器 $PORT）
# 容器内 Xray 只跑明文 WS，TLS 在 Railway 边缘终结，不要在容器内再开 TLS。
PORT="${PORT:-8080}"
UUID="${UUID:?请在 Railway 环境变量里设置 UUID}"
WS_PATH="${WS_PATH:-/281322e070f2}"
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [{ "id": "${UUID}", "level": 0, "email": "railway@xray" }],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [{ "protocol": "freedom", "tag": "direct" }]
}
EOF
exec /usr/local/bin/xray -c /etc/xray/config.json
