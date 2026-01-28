# Heartbeat Monitor

## Overview
The Heartbeat Monitor is a shell-based self-healing monitoring system designed for document pipelines on **Linux** environments. It ensures that critical files are generated on time and provides diagnostic information when failures occur.

## Prerequisites
- Linux / Unix environment
- Bash
- Perl
- Standard system utilities (`find`, `ps`, `awk`)

## Components
- **Heartbeat (Pulse)**: A Shell script (`bin/heartbeat.sh`) that monitors the "Last Modified" time of the production output folder.
- **Diagnostics**: A Perl script (`bin/diagnose.pl`) that investigates system state (finding "Zombie" processes) when the pulse stops.
- **Configuration**: Centralized configuration in `config/thresholds.cfg`.

## Usage
1. Configure the watch directory and thresholds in `config/thresholds.cfg`.
2. Run `bin/heartbeat.sh` as a cron job or scheduled task.
3. Check `logs/` for activity and alerts.

## Directory Structure
- `bin/`: Executable scripts
- `config/`: Configuration files
- `logs/`: Application logs
- `tests/`: Test scenarios and mock data
