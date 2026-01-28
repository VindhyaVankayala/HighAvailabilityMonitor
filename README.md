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

##Test Scenarios
Scenario 1: Pulse OK
Create a file in tests/production_output with a recent timestamp.
Run
bin/heartbeat.sh
Check logs/heartbeat.log contains "Pulse OK".

Scenario 2: Pulse Missing (Heartbeat Failure)
Clear tests/production_output or set file times to old.
Run 
bin/heartbeat.sh
Check logs/heartbeat.log contains "ALERT" and "DIAGNOSTICS STARTED".

I have added the generated log file heartbeat.log for reference.
