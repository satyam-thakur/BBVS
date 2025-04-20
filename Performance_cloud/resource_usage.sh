#!/bin/bash

# echo "Monitoring CPU and Memory Usage..."
# echo -e "Time\t\tCPU%\tMemory%\tAvailable MB"

# while true; do
#     time_stamp=$(date +"%H:%M:%S")
#     cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
#     mem_usage=$(free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')
#     mem_available=$(free -m | awk '/Mem/ {print $7}')
    
#     echo -e "$time_stamp\t$cpu_usage\t$mem_usage\t$mem_available"
#     sleep 1
# done

#===============================================================

echo "Monitoring CPU and Memory Usage... (Press Ctrl+C to stop)"
echo -e "Time\t\tCPU%\tMemory%\tAvailable MB\tAvg CPU%\tAvg Mem%"

cpu_total=0
mem_total=0
count=0

while true; do
    time_stamp=$(date +"%H:%M:%S")
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    mem_usage=$(free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')
    mem_available=$(free -m | awk '/Mem/ {print $7}')
    
    # Update averages
    cpu_total=$(echo "$cpu_total + $cpu_usage" | bc)
    mem_total=$(echo "$mem_total + $mem_usage" | bc)
    count=$((count + 1))
    
    avg_cpu=$(echo "scale=2; $cpu_total / $count" | bc)
    avg_mem=$(echo "scale=2; $mem_total / $count" | bc)

    echo -e "$time_stamp\t$cpu_usage\t$mem_usage\t$mem_available\t$avg_cpu\t\t$avg_mem"
    sleep 1
done