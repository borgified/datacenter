#!/usr/bin/perl

use warnings;
use strict;
use CGI qw/:standard/;


my $cgi = new CGI;
my $status = $cgi->param('status');

if(!defined $status){
	$status=" ";
}elsif($status eq 'login_error'){
	$status="bad username/password combo";
}elsif($status eq 'timeout'){
	$status="session timed out, login again";
}

my $output = <<EOO

<html>
<h1>Welcome to the Server Orphanage</h1>

Here you can claim ownership of a server
<p>
Owning a server gets you:
<li>email notification of hardware maintenance/downtimes
<li>ability to determine whether a server needs to covered under a support contract
<p>
<form method="post" action="/cgi-bin/orphanage/login.pl">
Login with your windows username/password<p>
username: <input type="text" name="username">
password: <input type="password" name="password"><p>
$status<p>
<input type="submit" value="login">
</form>

EOO
;


print $cgi->header;
print $output;
