#!/usr/bin/env bash
#
# server-stats.sh — analyse basic server performance stats
# Works on most Linux servers. Run with:  bash server-stats.sh
#

# Make output a little nicer with a divider helper
divider() {
    echo "------------------------------------------------------------"
}

echo "============================================================"
echo "                 SERVER PERFORMANCE STATS                   "
echo "         $(date '+%Y-%m-%d %H:%M:%S')  on  $(hostname)        "
echo "============================================================"

# ----------------------------------------------------------------
# CPU USAGE
# ----------------------------------------------------------------
divider
echo ">> TOTAL CPU USAGE"
divider

# Read CPU idle % from 'top' (batch mode, one sample) and compute usage = 100 - idle.
cpu_idle=$(top -bn1 | grep -i "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/')
if [ -n "$cpu_idle" ]; then
    cpu_usage=$(echo "100 - $cpu_idle" | bc 2>/dev/null)
    echo "CPU Used : ${cpu_usage}%"
    echo "CPU Idle : ${cpu_idle}%"
else
    echo "Could not read CPU usage on this system."
fi

# ----------------------------------------------------------------
# MEMORY USAGE
# ----------------------------------------------------------------
divider
echo ">> TOTAL MEMORY USAGE (Free vs Used)"
divider

# 'free -m' gives memory in megabytes. We pull the line that starts with "Mem:".
mem_total=$(free -m | awk '/^Mem:/ {print $2}')
mem_used=$(free -m | awk '/^Mem:/ {print $3}')
mem_free=$(free -m | awk '/^Mem:/ {print $4}')
mem_pct=$(echo "scale=2; $mem_used / $mem_total * 100" | bc 2>/dev/null)

echo "Total : ${mem_total} MB"
echo "Used  : ${mem_used} MB  (${mem_pct}%)"
echo "Free  : ${mem_free} MB"

# ----------------------------------------------------------------
# DISK USAGE
# ----------------------------------------------------------------
divider
echo ">> TOTAL DISK USAGE (Free vs Used)"
divider

# 'df -h --total' gives a summary "total" row across all filesystems.
# We grab that row and print the used/free/percent columns.
df -h --total 2>/dev/null | awk '/^total/ {
    print "Total : " $2;
    print "Used  : " $3 "  (" $5 ")";
    print "Free  : " $4;
}'

# ----------------------------------------------------------------
# TOP 5 PROCESSES BY CPU
# ----------------------------------------------------------------
divider
echo ">> TOP 5 PROCESSES BY CPU USAGE"
divider

# ps lists processes; we sort by %CPU descending and show the top 5.
printf "%-8s %-8s %-6s %s\n" "PID" "%CPU" "%MEM" "COMMAND"
ps -eo pid,pcpu,pmem,comm --sort=-pcpu | head -n 6 | tail -n 5 | \
    awk '{ printf "%-8s %-8s %-6s %s\n", $1, $2, $3, $4 }'

# ----------------------------------------------------------------
# TOP 5 PROCESSES BY MEMORY
# ----------------------------------------------------------------
divider
echo ">> TOP 5 PROCESSES BY MEMORY USAGE"
divider

printf "%-8s %-8s %-6s %s\n" "PID" "%MEM" "%CPU" "COMMAND"
ps -eo pid,pmem,pcpu,comm --sort=-pmem | head -n 6 | tail -n 5 | \
    awk '{ printf "%-8s %-8s %-6s %s\n", $1, $2, $3, $4 }'

# ================================================================
# STRETCH GOALS — extra useful stats
# ================================================================
divider
echo ">> EXTRA STATS"
divider

# OS version
if [ -f /etc/os-release ]; then
    os_name=$(grep -w "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
    echo "OS Version       : $os_name"
fi

# Kernel
echo "Kernel           : $(uname -r)"

# Uptime (how long the machine has been running)
echo "Uptime           : $(uptime -p 2>/dev/null || uptime)"

# Load average (1, 5, 15 minute averages)
load=$(uptime | awk -F'load average:' '{print $2}')
echo "Load Average     :$load"

# Number of logged-in users
users_count=$(who | wc -l)
echo "Logged-in Users  : $users_count"

# Currently logged-in usernames (unique)
logged_in=$(who | awk '{print $1}' | sort -u | tr '\n' ' ')
echo "Active Users     : $logged_in"

# Failed login attempts (needs permission to read auth logs; may show 0 if not accessible)
if command -v lastb >/dev/null 2>&1; then
    failed=$(sudo lastb 2>/dev/null | grep -v "^$" | grep -vc "btmp begins")
    echo "Failed Logins    : $failed   (run with sudo for accurate count)"
fi

divider
echo "Report complete."
divider
