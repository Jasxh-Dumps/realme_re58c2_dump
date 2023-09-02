#!/system/bin/sh

ip_m_log() {
    local tag="$1"
    shift

    log -p d -t "${tag}-$$" "$@"
}

ipxfrm_monitor() {
    ip xfrm monitor | while read line; do
        ip_m_log "ipxfrm_monitor" "$line"
    done
}

ip_monitor() {
    ip monitor | while read line; do
        ip_m_log "ip_monitor" "$line"
    done
}

# ip xfrm monitor is only available on userdebug, as it will dump
# the secret key used in ipsec. This may cause a security risk!
[ "$(getprop ro.debuggable)" -eq 1 ] && ipxfrm_monitor &

ip_monitor
