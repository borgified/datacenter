#!/usr/bin/perl

use warnings;
use strict;
use CGI qw/:standard/;
use DBI;

my $my_cnf = '/secret/my_cnf.cnf';

my $dbh = DBI->connect("DBI:mysql:"
    . ";mysql_read_default_file=$my_cnf"
    .';mysql_read_default_group=inventory',
    undef, 
    undef
   ) or die "something went wrong ($DBI::errstr)";


my $id = param('id');
my $position = param('position');
my $cab = param('cab');

#get the affected id's
my $sth=$dbh->prepare("select id from rwc where cab = \'$cab\' and position > $position order by position asc");

#shift positions down for each entry in cab below deleted entry
my $sth2=$dbh->prepare('update rwc set position = ? where id = ?');

#delete the entry
my $sth3=$dbh->prepare("delete from rwc where id=\'$id\'");


$sth->execute();

my $new_position = $position;

while(my @line=$sth->fetchrow_array()){
	my $id = shift(@line);
	$sth2->execute($new_position,$id);
	$new_position++;
}

$sth3->execute();


print header,start_html;
print <<EOF;
<meta http-equiv="REFRESH" content="0;url=inventory.pl">
EOF
print end_html;
