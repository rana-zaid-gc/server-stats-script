# server-stats.sh — Linux Server Performance Analyzer

A Bash script that analyzes the performance of any Linux server and prints a clean, readable report in one command. Built to practice shell scripting and the core Linux tools every DevOps engineer uses daily — `ps`, `top`, `free`, `df`, `awk`, `grep`, and `sed`.

Project URL:https://github.com/rana-zaid-gc/server-stats-script


## What it reports

**Core stats:**
- Total **CPU usage** (used vs idle)
- Total **memory usage** — free vs used, with percentage
- Total **disk usage** — free vs used, with percentage
- **Top 5 processes by CPU usage**
- **Top 5 processes by memory usage**

**Extra stats (stretch goals):**
- OS version and kernel
- System uptime
- Load average (1 / 5 / 15 min)
- Number of logged-in users and active usernames
- Failed login attempts

## Usage

```bash
# Make the script executable (once)
chmod +x server-stats.sh

# Run it
./server-stats.sh
```

For an accurate failed-login count, run with elevated privileges:

```bash
sudo bash server-stats.sh
```

The script is self-contained — no installation or dependencies beyond standard Linux utilities.

## Sample output

```
============================================================
                 SERVER PERFORMANCE STATS
         2026-06-25 10:08:10  on  myserver
============================================================
------------------------------------------------------------
>> TOTAL CPU USAGE
------------------------------------------------------------
CPU Used : 23.1%
CPU Idle : 76.9%
------------------------------------------------------------
>> TOTAL MEMORY USAGE (Free vs Used)
------------------------------------------------------------
Total : 3997 MB
Used  : 199 MB  (4.00%)
Free  : 3892 MB
------------------------------------------------------------
>> TOTAL DISK USAGE (Free vs Used)
------------------------------------------------------------
Total : 40G
Used  : 8.6G  (22%)
Free  : 31G
------------------------------------------------------------
>> TOP 5 PROCESSES BY CPU USAGE
------------------------------------------------------------
PID      %CPU     %MEM   COMMAND
491      21.6     0.8    rclone
1        9.2      0.1    systemd
...
------------------------------------------------------------
>> EXTRA STATS
------------------------------------------------------------
OS Version       : Ubuntu 24.04.4 LTS
Kernel           : 6.18.5
Uptime           : up 3 hours, 12 minutes
Load Average     : 0.08, 0.02, 0.01
Logged-in Users  : 1
------------------------------------------------------------
```

## How it works

Each stat follows the classic Linux pattern: **run a command → filter it → extract the value.**

| Stat | Technique |
|------|-----------|
| CPU | `top -bn1` reports idle %; usage is calculated as `100 - idle` with `bc` |
| Memory | `free -m` parsed with `awk`, percentage computed with `bc` |
| Disk | `df -h --total` summary row parsed with `awk` |
| Top processes | `ps -eo ... --sort=-pcpu` (and `-pmem`), trimmed with `head`/`tail` |
| Extra stats | `/etc/os-release`, `uname`, `uptime`, `who`, `lastb` |

## Tested on

- Ubuntu 24.04 LTS

> Note: CPU and memory parsing targets the standard `top` / `free` output on Debian/Ubuntu systems. Other distributions may format these slightly differently and could require minor tweaks.

## What I learned

- Writing and structuring a Bash script with functions and clear output
- Extracting specific values from command output with `awk`, `grep`, and `sed`
- Doing floating-point math in shell with `bc`
- Sorting and filtering process lists with `ps`
- Reading core Linux system stats the way monitoring tools do under the hood

---

screenshot

<img width="1920" height="941" alt="Screenshot from 2026-06-25 15-08-59" src="https://github.com/user-attachments/assets/fede9253-f5d0-40d5-aed6-cbbfda053eda" />


