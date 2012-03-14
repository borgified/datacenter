#!/usr/bin/perl

use strict;
use warnings;
use CGI qw/:standard/;
use DBI;

my $my_cnf = '/secret/my_cnf.cnf';

my $dbh = DBI->connect("DBI:mysql:"
    . ";mysql_read_default_file=$my_cnf"
    .';mysql_read_default_group=inventory',
    undef, 
    undef
   ) or die "something went wrong ($DBI::errstr)";


my $position = param('position');
my $cab = param('cab');

#get the affected id's
my $sth=$dbh->prepare("select id from rwc where cab = \'$cab\' and position >= $position order by position asc");

#increment by one on all the positions below the new entry
my $sth2=$dbh->prepare('update rwc set position = ? where id = ?');

#insert a blank entry at the newly created position
my $sth3=$dbh->prepare("insert into rwc (cab,position) values (\'$cab\',$position)");


$sth->execute();

my $new_position = $position;

while(my @line=$sth->fetchrow_array()){
	$new_position++;
	my $id = shift(@line);
	$sth2->execute($new_position,$id);
}

$sth3->execute();


print header,start_html;
print <<EOF;
<meta http-equiv="REFRESH" content="0;url=inventory.pl">
EOF
print end_html;
