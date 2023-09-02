#!/usr/bin/bash
while getopts "c:g:d:t:i:f:" opt
do
    case $opt in
        c)
        cd
        echo "\ncpu_loading:"
        ./vendor/bin/power/cpu/loading/cpu_loading -t $OPTARG
        ;;
        g)
        cd
        echo "\ngpu_loading:"
        ./vendor/bin/power/gpu/loading/gpu_loading -t $OPTARG
        ;;
        d)
        cd
        echo "\nddr_loading:"
        ./vendor/bin/power/ddr/loading/ddr_loading -t $OPTARG
        ;;
        t)
        cd
        echo "\nthread_top:"
        ./vendor/bin/power/tops/tops -t $OPTARG
        ;;
        i)
        cd
        echo "\ninterrupts:"
        ./vendor/bin/power/interrupt/interrupt  -t $OPTARG
        ;;
        f)
        cd
        echo "\nfps:"
        ./vendor/bin/power/frame/fps_sf -t $OPTARG
        ;;
    esac
done