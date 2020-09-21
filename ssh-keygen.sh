#!/bin/bash
#使用本脚本需要在创建/tmp/hosts文件，写入所有主机信息和密码格式为    hostname password
rpm -qa|grep expect &>/dev/null
[ "$(echo $?)" != "0" ] && yum -y install expect &>/dev/null && echo "expect install successfully" || echo "expect already exists!"



num=`cat /tmp/hosts | wc -l`

for i in `seq 1 $num`
do
    hostname=`sed -n "${i}p" /tmp/hosts|awk '{print $1}'`
    passwd=`sed -n "${i}p" /tmp/hosts|awk '{print $2}'`
    /usr/bin/expect <<EOF
    set timeout 300
    spawn ssh-keygen
    expect "/root/.ssh/id_rsa"
    send "\n"
    expect {
            "Overwrite" { send "no\n" }
            "passphrase" { send "\n"; exp_continue }
            "again" { send "\n" }
    }

    spawn ssh-copy-id -i $hostname
    expect {
            "yes/no" { send "yes\n"; exp_continue }
            "password" { send "${passwd}\n" }
    }
    expect eof
EOF
done
#执行完成后删除主机清单
#rm -rf /tmp/hosts

