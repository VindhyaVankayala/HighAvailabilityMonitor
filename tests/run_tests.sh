#!/bin/bash

# VBS Heartbeat Monitor - Test Runner
# Run this on your Linux environment.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_ROOT/logs/heartbeat.log"
TEST_OUTPUT_DIR="$PROJECT_ROOT/tests/production_output"

# Ensure clean state
mkdir -p "$TEST_OUTPUT_DIR"
mkdir -p "$PROJECT_ROOT/logs"

function cleanup {
    echo "Cleaning up..."
    rm -f "$LOG_FILE"
    rm -rf "$TEST_OUTPUT_DIR"/*
    pkill -f "simulate_zombie.pl" || true
    pkill -f "simulate_stuck.pl" || true
}

function run_heartbeat {
    echo "Running heartbeat.sh..."
    bash "$PROJECT_ROOT/bin/heartbeat.sh"
}

function check_log {
    local pattern="$1"
    if grep -q "$pattern" "$LOG_FILE"; then
        echo "✅ PASS: Log contains '$pattern'"
    else
        echo "❌ FAIL: Log missing '$pattern'"
        echo "--- Log Content ---"
        cat "$LOG_FILE"
        echo "-------------------"
    fi
}

echo "==========================================="
echo "Running VBS Heartbeat Tests"
echo "==========================================="

# --- Scenario 1: Pulse OK ---
echo ""
echo "test_pulse_ok: Creating fresh file..."
cleanup
touch "$TEST_OUTPUT_DIR/fresh_file.txt" # Created just now
run_heartbeat
check_log "Pulse OK"

# --- Scenario 2: Pulse Missing ---
echo ""
echo "test_pulse_missing: No recent files..."
cleanup
# No files created
run_heartbeat
check_log "ALERT: No files produced"
check_log "Triggering Diagnostic Engine"

# --- Scenario 3: Zombie Process ---
echo ""
echo "test_zombie_detection: Simulating Zombie..."
cleanup
# Start zombie simulator in background
perl "$SCRIPT_DIR/simulate_zombie.pl" &
ZOMBIE_PID=$!
# Give it a second to become a zombie
sleep 2

run_heartbeat
check_log "CRITICAL: Found candidate ZOMBIE processes"

# Kill parent of zombie (cleanup)
kill $ZOMBIE_PID 2>/dev/null

# --- Scenario 4: Stuck Process ---
echo ""
echo "test_stuck_detection: Simulating Stuck Process..."
cleanup
# Start stuck simulator in background
perl "$SCRIPT_DIR/simulate_stuck.pl" &
STUCK_PID=$!
sleep 1

run_heartbeat
check_log "WARNING: Process potentially stuck"

kill $STUCK_PID 2>/dev/null


echo ""
echo "==========================================="
echo "Tests Completed."
