#!/system/bin/sh

for rs_interval in `ls /proc/sys/net/ipv6/conf/seth_lte*/router_solicitation_interval`
do
    echo 1 > $rs_interval
done

for rs_interval in `ls /proc/sys/net/ipv6/conf/sipa_eth*/router_solicitation_interval`
do
    echo 1 > $rs_interval
done

for addr_gm in `ls /proc/sys/net/ipv6/conf/seth_lte*/addr_gen_mode`
do
    echo 1 > $addr_gm
done

for addr_gm in `ls /proc/sys/net/ipv6/conf/sipa_eth*/addr_gen_mode`
do
    echo 1 > $addr_gm
done
