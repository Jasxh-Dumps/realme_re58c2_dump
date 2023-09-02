#!/vendor/bin/sh
while :
do
        time=`uptime | awk '{print $3}'`
        if [ $time -lt 4 ]; then
                sleep 10
        else
                setprop vendor.zram.writeback idle
                sleep 2
                setprop vendor.zram.writeback idle_fast
                break
        fi
done

