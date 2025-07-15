#!/bin/bash

# VM Health Monitoring Script
# Checks CPU, Memory, and Disk usage against 60% threshold

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Threshold percentage
THRESHOLD=60

echo "========================================="
echo "       VM Health Check Report"
echo "========================================="
echo "Threshold: ${THRESHOLD}%"
echo "Date: $(date)"
echo "========================================="

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

# Function to get Memory usage
get_memory_usage() {
    memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    echo "$memory_usage"
}

# Function to get Disk usage
get_disk_usage() {
    # Get disk usage for root partition
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "$disk_usage"
}

# Function to check if usage is healthy
check_health() {
    local usage=$1
    local resource=$2
    
    if [ "$usage" -lt "$THRESHOLD" ]; then
        echo -e "${GREEN}✓ $resource: ${usage}% - HEALTHY${NC}"
        return 0
    else
        echo -e "${RED}✗ $resource: ${usage}% - NOT HEALTHY${NC}"
        return 1
    fi
}

# Get system metrics
echo "Collecting system metrics..."
echo ""

CPU_USAGE=$(get_cpu_usage)
MEMORY_USAGE=$(get_memory_usage)
DISK_USAGE=$(get_disk_usage)

# Display current usage
echo "Current System Usage:"
echo "---------------------"

# Check each component
cpu_healthy=$(check_health "$CPU_USAGE" "CPU")
cpu_status=$?

memory_healthy=$(check_health "$MEMORY_USAGE" "Memory")
memory_status=$?

disk_healthy=$(check_health "$DISK_USAGE" "Disk Space")
disk_status=$?

echo ""
echo "========================================="

# Overall health assessment
if [ $cpu_status -eq 0 ] && [ $memory_status -eq 0 ] && [ $disk_status -eq 0 ]; then
    echo -e "${GREEN}🎉 OVERALL VM STATUS: HEALTHY${NC}"
    echo "All system resources are within acceptable limits."
    exit_code=0
else
    echo -e "${RED}⚠️  OVERALL VM STATUS: NOT HEALTHY${NC}"
    echo "One or more system resources exceed the threshold."
    
    # Provide recommendations
    echo ""
    echo "Recommendations:"
    echo "----------------"
    
    if [ $cpu_status -ne 0 ]; then
        echo "• CPU usage is high. Consider:"
        echo "  - Identifying resource-intensive processes"
        echo "  - Scaling up CPU resources"
        echo "  - Optimizing applications"
    fi
    
    if [ $memory_status -ne 0 ]; then
        echo "• Memory usage is high. Consider:"
        echo "  - Checking for memory leaks"
        echo "  - Increasing RAM allocation"
        echo "  - Optimizing memory usage"
    fi
    
    if [ $disk_status -ne 0 ]; then
        echo "• Disk usage is high. Consider:"
        echo "  - Cleaning up unnecessary files"
        echo "  - Expanding disk space"
        echo "  - Implementing log rotation"
    fi
    
    exit_code=1
fi

echo "========================================="
echo "Health check completed at $(date)"

# Exit with appropriate code
exit $exit_code