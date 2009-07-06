#!/usr/bin/env perl

use warnings;
use strict;
use Getopt::Long;

my $user_name = `git config user.name`;
chomp $user_name;
my $user_email = `git config user.email`;
chomp $user_email;
my $author = "$user_name <$user_email>";

my $msg = "File import.";
my $autocrlf = 1;

GetOptions("msg=s", \$msg,
           "noautocrlf", sub { $autocrlf = 0 }) || exit 1;
$msg = $msg . "\n";

for my $filename (@ARGV) {
	open FH, $filename || die "can't open $filename: $!\n";
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
	    $atime,$mtime,$ctime,$blksize,$blocks) = stat FH;
	my $blob = do { local $/; <FH> };
	close FH;

	if ($autocrlf) {
		$blob =~ tr/\r//d;
	}

	my $gitmode = ($mode & 0111) ? "755" : "644";
	print "blob\nmark :1234\ndata " . length($blob) . "\n";
	print $blob;
	print "commit refs/heads/master\n";
	print "mark :4321\ncommitter $author $mtime +0000\n";
	print "data " . length($msg) . "\n$msg";
	print "M $gitmode :1234 $filename\n";
}
