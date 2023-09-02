#!/vendor/bin/sh

if [ $# -eq 1 ]; then
	cfg_file=$1
elif [ $# -eq 2 ]; then
	cfg_file=$1
	if [[ $2 == "cali" || $2 == "charger" ]]; then
		bootmode=".$2"
	else
		bootmode=
	fi
else
	# Set property even if there is no insmod config
	# to unblock early-boot trigger
	setprop vendor.all.modules.ready 1
	exit 1
fi

if [ -f $cfg_file ]; then
	while IFS="|" read -r action arg
	do
		args=`echo $arg | sed 's/|/ /g'`
		case $action in
			"insmod") insmod $args ;;
			"setprop") setprop $arg 1 ;;
			"enable") echo 1 > $arg ;;
			"modprobe")
				case $(arg) in
					"-b *" | "-b")
						arg="-b $(cat /vendor/lib/modules/modules.load$bootmode)" ;;
					 "*"|"")
						arg="$(cat /vendor/lib/modules/modules.load$bootmode)" ;;
				esac
				modprobe -s -a -d /vendor/lib/modules $arg ;;
			"modprobe_gki_modules")
				case $(arg) in
					 "*"|"")
						arg="$(cat /system/lib/modules/modules.load)" ;;
				esac
				modprobe -s -a -d /system/lib/modules $arg ;;
		esac
	done < $cfg_file
fi
