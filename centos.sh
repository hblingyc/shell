#!/usr/bin/bash
#by YING
#time 2020-04-01
#防火墙设置
echo "关闭防火墙和selinux"
        systemctl stop firewalld && systemctl disable firewalld && setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        if [ $? -eq 0 ];then
                echo "防火墙已关闭且开机不自启"
        else
                echo "防火墙关闭失败请手动查看"
                exit 1
        fi
        sleep 2
#安装相关配置常用工具
        yum install -y lrzsz sysstat  elinks wget vim net-tools bash-completion &>/dev/null
        if [ $? -eq 0 ];then
                echo "安装工具成功"
        else
                echo "安装工具失败，请检查yum源"
                exit 2
        fi
        sleep 2
#配置固定IP地址
chack_ip(){
        sed -i.bak 's/BOOTPROTO="dhcp"/BOOTPROTO="none"/' /etc/sysconfig/network-scripts/ifcfg-ens33
        ip=`ip a | grep ens33 |grep inet |awk '{print $2}' | awk -F"/" '{print $1}'`
        net=255.255.255.0
        gate=`route -n |awk 'NR==3{print $2}'`
        dns=`cat /etc/resolv.conf |grep nameserver |awk '{print $2}'`
}
chack_ip
(
cat <<EOF
IPADDR=$ip
NETMASK=$net
GATEWAY=$gate
DNS1=$dns
EOF
) >> /etc/sysconfig/network-scripts/ifcfg-ens33
        systemctl restart network
        if [ $? -eq 0 ];then
                echo "配置IP地址成功"
        else
                echo "配置IP地址失败，请手动查看"
                exit 3
        fi
        sleep 2
#配置yum源-这里选用阿里源
        mv /etc/yum.repos.d/*.repo /tmp
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
        echo "查看下载的yum源：" $(ls /etc/yum.repos.d)
        sleep 2
        exit 0

