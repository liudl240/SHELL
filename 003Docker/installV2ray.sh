#!/bin/bash
#james.liu
#Thu Feb 14 15:18:34 CST 2019
#自动安装翻墙脚本

#安装docker
install_docker(){
wget -O docker-ce.rpm https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-18.09.2-3.el7.x86_64.rpm && \
yum -y install docker-ce.rpm && \
systemctl start docker && \
systemctl enable docker && \
echo -e "\033[32m安装docker-ce成功\033[0m" || echo  "安装docker-ce失败"
}
#配置配置文件
fix_config(){
cat config.json <<EOF
{
  "log" : {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbound": {
    "port": $port,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "`uuidgen`",
          "level": 1,
          "alterId": 64
        }
      ]
    }
  },
  "inboundDetour": [
   {
     "protocol": "shadowsocks",
     "port": 4422,
     "settings": {
      "method": "aes-256-cfb",
      "password": "731d262914a1",
      "udp": true
     }
    }
  ],
  "outbound": {
    "protocol": "freedom",
    "settings": {}
  },
  "outboundDetour": [
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "strategy": "rules",
    "settings": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "127.0.0.0/8",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        }
      ]
    }
  }
}
EOF
}
installV2ray(){
docker run -d --name v2ray -v `pwd`/config.json:/etc/v2ray/config.json -p $port:$port v2ray/official  v2ray -config=/etc/v2ray/config.json
}


#开启防火墙和开启路由
openport(){
iptables -A INPUT -p tcp --dport $port -j ACCEPT
echo "iptables 开放端口"
argv=$(sysctl  net.ipv4.ip_forward |awk -F"=" '{print $2}')
if [ $argv -eq 0 ];then
	echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
	systemctl  net.ipv4.ip_forward=1
	sysctl -p
fi
}
main_install(){
read -p "输入需要监听的端口【8888】:" port
netstat -anptul|grep -i listen |awk  '{print $4}'|awk -v port=$port -F ":" '{if ($2==port) exit 10}'
if [ $? -eq 10 ];then
	echo -e "\033[31m$port 端口在占用\033[0m"
	exit 2
else
install_docker
fix_config
installV2ray
openport
fi
}
main_install
