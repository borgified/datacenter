#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use CGI qw/:standard/;
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

my $owner = $session->param('username');
chomp($owner);





my $my_cnf = '/secret/my_cnf.cnf';

my $dbh = DBI->connect("DBI:mysql:"
    . ";mysql_read_default_file=$my_cnf"
    .';mysql_read_default_group=inventory',
    undef,
    undef
   ) or die "something went wrong ($DBI::errstr)";

my $task = $session->param('task');

if($task eq 'list'){

	my @claim_checked_servers = $cgi->param('claim');
	#my $sth = $dbh->prepare('update rwc set owner=? where hostname=?');
	my $sth = $dbh->prepare('update rwc set owner=concat_ws(\' \',owner, ?) where hostname=?');
	
	foreach my $server (@claim_checked_servers){
		$sth->execute($owner,$server);
	}
	
	my @unclaim_checked_servers = $cgi->param('unclaim');
	#$sth = $dbh->prepare('update rwc set owner=\'\' where hostname=?');
	$sth = $dbh->prepare('update rwc set owner=replace(owner, ? ,\'\') where hostname=?');
	
	foreach my $server (@unclaim_checked_servers){
		$sth->execute(" $owner",$server);
	}
}elsif($task eq 'support'){
#start coding here
}else{

}
print $cgi->redirect(-location=>'list.pl');
