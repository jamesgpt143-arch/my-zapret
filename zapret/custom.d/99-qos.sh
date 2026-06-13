#!/bin/sh

qos_start() {
    [ "$QOS_ENABLE" = "1" ] || return 0
    
    if ! command -v tc >/dev/null; then
        echo "QoS: 'tc' command not found! Please install 'tc' package." | logger -t zapret-qos
        return 1
    fi
    
    . /lib/functions/network.sh
    
    local WAN_IF
    local LAN_IF
    network_get_physdev WAN_IF wan
    network_get_physdev LAN_IF lan
    
    [ -z "$LAN_IF" ] && LAN_IF="br-lan"
    
    if [ -n "$WAN_IF" ] && [ "$QOS_UPLOAD" -gt 0 ]; then
        tc qdisc del dev $WAN_IF root 2>/dev/null
        tc qdisc add dev $WAN_IF root tbf rate ${QOS_UPLOAD}mbit burst 32kbit latency 400ms
        echo "QoS: Applied ${QOS_UPLOAD}Mbps upload limit on $WAN_IF" | logger -t zapret-qos
    fi
    
    if [ -n "$LAN_IF" ] && [ "$QOS_DOWNLOAD" -gt 0 ]; then
        tc qdisc del dev $LAN_IF root 2>/dev/null
        tc qdisc add dev $LAN_IF root tbf rate ${QOS_DOWNLOAD}mbit burst 32kbit latency 400ms
        echo "QoS: Applied ${QOS_DOWNLOAD}Mbps download limit on $LAN_IF" | logger -t zapret-qos
    fi
}

qos_stop() {
    if ! command -v tc >/dev/null; then
        return 0
    fi

    . /lib/functions/network.sh
    
    local WAN_IF
    local LAN_IF
    network_get_physdev WAN_IF wan
    network_get_physdev LAN_IF lan
    
    [ -z "$LAN_IF" ] && LAN_IF="br-lan"
    
    if [ -n "$WAN_IF" ]; then
        tc qdisc del dev $WAN_IF root 2>/dev/null
    fi
    if [ -n "$LAN_IF" ]; then
        tc qdisc del dev $LAN_IF root 2>/dev/null
    fi
}

case "$1" in
    start)
        qos_start
        ;;
    stop)
        qos_stop
        ;;
esac
