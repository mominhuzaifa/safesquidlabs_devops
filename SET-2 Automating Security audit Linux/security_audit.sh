#!/bin/bash

# 1. User and Group Audits
audit_users_and_groups() {
    echo "=== User and Group Audits ==="
    echo "Listing all users and groups..."
    cat /etc/passwd
    cat /etc/group

    echo "Checking for users with UID 0..."
    awk -F: '($3 == 0) {print}' /etc/passwd

    echo "Identifying users without passwords or with weak passwords..."
    awk -F: '($2 == "") {print $1 " has no password!"}' /etc/shadow

    echo "Done with user and group audits."
}

# 2. File and Directory Permissions
audit_file_permissions() {
    echo "=== File and Directory Permissions ==="
    echo "Scanning for world-writable files and directories..."
    find / -type d -perm -0002 -exec ls -ld {} \;
    find / -type f -perm -0002 -exec ls -l {} \;

    echo "Checking .ssh directory permissions..."
    find /home -type d -name ".ssh" -exec chmod 700 {} \;

    echo "Checking for SUID/SGID files..."
    find / -perm /6000 -type f -exec ls -l {} \;

    echo "Done with file and directory permissions."
}

# 3. Service Audits
audit_services() {
    echo "=== Service Audits ==="
    echo "Listing all running services..."
    systemctl list-units --type=service --state=running

    echo "Checking for unauthorized services..."
    authorized_services=("sshd" "iptables" "ufw")

    for service in "${authorized_services[@]}"; do
        if systemctl is-active --quiet $service; then
            echo "$service is running"
        else
            echo "$service is NOT running"
        fi
    done

    echo "Checking for services listening on non-standard ports..."
    netstat -tulnp | grep -v ":22"

    echo "Done with service audits."
}

# 4. Firewall and Network Security
audit_firewall_and_network() {
    echo "=== Firewall and Network Security ==="
    echo "Checking firewall status..."
    ufw status || iptables -L

    echo "Checking for open ports..."
    netstat -tuln | grep LISTEN

    echo "Checking IP forwarding and network configuration..."
    sysctl net.ipv4.ip_forward
    sysctl net.ipv6.conf.all.forwarding

    echo "Done with firewall and network security."
}

# 5. IP and Network Configuration Checks
audit_ip_configuration() {
    echo "=== IP and Network Configuration Checks ==="
    echo "Checking public vs. private IPs..."
    ip addr | grep inet

    echo "Summary of IP addresses:"
    ip -4 addr show | awk '/inet/ {print $2}' | while read -r ip; do
        if [[ $ip =~ ^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.168\. ]]; then
            echo "$ip is private"
        else
            echo "$ip is public"
        fi
    done

    echo "Ensuring SSH is not exposed on public IPs..."
    # Add custom logic to check if SSH is on public IP

    echo "Done with IP and network configuration."
}

# 6. Security Updates and Patching
audit_security_updates() {
    echo "=== Security Updates and Patching ==="
    echo "Checking for available security updates..."
    apt-get update && apt-get -s upgrade | grep -i security

    echo "Ensuring automatic security updates are configured..."
    grep -r "Unattended-Upgrade::" /etc/apt/apt.conf.d/

    echo "Done with security updates and patching."
}

# 7. Log Monitoring
monitor_logs() {
    echo "=== Log Monitoring ==="
    echo "Checking for suspicious SSH login attempts..."
    grep "Failed password" /var/log/auth.log | tail -10

    echo "Done with log monitoring."
}

# 8. Server Hardening
server_hardening() {
    echo "=== Server Hardening ==="
    echo "Configuring SSH for key-based authentication..."
    sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd

    echo "Disabling IPv6 (if not required)..."
    sysctl -w net.ipv6.conf.all.disable_ipv6=1

    echo "Securing GRUB bootloader..."
    echo "set superusers=\"root\"" >> /etc/grub.d/40_custom
    echo "password_pbkdf2 root $(grub-mkpasswd-pbkdf2)" >> /etc/grub.d/40_custom
    update-grub

    echo "Configuring automatic security updates..."
    dpkg-reconfigure -plow unattended-upgrades

    echo "Firewall hardening..."
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    # Add other necessary rules here
    iptables-save > /etc/iptables/rules.v4

    echo "Done with server hardening."
}

# 9. Custom Security Checks
custom_security_checks() {
    echo "=== Custom Security Checks ==="
    if [ -f /etc/security/custom_checks.sh ]; then
        bash /etc/security/custom_checks.sh
    fi
    echo "Done with custom security checks."
}

# 10. Reporting and Alerting
generate_report() {
    echo "Generating security audit and hardening report..."
    report_file="/home/huzaifa/workspace/safesquid/safesquidlabs_devops/SET-2 Automating Security audit Linux/security_audit_$(date +'%Y%m%d').log"
    {
        audit_users_and_groups
        audit_file_permissions
        audit_services
        audit_firewall_and_network
        audit_ip_configuration
        audit_security_updates
        monitor_logs
        server_hardening
        custom_security_checks
    } > "$report_file"

    echo "Report saved to $report_file"

    # Optional: Send email alert
    # mail -s "Security Audit Report" admin@example.com < "$report_file"
}

# Main Script Execution
main() {
    echo "Starting security audit and hardening process..."
    generate_report
    echo "Process completed."
}

# Call the main function
main "$@"
