#!/usr/bin/perl
use strict;
use warnings;

# This script simulates a "stuck" process.
# It does absolutely nothing but sleep, consuming 0% CPU.
# The diagnostic tool looks for processes with 0.0% CPU usage.

print "Starting stuck process simulation (PID $$)...\n";
print "I will sleep for 60 seconds. My CPU usage should be 0.0%.\n";

sleep(60);

print "Stuck process waking up and exiting.\n";
