#!/bin/bash

#======================================================================
# 项目停服shell脚本
# 通过项目名称查找到PID
# 然后kill -9 pid
#
# author: geekidea
# date: 2018-12-2
#======================================================================

# 项目名称
APPLICATION="@project.name@"

# 项目启动jar包名称
APPLICATION_JAR="@build.finalName@.xjar"

# bin目录绝对路径
BIN_PATH=$(cd `dirname $0`; pwd)
# 进入bin目录
cd `dirname $0`
# 返回到上一级项目根目录路径
cd ..
# 打印项目根目录绝对路径
# `pwd` 执行系统命令并获得结果
BASE_PATH=`pwd`

PID=$(ps -ef | grep -v grep | grep "${BASE_PATH}/boot/" | awk '{ print $2 }')
if [ -z "${PID}" ];
then
    echo ${APPLICATION} is already stopped
else
    echo kill  ${PID}
    kill -9 ${PID}
    echo ${APPLICATION} stopped successfully
    COUNT=0
    while [ $COUNT -lt 1 ]; do
        echo -e ".\c"
        sleep 1
        COUNT=1
        PID_EXIST=`ps -fp ${PID} | grep java`
            if [ -n "${PID_EXIST}" ]; then
                COUNT=0
                break
            fi
    done
fi

echo "OK!"
echo "PID: $PID"