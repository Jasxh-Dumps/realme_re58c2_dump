#!/vendor/bin/sh

spl_a="0:0:0:1/block"
spl_b="0:0:0:2/block"

ln_number=0
ln_number_max=2
while [ $ln_number -lt $ln_number_max ] && ([ ! -h /dev/block/by-name/spl_a ] || [ ! -h /dev/block/by-name/spl_b ])
do
  ln_number=`expr $ln_number + 1`
  if [ -e /sys/class/block/sda ]; then
    sda=`find /sys/devices/platform/soc -name sda`
    sdb=`find /sys/devices/platform/soc -name sdb`
    sdc=`find /sys/devices/platform/soc -name sdc`

    res=$(echo $sda | grep "${spl_a}")
    if [ "$res" != "" ]
    then
      ln -s /dev/block/sda /dev/block/by-name/spl_a
    fi
    res=$(echo $sdb | grep "${spl_a}")
    if [ "$res" != "" ]
    then
      ln -s /dev/block/sdb /dev/block/by-name/spl_a
    fi
    res=$(echo $sdc | grep "${spl_a}")
    if [ "$res" != "" ]
    then
      ln -s /dev/block/sdc /dev/block/by-name/spl_a
    fi

    res=$(echo $sda | grep "${spl_b}")
    if [ "$res" != "" ]
    then
      ln -s /dev/block/sda /dev/block/by-name/spl_b
    fi
    res=$(echo $sdb | grep "${spl_b}")
    if [ "$res" != "" ]
    then
      ln -s /dev/block/sdb /dev/block/by-name/spl_b
    fi
    res=$(echo $sdc | grep "${spl_b}")
    if [ "$res" != "" ]
    then
      ln -s /dev/block/sdc /dev/block/by-name/spl_b
    fi
  else
    ln -s /dev/block/mmcblk0boot0 /dev/block/by-name/spl_a
    ln -s /dev/block/mmcblk0boot1 /dev/block/by-name/spl_b
  fi
done
