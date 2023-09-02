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

function create_new_file()
{
    echo -n "YZIPC02"
    echo -n $1
    echo -n $2
    echo -n "20CPIZY"
}

create_new_file "lastlog/kernel.log"
exe_cmd "cat /data/ylog/lastkernel.log"

create_new_file "lastlog/error.log"
exe_cmd "cat /data/ylog/dmesg.log"

create_new_file "lastlog/android.log"
exe_cmd "ylogkat -L -f /data/ylog/lastandroid.log"

create_new_file "lastlog/lastkmsg.log"
exe_cmd "ylogkat -K"

echo -e "\n"
create_new_file "lastlog/lastylogbuffer.log"
exe_cmd "ylogkat -Y"

sleep 1024h
