#!/bin/bash

# Heartbeat Monitor - Pulse Script

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the configuration
CONFIG_FILE="$PROJECT_ROOT/config/thresholds.cfg"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Ensure Log Directory Exists
mkdir -p "$(dirname "$LOG_FILE")"

# Convert relative paths to absolute for safety if needed, 
# or ensure we run from project root. Here we assume paths in config are relative to project root
# if they start with ./, so we prepend PROJECT_ROOT
if [[ "$WATCH_DIR" == ./* ]]; then
    FULL_WATCH_DIR="$PROJECT_ROOT/${WATCH_DIR#./}"
else
    FULL_WATCH_DIR="$WATCH_DIR"
fi

if [[ "$DIAGNOSE_SCRIPT" == ./* ]]; then
    FULL_DIAGNOSE_SCRIPT="$PROJECT_ROOT/${DIAGNOSE_SCRIPT#./}"
else
    FULL_DIAGNOSE_SCRIPT="$DIAGNOSE_SCRIPT"
fi

if [[ "$LOG_FILE" == ./* ]]; then
    FULL_LOG_FILE="$PROJECT_ROOT/${LOG_FILE#./}"
else
    FULL_LOG_FILE="$LOG_FILE"
fi

# Check if WATCH_DIR exists
if [ ! -d "$FULL_WATCH_DIR" ]; then
    echo "$(date): Error - Watch directory $FULL_WATCH_DIR does not exist." | tee -a "$FULL_LOG_FILE"
    exit 1
fi

# Check for files modified in the last N minutes
# We look for *any* file type (-type f)
# -mmin -N means modified less than N minutes ago
RECENT_FILES=$(find "$FULL_WATCH_DIR" -type f -mmin -"$THRESHOLD_MINUTES")

if [ -z "$RECENT_FILES" ]; then
    MESSAGE="ALERT: No files produced in $FULL_WATCH_DIR in the last $THRESHOLD_MINUTES minutes."
    echo "$(date): $MESSAGE" | tee -a "$FULL_LOG_FILE"
    
    echo "Triggering Diagnostic Engine..." | tee -a "$FULL_LOG_FILE"
    
    if [ -x "$FULL_DIAGNOSE_SCRIPT" ] || [ -f "$FULL_DIAGNOSE_SCRIPT" ]; then
        # Run perl script
        perl "$FULL_DIAGNOSE_SCRIPT" | tee -a "$FULL_LOG_FILE"
    else
        echo "Error: Diagnostic script not found or not executable at $FULL_DIAGNOSE_SCRIPT" | tee -a "$FULL_LOG_FILE"
    fi
else
    COUNT=$(echo "$RECENT_FILES" | wc -l)
    echo "$(date): Pulse OK. Found $COUNT active files in $FULL_WATCH_DIR." >> "$FULL_LOG_FILE"
fi
