#!/bin/bash

#======================================================================
# 项目重启shell脚本
# 先调用shutdown.sh停服
# 然后调用startup.sh启动服务
#
# author: geekidea
# date: 2018-12-2
#======================================================================
DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ];then
    CUR=`dirname $DIRNAME`
else
    CUR="`pwd`"/"`dirname $DIRNAME`"
fi
# 项目名称
APPLICATION="@project.name@"

# 项目启动jar包名称
APPLICATION_JAR="@build.finalName@.xjar"

# 停服
echo stop ${APPLICATION} Application...
sh $CUR/shutdown.sh

# 启动服务
echo start ${APPLICATION} Application...
sh $CUR/startup.sh "$@"