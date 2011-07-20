#!/usr/bin/perl -w

use DBI;

##connect to db to store results
my $dbh = DBI->connect('DBI:mysql:datacenter', 'root', ''
	           ) || die "Could not connect to database: $DBI::errstr";

my $sth = $dbh->prepare('insert into rwc (hostname,asset_tag,make,model,serial_number,cab) values (?,?,?,?,?,?)');


open(INPUT,"datacenter.csv");
while(defined(my $line=<INPUT>)){
	#skip header
	if($line=~/^Timestamp/){
		next;
	}
	my($timestamp,$hostname,$asset_tag,$make,$model,$serial_number,$cab,$ping)=split(/,/,$line);
	$sth->execute($hostname,$asset_tag,$make,$model,$serial_number,$cab);
}
