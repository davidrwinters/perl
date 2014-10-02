#!/usr/bin/perl

my @out = `@ARGV`;
foreach (@out) {
    print "@ARGV: $_";
}
