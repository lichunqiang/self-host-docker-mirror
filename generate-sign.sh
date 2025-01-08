#!/bin/bash

# 检查是否提供了域名和 IP 地址
if [ $# -ne 2 ]; then
    echo "用法: $0 <域名> <IP 地址>"
    exit 1
fi

# 参数: 域名和 IP 地址
DOMAIN=$1
IP=$2

# 生成私钥
openssl genrsa -out "$DOMAIN".key 2048

# 生成证书签名请求 (CSR)
openssl req -new -key "$DOMAIN".key -subj "/CN=$DOMAIN" -out "$DOMAIN".csr

# 生成配置文件，添加 IP SAN
cat > "$DOMAIN".ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
IP.1 = $IP
EOF

# 使用配置文件生成自签名证书
openssl x509 -req -in "$DOMAIN".csr -signkey "$DOMAIN".key -out "$DOMAIN".crt -days 365 -extfile "$DOMAIN".ext

# 清理临时文件
rm -f "$DOMAIN".csr "$DOMAIN".ext

echo "证书生成成功: $DOMAIN.crt"
echo "私钥: $DOMAIN.key"
