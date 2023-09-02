#!bin/sh

function logcmd()
{
    echo -e "\n"
    echo -n "$@"
    echo -n " on "
    date '+%m-%d %T'
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
    echo -n "run finished on "
    date '+%m-%d %T'
}


count=0
while true;do
    sysinfo_date=$(date '+%m-%d %T')
    echo "sysinfo_"$count"  on "$sysinfo_date
    count=$(($count+1))
    #temprature
    exe_cmd "cat /sys/class/thermal/thermal_zone23/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone24/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone25/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone26/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone27/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone19/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone20/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone21/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone22/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone28/temp"
    exe_cmd "cat /sys/class/thermal/thermal_zone21/temp"
    #charge
    exe_cmd "cat /sys/class/power_supply/usb/type"
    exe_cmd "cat /sys/class/power_supply/ac/type"
    exe_cmd "cat /sys/class/power_supply/wireless/type"
    exe_cmd "cat /sys/class/power_supply/sc27xx-fgu/constant_charge_voltage"
    exe_cmd "cat /sys/class/power_supply/sc2703_charger/input_current_now"
    exe_cmd "cat /sys/class/power_supply/sc27xx-fgu/constant_charge_voltage"
    exe_cmd "cat /sys/class/power_supply/eta6937_charger/input_current_now"
    exe_cmd "cat /sys/class/power_supply/battery/charge_control_limit"
    exe_cmd "cat /sys/class/power_supply/battery/voltage_now"
    exe_cmd "cat /sys/class/power_supply/battery/current_now"
    exe_cmd "cat /sys/class/power_supply/battery/constant_charge_current"
    exe_cmd "cat /sys/class/power_supply/battery/capacity"
    #power dissipation
    exe_cmd "cat /proc/meminfocat /sys/class/backlight/sprd_backlight/brightness"
    exe_cmd "cat /sys/devices/system/cpu/online"
    exe_cmd "cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq"
    exe_cmd "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    exe_cmd "cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq"
    exe_cmd "cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
    exe_cmd "cat /sys/class/devfreq/60000000.gpu/cur_freq"
    exe_cmd "cat /sys/class/devfreq/60000000.gpu/max_freq"
    exe_cmd "dumpsys cpuinfo | grep Load"
    exe_cmd "dumpsys cpuinfo | grep % | head -n 1"
    exe_cmd "dumpsys cpuinfo | grep % | head -n 2 | tail -n 1"
    exe_cmd "dumpsys cpuinfo | grep % | head -n 3 | tail -n 1"
    exe_cmd "dumpsys window | grep mCurrentFocus"
    exe_cmd "cat /d/pvr/status | grep GPU"
    exe_cmd "getprop gsm.network.type"
    exe_cmd "dumpsys telephony.registry | grep mSignalStrength | head -n 1"
    exe_cmd "dumpsys wifi | grep Stay-awake"
    echo "thermal end\n\n\n"
    if [[ $1 == 1 ]]; then
        break
    fi
    #print thermal log every 1m
    sleep 60s
done
