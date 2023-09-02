#!bin/sh

function logcmd()
{
    echo -e "\n"
    echo -n "$@"
    echo -n " on "
    date
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
    echo -n "run finished on "
    date '+%m-%d %T'
}
loopcount=0
linecount=0
while true;do
    ylogdebug_date=$(date '+%m-%d %T')
    echo "ylogdebug_"$loopcount"  on "$ylogdebug_date
    loopcount=$(($loopcount+1))
    exe_cmd "uptime"
    exe_cmd "logcat -S"
    exe_cmd "ylogctl q"
    exe_cmd "ylogctl space"
    exe_cmd "cat /data/ylog/ylog.conf"
    if [  -d "/cache/ylog/ap/" ]; then
        exe_cmd "ls -l /cache/ylog/ap/"
    fi
    if [  -d "/data/ylog/ap/" ]; then
        exe_cmd "ls -l /data/ylog/ap/"
    fi
    if [  -d "/storage/emulated/0/ylog/ap/" ]; then
        exe_cmd "ls -l /storage/emulated/0/ylog/ap/"
    fi
    if [  -d "/storage/sdcard0/ylog/ap/" ]; then
        exe_cmd "ls -l /storage/sdcard0/ylog/ap/"
    fi
    #save /data/ylog/journal.log  to .ylog by diff file  line
    if [[ $loopcount == 1 ]]; then
        linecount=$(wc -l </data/ylog/journal.log)
        exe_cmd "cat /data/ylog/journal.log"
    else
        if [ "$(($loopcount % 60))" = "0" ];  then
            exe_cmd "cat /data/ylog/journal.log"
        else
            newlinecount=$(wc -l </data/ylog/journal.log)
            if [ $linecount -lt $newlinecount ];then
                newline=$(($linecount-1))
                linecount=$newlinecount
                exe_cmd "tail -n +"${newline}"</data/ylog/journal.log"
            fi
        fi
    fi
    echo ylogdebug end
    echo -e "\n\n\n"
    sleep 300s
done
