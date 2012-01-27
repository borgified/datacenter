#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use CGI qw(:standard);

my $my_cnf = '~/scripts/secret/my_cnf.cnf';

my $dbh = DBI->connect("DBI:mysql:"
    . ";mysql_read_default_file=$my_cnf"
    .';mysql_read_default_group=inventory',
    undef, 
    undef
   ) or die "something went wrong ($DBI::errstr)";

my $sth = $dbh->prepare('select hostname,owner,backup,support_notes,os from rwc');

$sth->execute();

my @categories = qw/hostname owner backup support_notes os/;
my %data;

while(my @results = $sth->fetchrow_array()){
		$data{$results[0]}{'owner'}=$results[1];
		$data{$results[0]}{'backup'}=$results[2];
		$data{$results[0]}{'support_notes'}=$results[3];
		$data{$results[0]}{'os'}=$results[4];
}


print "the server orphanage";
foreach my $key (keys %data){
	if($data{$key}{'owner'} eq ''){
		print "$key CLAIM OWNERSHIP\n";
	}
}
