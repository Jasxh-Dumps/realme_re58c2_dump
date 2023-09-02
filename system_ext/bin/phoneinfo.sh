#!bin/sh

function logcmd()
{
    echo -e "\n"
    echo "$@"
    date
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
}


echo phoneinfo start
exe_cmd "cat /proc/cmdline"
exe_cmd "cat /proc/version"
exe_cmd "cat /proc/meminfo"
exe_cmd "cat /proc/slabinfo"
exe_cmd "cat /proc/mounts"
exe_cmd "cat /proc/diskstats"
exe_cmd "cat /proc/modules"
exe_cmd "cat /proc/cpuinfo"
exe_cmd "getprop"
exe_cmd "ylogctl q"
sleep 60s
echo phoneinfo end
echo poweron start
fwc=$(getprop sys.debug.fwc)
fwce="1"
date
exe_cmd "uptime"
retVal=$(/system/bin/ylogctl file)
logcmd "the log file is $retVal"

while true;do
    if [  -d "/data/ylog/ap/" ]; then
        break
    fi
    sleep 1s
done
exe_cmd "getprop>/data/ylog/phone.info"
exe_cmd "chmod 0777 /data/ylog/phone.info"
if [ "$fwc" = "$fwce" ];then
    exe_cmd "echo 'dummy'>/data/ylog/fwcrash.info"
    exe_cmd "chmod 0777 /data/ylog/fwcrash.info"
fi

sleep 1024h

echo poweron end
