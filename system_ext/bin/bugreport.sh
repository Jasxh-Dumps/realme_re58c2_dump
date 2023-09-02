#!bin/sh

config="$1"

function logcmd()
{
    echo -e "\n"
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
}

function dump_bugreport()
{
    exe_cmd "bugreportz"
}

function transferBugreportLog()
{
    DATA_BUGREPORT_PATH=/data/user_de/0/com.android.shell/files/bugreports
    SDCARD_BUGREPORT_PATH=/data/ylog/bugreports
    if [ -d "${DATA_BUGREPORT_PATH}" ];then
        if [ ! -d "${SDCARD_BUGREPORT_PATH}" ];then
            exe_cmd "mkdir -p ${SDCARD_BUGREPORT_PATH}"
        fi
        exe_cmd "mv ${DATA_BUGREPORT_PATH}/* ${SDCARD_BUGREPORT_PATH}"
        chmod -R 755 $SDCARD_BUGREPORT_PATH
    fi
}

function deleteBugreportLog()
{
   if [ -d "/data/ylog/bugreports" ];then
       rm -rf /data/ylog/bugreports/*
   fi
}

case "$config" in
    "bugreport")
        dump_bugreport
        ;;
    "transfer_bugreport")
        transferBugreportLog
        ;;
    "delete_bugreport")
        deleteBugreportLog
        ;;
    *)
        ;;
esac
