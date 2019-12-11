#!/bin/bash
#============================
需要安装: curl

#============================
#======================================================================
# 项目启动shell脚本
# boot目录: spring boot jar包
# config目录: 配置文件目录
# logs目录: 项目运行日志目录
# logs/startup.log: 记录启动日志
# logs/back目录: 项目运行日志备份目录
# nohup后台运行
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

# 外部配置文件绝对目录,如果是目录需要/结尾，也可以直接指定文件
# 如果指定的是目录,spring则会读取目录中的所有配置文件
CONFIG_DIR=${BASE_PATH}"/config/"

STATUS_URL='/api/v2/common/AlgoCommon/status'

SERVER_PORT=`sed '/server.port=/!d;s/.*=//' $CONFIG_DIR/application.properties | tr -d '\r'`
# 项目日志输出绝对路径
LOG_DIR=${BASE_PATH}"/logs"
LOG_FILE="${APPLICATION}.log"
LOG_PATH="${LOG_DIR}/${LOG_FILE}"
# 日志备份目录
LOG_BACK_DIR="${LOG_DIR}/back/"

# 项目启动日志输出绝对路径
LOG_STARTUP_PATH="${LOG_DIR}/startup.log"

# 当前时间
NOW=`date +'%Y-%m-%d-%H-%M-%S'`
NOW_PRETTY=`date +'%Y-%m-%d %H:%M:%S'`

# 启动日志
STARTUP_LOG="================================================ ${NOW_PRETTY} ================================================\n"

# 如果logs文件夹不存在,则创建文件夹
if [ ! -d "${LOG_DIR}" ]; then
  mkdir "${LOG_DIR}"
fi

# 如果logs/back文件夹不存在,则创建文件夹
#if [[ ! -d "${LOG_BACK_DIR}" ]]; then
#  mkdir "${LOG_BACK_DIR}"
#fi

# 如果项目运行日志存在,则重命名备份
#if [[ -f "${LOG_PATH}" ]]; then
#	mv ${LOG_PATH} "${LOG_BACK_DIR}/${APPLICATION}_back_${NOW}.log"
#fi

# 创建新的项目运行日志
#echo "" > ${LOG_PATH}

# 如果项目启动日志不存在,则创建,否则追加
#echo "${STARTUP_LOG}" >> ${LOG_STARTUP_PATH}

PIDS=`ps -ef | grep java | grep -v grep | grep "${BASE_PATH}/boot/" |awk '{print $2}'`
if [ -n "$PIDS" ]; then
    echo "ERROR: The ${BASE_PATH}/boot/ already started!"
    echo "PID: $PIDS"
    exit 1
fi

if [ -n "$SERVER_PORT" ]; then
    SERVER_PORT_COUNT=`netstat -tln | grep $SERVER_PORT | wc -l`
    if [ $SERVER_PORT_COUNT -gt 0 ]; then
        echo "ERROR: The $SERVER_NAME port $SERVER_PORT already used!"
        exit 1
    fi
fi
#==========================================================================================
# JVM Configuration
# -Xmx256m:设置JVM最大可用内存为256m,根据项目实际情况而定，建议最小和最大设置成一样。
# -Xms256m:设置JVM初始内存。此值可以设置与-Xmx相同,以避免每次垃圾回收完成后JVM重新分配内存
# -Xmn512m:设置年轻代大小为512m。整个JVM内存大小=年轻代大小 + 年老代大小 + 持久代大小。
#          持久代一般固定大小为64m,所以增大年轻代,将会减小年老代大小。此值对系统性能影响较大,Sun官方推荐配置为整个堆的3/8
# -XX:MetaspaceSize=64m:存储class的内存大小,该值越大触发Metaspace GC的时机就越晚
# -XX:MaxMetaspaceSize=320m:限制Metaspace增长的上限，防止因为某些情况导致Metaspace无限的使用本地内存，影响到其他程序
# -XX:-OmitStackTraceInFastThrow:解决重复异常不打印堆栈信息问题
#==========================================================================================
JAVA_OPT="-server -Xms1024m -Xmx2048m -Xmn512m -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=256m"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow"

