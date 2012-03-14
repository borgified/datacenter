#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use CGI qw(:standard);
use CGI::Session qw/-ip-match/;
use File::Spec;

my $my_cnf = '/secret/my_cnf.cnf';

my $dbh = DBI->connect("DBI:mysql:"
    . ";mysql_read_default_file=$my_cnf"
    .';mysql_read_default_group=inventory',
    undef, 
    undef
   ) or die "something went wrong ($DBI::errstr)";

my $sth = $dbh->prepare('select hostname,owner,backup,support_notes,os from rwc');

$sth->execute();

my @categories = qw/hostname owner backup support_notes os hw_maintenance sw_maintenance/;
my %data;

while(my @results = $sth->fetchrow_array()){
		$data{$results[0]}{'owner'}=$results[1];
		$data{$results[0]}{'backup'}=$results[2];
		$data{$results[0]}{'support_notes'}=$results[3];
		$data{$results[0]}{'os'}=$results[4];
		$data{$results[0]}{'hw_maintenance'}=$results[5];
		$data{$results[0]}{'sw_maintenance'}=$results[6];
}

my $cgi = new CGI;

my $sid = $cgi->cookie("CGISESSID") || undef;
my $session = new CGI::Session(undef, $sid, {Directory=>File::Spec->tmpdir});
	
if($sid ne $session->id()){
	$session->delete();
	print $cgi->redirect(-location=>'index.pl?status=timeout');
	exit;
}

my $owner = $session->param('username');
chomp($owner);

$session->param('data',\%data);

print $cgi->header,$cgi->start_html;
print $cgi->h1("the server orphanage");

$session->param('task','list'); #this tells modifytable.pl what params to fetch and what sql to execute

print "<form action='modifytable.pl' method=post>\n";
print "<input type=submit value='Submit changes'> as checked below\n";


print $cgi->h3("these are systems I own");
print "<a href='support.pl'>manage support contract</a><p>";
print "<font color=#FF0000>check to <b>release</b> ownership</font>\n";
print "<table border=1>\n";
print "<tr><th></th><th>hostname</th><th>owner</th><th>backup</th><th>support_notes</th><td>os</td></tr>\n";
foreach my $key (sort keys %data){
	if($data{$key}{'owner'} =~ /\b$owner\b/){
		print "<tr><td><input type='checkbox' name='unclaim' value=$key></td><td>$key</td><td>$data{$key}{'owner'}</td><td>$data{$key}{'backup'}</td><td>$data{$key}{'support_notes'}</td><td>$data{$key}{'os'}</td></tr>\n";
	}
}
print "</table>\n";

print "<hr>\n";

print $cgi->h3("these are systems with no owner");
print "<font color=#FF0000>check to <b>claim</b> ownership</font>\n";
print "<table>\n";
print "<tr><th></th><th>hostname</th></tr>\n";
foreach my $key (sort keys %data){
	if($data{$key}{'owner'} eq ''){
		print "<tr><td><input type='checkbox' name='claim' value=$key></td><td>$key</td></tr>\n";
	}
}
print "</table>\n";


print "<hr>\n";

print $cgi->h3("these are systems with at least one owner");
print "<font color=#FF0000>check to add yourself as co-owner</font>\n";
print "<table>\n";
print "<tr><th></th><th>hostname</th><th>owner(s)</th></tr>\n";
foreach my $key (sort keys %data){
	if($data{$key}{'owner'} ne '' && $data{$key}{'owner'} !~ /\b$owner\b/){
		print "<tr><td><input type='checkbox' name='claim' value=$key></td><td>$key</td><td>$data{$key}{'owner'}</td></tr>\n";
	}
}
print "</table>\n";


print "</form>\n";


print $cgi->end_html;
