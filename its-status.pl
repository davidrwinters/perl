#!/usr/bin/perl

use Data::Dumper;

my %its;

sub saveItStatus {
	my ($timestamp, $thread, $table, $status) = @_;
	if ($status eq 'Starting') {
		my $rec = {};
		$rec->{'start'} = $timestamp;
		$rec->{'thread'} = $thread;
		$its{$table} = $rec;
	} elsif ($status eq 'finished') {
		my $rec = $its{$table};
		$rec->{'finish'} = $timestamp;
		$its{$table} = $rec;
	} else {
		print "!!!Unknown status: $status!!!";
	}
}

sub printUnfinishedIts {
	print "Unfinished ITs\n--------------\n";
	foreach my $key (keys %its) {
		if ($its{$key}->{'finish'} == undef) {
			print Dumper($its{$key}, $key);
		}
	}
}

my $fileArg = $ARGV[0];
die "Missing file argument.  Usage: $0 <file>\n" unless $fileArg;

open (MYFILE, "<$fileArg");
foreach my $line (<MYFILE>) {
	chomp $line;
	#
	# Format of input lines:
	# 12:55:56,051 (pool-1-thread-2) TRACE [c.s.d.t.f.SpliceTableWatcher] - [DATATYPECORRECTNESSIT.II] Starting
	# 13:10:45,951 (pool-1-thread-2) TRACE [c.s.d.t.f.SpliceTableWatcher] - [DATATYPECORRECTNESSIT.II] finished
	#
	if ($line =~ /^(\d\d:\d\d:\d\d,\d\d\d) \((.*)\) TRACE \[c.s.d.t.f.SpliceTableWatcher\] - \[(.*)\] ([\w]+)$/) {
		my ($timestamp, $thread, $table, $status) = ($1, $2, $3, $4);
		saveItStatus($timestamp, $thread, $table, $status);
		print "timestamp = $timestamp, thread = $thread, table = $table, status = $status\n";
	}
}
close (MYFILE);
print Dumper(\%its);
printUnfinishedIts();
