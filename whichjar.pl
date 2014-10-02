#!/usr/bin/perl

my $MATCH_COUNT = 0;

sub scanResource {
	my ($topLevelResource, $resource, $fileToFind) = @_;

    if (-d $resource) {  ### directory ###
    	if ($topLevelResource eq $resource) {  ### Explode contents of top level directories ###
	    	print "directory: $resource\n";
	    	foreach my $line (<$resource/*>) {
	    		scanResource($topLevelResource, $line, $fileToFind, 0);
	    	}
    	} else {  ### This directory and its children have already been expanded with the find or tar command. ###
		}
    } elsif (-f $resource and $resource =~ /^.*\.[jJ][aA][rR]$/) {  ### jar file ###
    	my @lines = `jar tvf $resource`;
    	foreach my $line (@lines) {
    		chomp($line);
    		scanResource($topLevelResource, $line, $fileToFind, 0);
    	}
    } elsif (-f $resource and $resource =~ /^.*\.[zZ][iI][pP]$/) {  ### zip file ###
    	warn "!!!!!!!!!!!! zip file is not implemented !!!!!!!!!!!!\n";
    } else { ### class, properties, xml, etc. file ###
    	if (index($resource, $fileToFind) != -1) {
    		$MATCH_COUNT++;
    		print "\n";
    		print "MATCH #: $MATCH_COUNT\n";
    		print "Classpath Entry: $topLevelResource\n";
    		print "File: $resource\n";
    	}
    }
}

my $classpathArg = $ARGV[0];  ### the CLASSPATH of resources ###
my $fileArg = $ARGV[1];   ### the file to search for in the CLASSPATH ###

die "Missing classpath argument.  Usage: $0 <classpath> <file>\n" unless $classpathArg;
die "Missing file argument.  Usage: $0 <classpath> <file>\n" unless $fileArg;

my @cpEntries = split(':', $classpathArg);
foreach my $cpEntry (@cpEntries) {
	scanResource($cpEntry, $cpEntry, $fileArg, 1);
}
