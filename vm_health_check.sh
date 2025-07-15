#!/bin/bash

# VM Health Check Script for Ubuntu
# Monitors CPU, Memory, and Disk usage with 60% threshold
# Usage: ./vm_health_check.sh [explain]

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Threshold percentage
THRESHOLD=60

# Function to get CPU usage
get_cpu_usage() {
    # Get CPU usage using top command (1 second sample)
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    # Alternative method using iostat if available
    if command -v iostat &> /dev/null; then
        cpu_usage=$(iostat -c 1 2 | tail -1 | awk '{print 100-$6}')
    else
        # Fallback: calculate from /proc/stat
        cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}')
    fi
    echo "${cpu_usage%.*}" # Remove decimal part
}

# Function to get memory usage
get_memory_usage() {
    memory_info=$(free | grep Mem)
    total_mem=$(echo $memory_info | awk '{print $2}')
    used_mem=$(echo $memory_info | awk '{print $3}')
    memory_usage=$((used_mem * 100 / total_mem))
    echo $memory_usage
}

# Function to get disk usage
get_disk_usage() {
    # Get disk usage for root partition
    disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo $disk_usage
}

# Function to determine health status
check_health() {
    local cpu=$1
    local memory=$2
    local disk=$3
    
    if [ $cpu -lt $THRESHOLD ] && [ $memory -lt $THRESHOLD ] && [ $disk -lt $THRESHOLD ]; then
        echo "HEALTHY"
    else
        echo "NOT HEALTHY"
    fi
}

# Function to print detailed explanation
print_explanation() {
    local cpu=$1
    local memory=$2
    local disk=$3
    local status=$4
    
    echo -e "${BLUE}=== VM Health Analysis ===${NC}"
    echo -e "${BLUE}Threshold: ${THRESHOLD}%${NC}"
    echo ""
    
    # CPU Status
    if [ $cpu -lt $THRESHOLD ]; then
        echo -e "CPU Usage: ${GREEN}${cpu}% (GOOD)${NC}"
    else
        echo -e "CPU Usage: ${RED}${cpu}% (HIGH)${NC}"
    fi
    
    # Memory Status
    if [ $memory -lt $THRESHOLD ]; then
        echo -e "Memory Usage: ${GREEN}${memory}% (GOOD)${NC}"
    else
        echo -e "Memory Usage: ${RED}${memory}% (HIGH)${NC}"
    fi
    
    # Disk Status
    if [ $disk -lt $THRESHOLD ]; then
        echo -e "Disk Usage: ${GREEN}${disk}% (GOOD)${NC}"
    else
        echo -e "Disk Usage: ${RED}${disk}% (HIGH)${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}=== Health Assessment ===${NC}"
    
    if [ "$status" = "HEALTHY" ]; then
        echo -e "Overall Status: ${GREEN}HEALTHY${NC}"
        echo "Reason: All system resources (CPU, Memory, Disk) are below the 60% threshold."
    else
        echo -e "Overall Status: ${RED}NOT HEALTHY${NC}"
        echo "Reason: One or more system resources exceed the 60% threshold:"
        
        [ $cpu -ge $THRESHOLD ] && echo "  - CPU usage is at ${cpu}% (≥60%)"
        [ $memory -ge $THRESHOLD ] && echo "  - Memory usage is at ${memory}% (≥60%)"
        [ $disk -ge $THRESHOLD ] && echo "  - Disk usage is at ${disk}% (≥60%)"
        
        echo ""
        echo "Recommendations:"
        [ $cpu -ge $THRESHOLD ] && echo "  - Consider reducing CPU-intensive processes"
        [ $memory -ge $THRESHOLD ] && echo "  - Free up memory or add more RAM"
        [ $disk -ge $THRESHOLD ] && echo "  - Clean up disk space or expand storage"
    fi
}

# Main script execution
main() {
    # Check if running on Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        echo -e "${YELLOW}Warning: This script is designed for Ubuntu systems.${NC}"
    fi
    
    # Get system metrics
    echo "Collecting system metrics..."
    cpu_usage=$(get_cpu_usage)
    memory_usage=$(get_memory_usage)
    disk_usage=$(get_disk_usage)
    
    # Determine health status
    health_status=$(check_health $cpu_usage $memory_usage $disk_usage)
    
    # Check for explain argument
    if [ "$1" = "explain" ]; then
        print_explanation $cpu_usage $memory_usage $disk_usage "$health_status"
    else
        # Simple output
        echo ""
        if [ "$health_status" = "HEALTHY" ]; then
            echo -e "VM Health Status: ${GREEN}HEALTHY${NC}"
        else
            echo -e "VM Health Status: ${RED}NOT HEALTHY${NC}"
        fi
        echo ""
        echo "Usage: $0 [explain] - Add 'explain' for detailed analysis"
    fi
    
    # Exit with appropriate code
    if [ "$health_status" = "HEALTHY" ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function with all arguments
main "$@"