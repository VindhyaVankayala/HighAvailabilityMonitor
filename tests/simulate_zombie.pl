#!/usr/bin/perl
use strict;
use warnings;

# This script creates a zombie process.
# A zombie is a child process that has completed execution but still has an entry in the process table.
# This happens when the parent process has not yet released the child.

my $pid = fork();

if (!defined $pid) {
    die "Cannot fork: $!";
} elsif ($pid == 0) {
    # Child process
    print "Child process (PID $$) exiting immediately to become a zombie...\n";
    exit(0);
} else {
    # Parent process
    print "Parent process (PID $$) sleeping. Child $pid should be a zombie now.\n";
    print "Run 'ps -elf | grep $pid' to check state.\n";
    
    # Sleep long enough for the diagnostic tool to run and detect it
    sleep(60); 
    
    print "Parent waking up and reaping child.\n";
    waitpid($pid, 0);
}
