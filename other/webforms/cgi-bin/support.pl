#!/usr/bin/perl

use warnings;
use strict;
use CGI qw(:standard);
use CGI::Session qw/-ip-match/;
use File::Spec;



my $cgi = new CGI;

my $sid = $cgi->cookie("CGISESSID") || undef;
my $session = new CGI::Session(undef, $sid, {Directory=>File::Spec->tmpdir});

if($sid ne $session->id()){
    $session->delete();
    print $cgi->redirect(-location=>'index.pl?status=timeout');
    exit;
}

print $cgi->header,$cgi->start_html;
my $owner = $session->param('username');
my $data = $session->param('data');

$session->param('task','support');

print "<form method=post action='modifytable.pl'>\n";
print "<input type=submit value='Submit changes'>\n";
print "<table border=1>\n";
print "<tr><th>hostname</th><th>hw_maintenance</th><th>sw_maintenance</th></tr>";
foreach my $hostname (sort keys %{$data}){
	if($$data{$hostname}{'owner'} =~ /\b$owner\b/){
		print "<tr><td>$hostname</td>\n";

		if(defined($$data{$hostname}{'hw_maintenance'}) and $$data{$hostname}{'hw_maintenance'} =~ /\byes\b/){
			print "<td><input name=hw_maintenance type=checkbox value=$hostname checked></td>";
		}else{
			print "<td><input name=hw_maintenance type=checkbox value=$hostname></td>";
		}

		if(defined($$data{$hostname}{'sw_maintenance'}) and $$data{$hostname}{'sw_maintenance'} =~ /\byes\b/){
			print "<td><input name=sw_maintenance type=checkbox value=$hostname checked></td>";
		}else{
			print "<td><input name=sw_maintenance type=checkbox value=$hostname></td>";
		}
	
		print "</tr>\n";
	}
}
print "</table>\n";
print "<input type=submit value='Submit changes'>\n";
print "</form>\n";

print $cgi->end_html;

