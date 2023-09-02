#!bin/sh

function logcmd()
{
    echo -e "\n"
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
}

dstdir="/data/ylog/"
fwc_dir="fwreboot/"
sp="-"
sys_debug_fwc=sys.debug.fwc
persist_sys_ylog_fwc=persist.sys.ylog.fwc
fwc_prop=`getprop ${sys_debug_fwc}`
time_now=$(date "+%Y%m%d%H%M%S")
count=0
if [ $fwc_prop -ge 1 ];then
    cd $dstdir
    if [ ! -d $fwc_dir ];then
        exe_cmd "mkdir $fwc_dir"
        chmod 777 $fwc_dir
    fi
    cd $fwc_dir
    count=$(getprop $persist_sys_ylog_fwc)
    if [ -z "$count" ];then
        count=0
    else
        count=$(getprop $persist_sys_ylog_fwc)
    fi
    exe_cmd "mkdir $count$sp$time_now"
    chmod 777 $count$sp$time_now
    cd $count$sp$time_now
    exe_cmd "dmesg -T > $dstdir$fwc_dir$count$sp$time_now/kernel.log"
    exe_cmd "logcat -d > $dstdir$fwc_dir$count$sp$time_now/android.log"
    chmod 666 "kernel.log"
    chmod 666 "android.log"
    count=$((count+1))
    exe_cmd "setprop $persist_sys_ylog_fwc $count"
fi
if [ $count -gt 10 ];then
    path="/data/ylog/fwreboot/"
    count=0
    min=999
    min_file="XXX"

    for dir in $(ls $path)
    do
        [ -d $dir ] && echo $dir
        count=$((count+1))
        if [ ${dir%%-*} -lt $min ];then
            min=${dir%%-*}
            min_file=$dir
        fi
        if [ $count -eq 11 ];then
            exe_cmd "rm -rf $path$min_file"
        fi
    done
fi
echo "done"
