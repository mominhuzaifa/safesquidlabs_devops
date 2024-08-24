# cpu usage
top_apps() {
    echo "Top 10 Applications by CPU Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11

    echo -e "\nTop 10 Applications by Memory Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11
}

# network monitor
network_monitor() {
    echo "Number of Concurrent Connections:"
    netstat -an | grep ESTABLISHED | wc -l

    echo -e "\nPacket Drops:"
    netstat -s | grep "packet receive errors"

    echo -e "\nNetwork Traffic (MB In/Out):"
    ifconfig | awk '/RX packets/ {print "Received: " $5/1024/1024 " MB"} /TX packets/ {print "Transmitted: " $5/1024/1024 " MB"}'
}

# disk usage
disk_usage() {
    echo "Disk Usage:"
    df -h | awk '$5 >= 80 {print "Warning: " $0} $5 < 80 {print $0}'
}

# system load/uptime
system_load() {
    echo "System Load Average:"
    uptime

    echo -e "\nCPU Usage Breakdown:"
    mpstat
}

# memory usage
memory_usage() {
    echo "Memory Usage:"
    free -m
}

# proc monitor
process_monitor() {
    echo "Number of Active Processes:"
    ps aux | wc -l

    echo -e "\nTop 5 Processes by CPU Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6

    echo -e "\nTop 5 Processes by Memory Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
}

# service monitor
service_monitor() {
    echo "Service Status:"
    for service in sshd nginx apache2 iptables; do
        systemctl is-active --quiet $service && echo "$service is running" || echo "$service is not running"
    done
}

# dashboard.
case "$1" in
    -cpu)
        top_apps
        ;;
    -network)
        network_monitor
        ;;
    -disk)
        disk_usage
        ;;
    -load)
        system_load
        ;;
    -memory)
        memory_usage
        ;;
    -process)
        process_monitor
        ;;
    -services)
        service_monitor
        ;;
    -all)
        top_apps
        network_monitor
        disk_usage
        system_load
        memory_usage
        process_monitor
        service_monitor
        ;;
    *)
        echo "Usage: $0 {-cpu|-network|-disk|-load|-memory|-process|-services|-all}"
        ;;
esac
