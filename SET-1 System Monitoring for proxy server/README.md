# System Resource Monitoring Dashboard

This Bash script provides real-time monitoring of various system resources for a proxy server. The script can display information about CPU and memory usage, network activity, disk space, system load, active processes, and essential services.

## Usage

To run the script, use the following command:

```bash
./monitor.sh [OPTION]


Options:
-cpu: Display the top 10 most used applications by CPU and memory.
-network: Show network monitoring details.
-disk: Display disk usage by mounted partitions.
-load: Show the current system load average and CPU usage breakdown.
-memory: Display memory and swap usage.
-process: Monitor active processes.
-services: Check the status of essential services.
-all: Display the full dashboard with all information.