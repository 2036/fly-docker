#!/bin/sh
#ssh
service ssh restart
mkdir /tmp/v2ray
curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl

# Remove temporary directory
rm -rf /tmp/v2ray

# V2Ray new configuration
install -d /usr/local/etc/v2ray
cat <<-EOF > /usr/local/etc/v2ray/config.json
{
  "inbounds": [
  {
    "port": 8080,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "d0e98360-9100-4582-9d5b-1a35a0166e15",
          "alterId": 4       
        }
      ]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
      "path": "/ws"
      }     
    }
  }
  ],
  "outbounds": [
  {
    "protocol": "freedom",
    "settings": {}
  }
  ]
}
EOF
# Run V2Ray
nohup /usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json >v2.txt 2>&1 &

nohup /linux_amd64/sunny clientid a089fd92ca6ebdc7 >ssh.txt 2>&1 &

VERSION=$(/usr/local/bin/v2ray --version |grep V |awk '{print $2}')
REBOOTDATE=$(date)
sed -i "s/VERSION/$VERSION/g" /wwwroot/index.html
sed -i "s/REBOOTDATE/$REBOOTDATE/g" /wwwroot/index.html

caddy -conf="/etc/Caddyfile"
