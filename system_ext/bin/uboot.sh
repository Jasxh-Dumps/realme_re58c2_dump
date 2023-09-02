#!bin/sh


function exe_cmd()
{
    eval $@;
}

exe_cmd "cat /dev/block/by-name/uboot_log"

sleep 1024h

echo ubootlog end
