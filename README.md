# ai-assit-devops
practice

## VM Health Monitoring Script

This repository contains a shell script (`vm_health_check.sh`) that monitors the health of a virtual machine based on CPU, memory, and disk usage.

### Features

- **Health Threshold**: 60% utilization threshold for all metrics
- **Multi-metric Analysis**: Monitors CPU, Memory, and Disk usage
- **Ubuntu Optimized**: Designed specifically for Ubuntu virtual machines
- **Detailed Reporting**: Optional "explain" mode for comprehensive analysis
- **Color-coded Output**: Easy-to-read status indicators
- **Exit Codes**: Returns 0 for healthy, 1 for unhealthy systems

### Usage

#### Basic Health Check
```bash
./vm_health_check.sh
```

#### Detailed Analysis
```bash
./vm_health_check.sh explain
```

### Health Criteria

The VM is considered **HEALTHY** when:
- CPU usage < 60%
- Memory usage < 60%
- Disk usage < 60%

The VM is considered **NOT HEALTHY** when any of the above metrics ≥ 60%

### Output Examples

**Basic Output (Healthy):**
```
VM Health Status: HEALTHY
```

**Detailed Output (with explain):**
```
=== VM Health Analysis ===
Threshold: 60%

CPU Usage: 45% (GOOD)
Memory Usage: 52% (GOOD)
Disk Usage: 38% (GOOD)

=== Health Assessment ===
Overall Status: HEALTHY
Reason: All system resources (CPU, Memory, Disk) are below the 60% threshold.
```

### Requirements

- Ubuntu operating system
- Basic system utilities (free, df, top, grep, awk)
- Execute permissions on the script

### Installation

1. Make the script executable:
   ```bash
   chmod +x vm_health_check.sh
   ```

2. Run the health check:
   ```bash
   ./vm_health_check.sh
   ```