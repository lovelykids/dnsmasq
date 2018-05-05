#!/bin/sh
###仅限潘多拉与openwrt类固件使用###

###请将DNS设置为lan网关###


###该脚本只需要运行一次###

# 移动到用户命令文件夹
cd /

# 创建广告规则与更新脚本存放的文件夹 
mkdir -p /etc/dnsmasq/adblocks

# dnsmasq.conf 添加广告规则路径
cat >> /etc/dnsmasq.conf <<EOF
# 并发查询所有上游DNS
all-servers
# 按顺序查询上游DNS
# strict-order
# 添加监听地址（将10.0.0.1修改为你的lan网关ip）
listen-address=10.0.0.1,127.0.0.1
# 添加上游DNS服务器
resolv-file=/etc/dnsmasq/resolv.conf
# 添加广告规则路径
addn-hosts=/etc/dnsmasq/ad.hosts
addn-hosts=/etc/dnsmasq/gg.hosts
EOF

# 创建上游DNS配置文件
cat > /etc/dnsmasq/resolv.conf <<EOF
nameserver 127.0.0.1
nameserver 114.114.114.119
nameserver 223.5.5.5
nameserver 119.29.29.29
EOF

# 下载广告缓存
wget --no-check-certificate -qO - https://raw.githubusercontent.com/lovelykids/dnsmasq/master/ad  > /etc/dnsmasq/ad.hosts
wget --no-check-certificate -qO - https://raw.githubusercontent.com/lovelykids/dnsmasq/master/gg > /etc/dnsmasq/gg.hosts
# 合并广告规则缓存
#cat /etc/dnsmasq/adblocks/simpleu /etc/dnsmasq/adblocks/yhosts > /etc/dnsmasq/adblocks/noad
# 删除下载缓存

# 重启dnsmasq服务
/etc/init.d/dnsmasq restart


# 创建广告规则更新脚本
cat > /etc/dnsmasq/hosts_update.sh <<EOF
#!/bin/sh
# 移动到用户命令文件夹
cd /etc/dnsmasq/
rm -rf *.hosts
wget --no-check-certificate -qO - https://raw.githubusercontent.com/lovelykids/dnsmasq/master/ad  > /etc/dnsmasq/ad.hosts
wget --no-check-certificate -qO - https://raw.githubusercontent.com/lovelykids/dnsmasq/master/gg > /etc/dnsmasq/gg.hosts
/etc/init.d/dnsmasq restart
EOF

# 注入每8小时更新一次的任务
http_username=`nvram get http_username`
cat >> /etc/crontabs/$http_username <<EOF
8 */8 * * * /bin/sh /etc/dnsmasq/hosts_update.sh
EOF
