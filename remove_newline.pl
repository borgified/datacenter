#!/usr/bin/perl -w

use DBI;

my $dbh = DBI->connect('DBI:mysql:datacenter', 'root', ''
	           ) || die "Could not connect to database: $DBI::errstr";

my $sth=$dbh->prepare('select id,cab from rwc');
my $sth2=$dbh->prepare('update rwc set cab = ? where id = ?');
$sth->execute();

while(my($id,$cab)=$sth->fetchrow_array()){
	chomp($cab);
	$sth2->execute($cab,$id);
}
