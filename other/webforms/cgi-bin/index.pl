#!/usr/bin/perl

use warnings;
use strict;
use CGI qw/:standard/;


my $cgi = new CGI;
my $status = $cgi->param('status');

if(!defined $status){
	$status=" ";
}else{
	$status="bad username/password combo";
}

my $output = <<EOO

<html>
<h1>Welcome to the Server Orphanage</h1>

Here you can claim ownership of a server or give yourself (and others) shared custody of servers (multiple owners).
If you are not a server owner but a user, you may also register yourself as such.

The difference between a server owner and a user is the type of emails you might get. (see table below)

<table>
<tr><th></th><th>owner</th><th>user</th></tr>
<tr><td>downtime notification</td><td>yes</td><td>yes</td></tr>
<tr><td>questions - maintenance contract</td><td>yes</td><td>no</td></tr>
<tr><td>questions - backup related</td><td>yes</td><td>no</td></tr>
<tr><td></td><td></td><td></td></tr>
<tr><td></td><td></td><td></td></tr>
</table>
<form method="post" action="/cgi-bin/orphanage/login.pl">
Login with your windows username/password<p>
username: <input type="text" name="username">
password: <input type="password" name="password"><p>
$status<p>
<input type="submit" value="login">
<input type="submit" value="logout" name="logout">
</form>

EOO
;


print $cgi->header;
print $output;
