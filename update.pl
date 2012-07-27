#!/usr/bin/perl


#asset_tag.66 : 652
#cab.66 : 2-01
#dept.66 :
#hostname.66 : snowwhite
#make.66 : Sun
#model.66 : t2000
#position.66 : 1
#serial_number.66 : 0629nnn01w

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



my $sql="update rwc set ";
my $query = new CGI;

print header,start_html;
my $name;
my $id;

foreach my $field (sort ($query->param)){
	foreach my $value ($query->param($field)){
		($name,$id)=split(/\./,$field);
		$sql=$sql."$name = \'$value\' , ";
	}
}

$sql =~s/ , $/ where id = $id/;

my $sth=$dbh->prepare($sql);
$sth->execute();

print <<EOF;
<meta http-equiv="REFRESH" content="0;url=inventory.pl">
EOF
