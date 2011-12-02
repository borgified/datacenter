#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;

my $dbh = DBI->connect('DBI:mysql:datacenter', 'root', ''
	           ) || die "Could not connect to database: $DBI::errstr";


#all this is to detect new additions of columns into the table, so it can be automatically displayed as an html table
my $sth=$dbh->prepare('select column_name from information_schema.columns where table_name="rwc"');

$sth->execute();

my @columns;

while(my $line=$sth->fetchrow_array()){
	push (@columns,$line);
}

#these are the columns we know about and want to have displayed
my @fixed_columns=qw/id hostname asset_tag make model serial_number cab position dept backup/;
my @newcolumns;

foreach my $item (@columns){
	my $found=0;
	foreach my $item2 (@fixed_columns){
		if($item eq $item2){
			$found=1;
		}
	}
	if(!$found && $item ne 'timestamp'){
#@newcolumns contain any new columns not previously accounted for
		push(@newcolumns,$item);
	}
}


#now we can construct a proper sql query based on columns we already know about, plus the ones we dont know about.

my $sql_query="select id,hostname,asset_tag,make,model,serial_number,cab,position,dept,backup";

my $sql_add="";
foreach my $item (@newcolumns){
	$sql_add=$sql_add.",$item";
}
my $sql_end=" from rwc order by cab, (position+0) asc";

$sql_query=$sql_query.$sql_add.$sql_end;

#column autodetect code complete

$sth=$dbh->prepare($sql_query);
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

my $htmlheader="<tr><th>X</th><th>U</th><th>I</th><th>hostname</th><th>asset_tag</th><th>make</th><th>model</th><th>serial_number</th><th>cab</th><th>position</th><th>dept</th><th>backup</th>";

foreach $item (@newcolumns){
	$htmlheader=$htmlheader."<th>$item</th>";
}
$htmlheader=$htmlheader."</tr>";

print $htmlheader;

my $currcab="";

while(my @line=$sth->fetchrow_array()){
	my $id=shift(@line);
	my($hostname,$asset_tag,$make,$model,$serial_number,$cab,$position,$dept,$backup,$ping,$os)=@line;

	my $sizeof_line=@line;

	if($currcab ne $cab){
print <<EOF;
<tr><td></td><td></td><td></td><td colspan='$sizeof_line'><a href="inventory.pl?insert=$cab.$position"><hr style='margin:0'></a></td></tr>
EOF
	}


print <<EOF;
<tr title="$hostname"><td><a href="delete.pl?id=$id&position=$position&cab=$cab" onclick="return confirm('confirm deletion of $hostname');">X</a></td>
<form name="form.$id" action="update.pl" method="post">
<td><input type="submit" class="submitLink" value="U"></td>
<td><a href="insert_above.pl?position=$position&cab=$cab">&uarr;</a>&nbsp;<a href="insert_below.pl?position=$position&cab=$cab">&darr;</a></td>
EOF
	my $i=0;
#	my @inputname = qw/hostname asset_tag make model serial_number cab position dept backup ping os backup_size/;
#the next 3 lines replaces the previous line but allows new columns to be created and automatically accounted for for updating
	my @jc=(@fixed_columns, @newcolumns);
	shift(@jc);
	my @inputname=@jc;

	foreach my $item (@line){
		print "<td><input type='text' name='$inputname[$i].$id' value='$item'></td>";
		$i++;
	}

	$currcab=$cab;

	print "</tr></form>\n";
}

print "</table>";
print "</html>";
