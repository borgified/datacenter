#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;

my $dbh = DBI->connect('DBI:mysql:datacenter', 'root', ''
	           ) || die "Could not connect to database: $DBI::errstr";


my $sth=$dbh->prepare('select id,hostname,asset_tag,make,model,serial_number,cab,position,dept,backup from rwc order by cab, (position+0) asc');
$sth->execute();

print header;
print <<EOF;
<html>
<head>
<style type="text/css">

  .submitLink {
   color: #00f;
   background-color: transparent;
   text-decoration: underline;
   border: none;
   cursor: pointer;
   cursor: hand;
  }

</style>
</head>
EOF


print "<table border='1'>";
print "<tr><th>X</th><th>U</th><th>I</th><th>hostname</th><th>asset_tag</th><th>make</th><th>model</th><th>serial_number</th><th>cab</th><th>position</th><th>dept</th><th>backup</th></tr>";

my $currcab="";

while(my @line=$sth->fetchrow_array()){
	my $id=shift(@line);
	my($hostname,$asset_tag,$make,$model,$serial_number,$cab,$position,$dept,$backup)=@line;

	if($currcab ne $cab){
print <<EOF;
<tr><td></td><td></td><td></td><td colspan='9'><a href="inventory.pl?insert=$cab.$position"><hr style='margin:0'></a></td></tr>
EOF
	}


print <<EOF;
<tr><td><a href="delete.pl?id=$id&position=$position&cab=$cab" onclick="return confirm('confirm deletion of $hostname');">X</a></td>
<form name="form.$id" action="update.pl" method="post">
<td><input type="submit" class="submitLink" value="U"></td>
<td><a href="insert_above.pl?position=$position&cab=$cab">&uarr;</a>&nbsp;<a href="insert_below.pl?position=$position&cab=$cab">&darr;</a></td>
EOF
	my $i=0;
	my @inputname = qw/hostname asset_tag make model serial_number cab position dept backup/;
	foreach my $item (@line){
		print "<td><input type='text' name='$inputname[$i].$id' value='$item'></td>";
		$i++;
	}

	$currcab=$cab;

	print "</tr></form>\n";
}

print "</table>";
print "</html>";
