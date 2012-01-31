#!/usr/bin/perl

use warnings;
use strict;
use CGI qw/:cgi/;

#http://www.perlmonks.org/?node=327902
#http://search.cpan.org/~gbarr/perl-ldap-0.30/lib/Net/LDAP.pod
use Net::LDAPS;
use Net::LDAP;


my %config = do "$ENV{'HOME'}/scripts/secret/github_datacenter_other_webforms_login.pl";


my $host 		= $config{'host'};
my $ldaps 		= $config{'ldaps'};
my $adminDn 	= $config{'adminDn'};
my $adminPwd 	= $config{'adminPwd'};
my $searchBase 	= $config{'searchBase'};

my $username 	= param('username');
my $password	= param('password');

if(!defined $username or !defined $password){
	print "username/password not defined\n";
	exit;
}

my $userdn = testGuid ($username, $password);

if ($userdn)
{
    print "$userdn checks out!\n";
}



sub getUserDn
{
    my $ldap;
    my $guid = shift;
    my $dn;
    my $entry;

    if ($ldaps) {
        $ldap = Net::LDAPS->new($host, verify=>'none') or die "$@";
    }
    else {
        $ldap = Net::LDAP->new($host, verify=>'none') or die "$@";    
    }
    
    my $mesg = $ldap->bind ($adminDn, password=>"$adminPwd");
    
    $mesg->code && return undef;
    
    $mesg = $ldap->search(base => $searchBase, filter => "sAMAccountName=$guid" );
     
    $mesg->code && return undef;
    $entry = $mesg->shift_entry;
     
    if ($entry)
    {
        $dn = $entry->dn;
        #$entry->dump;
    }
    
    
    $ldap->unbind;
    
    return $dn;
}

sub testGuid
{
    my $ldap;

    my $guid = shift;
    my $userPwd = shift;

    my $userDn = getUserDn ($guid);
	
    return undef unless $userDn;
    
    if ($ldaps) {
        $ldap = Net::LDAPS->new($host, verify=>'none') or die "$@";
    }
    else {
        $ldap = Net::LDAP->new($host, verify=>'none') or die "$@";    
    }

    my $mesg = $ldap->bind ($userDn, password=>"$userPwd");
    
    if ($mesg->code)
    {
        # Bad Bind
        print $mesg->error . "\n";
        return undef;
    }
    
    $ldap->unbind;
    
    return $userDn;
}
