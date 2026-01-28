#!/usr/bin/perl
use strict;
use warnings;

# Heartbeat Monitor - Diagnostic Engine
# Purpose: Identify "Zombie" processes or stuck scripts when the heartbeat fails.

print "\n--- [DIAGNOSTICS STARTED] ---\n";
print "Timestamp: " . localtime() . "\n";

# 1. Check for Zombie Processes
# On Unix, we can use `ps -elf` or `ps aux` and look for 'Z' state.
# On Windows, we might rely on `tasklist` or specific checks.

my $os = $^O;
print "Operating System: $os (Assumed Linux/Unix environment)\n";

my @zombies = ();

# 1. Check for Zombie Processes
# Look for Z state in ps output
open(my $ps, "-|", "ps -eo pid,stat,pcpu,comm");
while (<$ps>) {
    chomp;
    # Example line:  1234 Z 0.0 generic-script
    if (/^\s*(\d+)\s+Z/) {
        push @zombies, $_;
    }
}
close($ps);

if (@zombies) {
    print "CRITICAL: Found candidate ZOMBIE processes:\n";
    foreach my $z (@zombies) {
        print "  -> $z\n";
    }
} else {
    print "Status: No 'Zombie' (defunct) processes detected.\n";
}

# 2. Check for Deadlocks (Scripts running with 0% CPU for long time)
print "Checking for potentially stuck script processes (0.0% CPU usage)...\n";

my $found_stuck = 0;
# ps -eo pid,pcpu,comm,args
open(my $ps_cpu, "-|", "ps -eo pid,pcpu,comm,args");
while (<$ps_cpu>) {
    # Filter for our relevant types (perl, bash, sh, python)
    if (/perl|bash|sh|php|python/i) {
        # Check for 0.0% CPU
        if (/^\s*\d+\s+0\.0/) {
                print "  WARNING: Process potentially stuck (0% CPU): $_\n";
                $found_stuck = 1;
        }
    }
}
close($ps_cpu);

if (!$found_stuck) {
    print "No obviously stuck script processes found.\n";
}

print "--- [DIAGNOSTICS COMPLETE] ---\n";
