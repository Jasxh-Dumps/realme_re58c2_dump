#!bin/sh

function logcmd()
{
    #echo -e "\n"
    echo -n "$@"
    echo -n " on "
    date '+%m-%d %T'
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
}

function printdebuginfo()
{
    echo "DebuginfoBegin"
    exe_cmd "wc -c < "$@
    exe_cmd "stat "$@
    exe_cmd "du -h "$@
    exe_cmd "ls -lZ /data/anr "
    FILE_SIZE=$(wc -c <"$@")
    echo "filesize="$FILE_SIZE
    echo "DebuginfoEnd"
}

count=0
tmppath=""
created_logfile=""
closed_logfile=""
writed_logfile=""
created_date=""
ylogtrace_created=0
duplcate_create_event=0
format_pb=".pb"
while true;do
    inotifywait -mq  -e 'create,close_write' /data/anr/ /data/tombstones/\
    |while read FILE;do
        out=$FILE
        find="CREATE"
        if [[ $out == *$find* ]]; then
            tmppath=${FILE/ CREATE /}
            created_date=$(date '+%m-%d %T')
            if [[$tmppath == *$format_pb*]];then
                continue
            fi
            created_logfile=$tmppath
            #echo "created_logfile:",$created_logfile
            #echo "closed_logfile:",$closed_logfile
            if [ "$created_logfile" == "$closed_logfile" ]; then
                duplcate_create_event=1
            else
                duplcate_create_event=0
            fi
       else
            if [ $duplcate_create_event -eq 1 ];then
                continue
            fi
            tmppath=${FILE/ CLOSE_WRITE,CLOSE /}
            closed_logfile=$tmppath
            if [ ! -f "$closed_logfile" ]; then
                closed_logfile=$created_logfile
            fi
            if [ "$writed_logfile" == "$closed_logfile" ]; then
                continue
            fi
            #echo $closed_logfile
            echo "YZIPC02traces/"$(date '+%m-%d_%H%M%S')"--"${closed_logfile##*/}".log20CPIZY"
            echo "traceno_"$count" "$closed_logfile" on "$created_date
            count=$(($count+1))
            writed_logfile=$closed_logfile

            sleep 5s
            exe_cmd "cat "${closed_logfile}
            sh /system_ext/bin/sysinfo.sh 1
            ylogctl logcat android
            ylogctl logcat kernel

            echo "trace end\n\n\n"
            if [ $ylogtrace_created -lt 1 ];then
                ylogtrace_created=1
                rootdir=$(/system/bin/ylogctl root)
                aplogdir=${rootdir/ap/}
                ls -l /data/anr/>/data/ylog/ylogtrace.info
                chmod 0777 /data/ylog/ylogtrace.info
                ls -l /data/anr/>$aplogdir/ylogtrace.info
            fi
        fi
    done
done





