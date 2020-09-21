#!/bin/bash
#auto backup musql db
#2020年7月19日

bakdir=/data/backup/`date +%Y-%m-%d`
mysqldb=company
mysqluse=root
mysqlpw=123
mysqlcmd=/usr/local/mysql/bin/mysqldump

#判断备份用户是否是root用户
if [ $UID -ne 0 ];then
	echo "Must to be use root for exec shell"
	exit
fi

#判断备份目录是否存在，不在则创建
if [ ! -d $bakdir ];then
	mkdir -p $bakdir
        echo "\033[32mThe $bakdir Create Successfullyl"
else
	echo "This $bakdir is exists..."
fi

#正式备份数据库
$mysqlcmd -u$mysqluse -p$mysqlpw -d $mysqldb > $bakdir/$mysqldb.sql

#判断数据库备份是否成功
if [ $? -eq 0 ];then
	echo -e "\033[32mThe mysql backup $mysqldb Successfullyl"
else
	echo -e "\033[32mThe mysql backup $mysqldb Failed.Please check"
fi

#为节约硬盘空间，将数据库压缩
tar zPcf $bakdir/$mysqldb.tar.gz $bakdir/$mysqldb.sql > /dev/null

#删除原始文件，只留压缩后文件
rm -rf $bakdir/$mysqldb.sql

#删除10天前的文件
find ${bakdir} -name "*.tar.gz" -mtime +10 -exec rm -rfv {} \;
exit 0