#=======================================================
# 将命令启动相关日志追加到日志文件
#=======================================================

# 输出项目名称
STARTUP_LOG="${STARTUP_LOG}application name: ${APPLICATION}\n"
# 输出jar包名称
STARTUP_LOG="${STARTUP_LOG}application jar  name: ${APPLICATION_JAR}\n"
# 输出项目根目录
STARTUP_LOG="${STARTUP_LOG}application root path: ${BASE_PATH}\n"
# 输出项目bin路径
STARTUP_LOG="${STARTUP_LOG}application bin  path: ${BIN_PATH}\n"
# 输出项目config路径
STARTUP_LOG="${STARTUP_LOG}application config path: ${CONFIG_DIR}\n"
# 打印日志路径
STARTUP_LOG="${STARTUP_LOG}application log  path: ${LOG_PATH}\n"
# 打印JVM配置
STARTUP_LOG="${STARTUP_LOG}application JAVA_OPT : ${JAVA_OPT}\n"


# 打印启动命令
STARTUP_LOG="${STARTUP_LOG}application startup command: nohup java ${JAVA_OPT} -jar ${BASE_PATH}/boot/${APPLICATION_JAR} --spring.config.location=${CONFIG_DIR} -Dlogging.path=${LOG_DIR} > /dev/null 2>&1 &\n"

#======================================================================
# 执行启动命令：后台启动项目,并将日志输出到项目根目录下的logs文件夹下
#======================================================================
nohup java ${JAVA_OPT} -jar ${BASE_PATH}/boot/${APPLICATION_JAR} --spring.config.location=${CONFIG_DIR} -Dlogging.path=${LOG_DIR} > /dev/null 2>&1 &
#nohup java ${JAVA_OPT} -jar ${BASE_PATH}/boot/${APPLICATION_JAR} --spring.config.location=${CONFIG_DIR} -Dlogging.path=${LOG_DIR} > ${LOG_PATH} 2>&1 &

echo -e ${STARTUP_LOG}

COUNT=0
num=0
while [ $COUNT -lt 1 ]; do
    echo -e ".\c"
    sleep 2
    num=$(( num + 1 ))
    COUNT=`ps -ef | grep java | grep -v grep | grep "${BASE_PATH}/boot/${APPLICATION_JAR}" | awk '{print $2}' | wc -l`

    if [ $COUNT -gt 0 ]; then
        break
    fi
    if [ $num -gt 10 ]; then
        break
    fi
done
COUNT=0
num=0
while [ $COUNT -lt 1 ]; do
    echo -e ".\c"
    sleep 2
    num=$(( num + 1 ))
    COUNT=`(sleep 1; echo -e '\n'; sleep 1; echo status; sleep 1)| curl 127.0.0.1:${SERVER_PORT}${STATUS_URL} | grep -c status_ok`
    if [ $COUNT -gt 0 ]; then
        break
    fi
    if [ $num -gt 100 ]; then
        exit 1;
    fi
done

# 进程ID
PID=$(ps -ef | grep "${BASE_PATH}/boot/${APPLICATION_JAR}" | grep -v grep | awk '{ print $2 }')
STARTUP_LOG="${STARTUP_LOG}application pid: ${PID}\n"

# 启动日志追加到启动日志文件中
echo -e ${STARTUP_LOG} >> ${LOG_STARTUP_PATH}
# 打印启动日志
echo -e ${STARTUP_LOG}

# 是否tail日志
tail_flag=$1
echo ${tail_flag}
if [ ${tail_flag}a = 'notail'a ]; then
  exit 0;
fi
# 打印项目日志
#cd $LOG_DIR
latest_file=`ls -ltr $LOG_DIR/ |grep logback | tail -1 | awk '{print $9}'`
if [ -n "${latest_file}" ]; then
  echo "tail -f ${LOG_DIR}/${latest_file}"
  tail -f ${LOG_DIR}/${latest_file}
fi
