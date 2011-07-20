#!/usr/bin/perl -w

use DBI;

$number_of_jobs_to_run_in_parallel=3;

my %running_jobs;
my %results;

my $dbh = DBI->connect('DBI:mysql:datacenter', 'root', ''
	           ) || die "Could not connect to database: $DBI::errstr";

#reset all the old ping results
my $sth=$dbh->prepare('update rwc set ping = -1');
$sth->execute();

$sth = $dbh->prepare('select distinct hostname from rwc');
$sth->execute();

while (my $hostname=$sth->fetchrow_array()){
	push(@hosts,$hostname);
}

my $number_of_hosts=@hosts;

#keep looping until we run out of hosts
while ($number_of_hosts != 0){
	
	#take one host out of the array (pop gets the last element of array)

	$host=pop(@hosts);

#since we're using pop instead of shift, the order of processing the array of hosts
#will be in reverse order, dont use shift, its slower.

	#reset the array size
	#remember to reset array size everytime you make changes to the array
	#ie. push/pop, that way our while loop will be using the most current
	#value of $number_of_hosts

	$number_of_hosts=@hosts;

	#we keep track of how many jobs we are running with the
	#number of entries we have in %running_jobs

	$number_of_jobs_running=keys %running_jobs;
	print "number of jobs currently running: $number_of_jobs_running\n";

	if($number_of_jobs_running<$number_of_jobs_to_run_in_parallel){

		my $pid = fork();
		if ($pid) {
# parent
			#add an entry to %running_jobs
			$running_jobs{$pid}="";
		} elsif ($pid == 0) {
# child

###### run your program here

	my $dbh = DBI->connect('DBI:mysql:datacenter', 'root', '') || die "Could not connect to database: $DBI::errstr";
	my $sth2 = $dbh->prepare('update rwc set ping = ? where hostname = ?');

	my $ping_output=`ping -c1 -w1 $host 2>/dev/null`;

	$sth2->execute($?,$host);	

###### end of run your program here
			exit(0);

		}else{
			die "couldn’t fork: $!\n";
		}
	}else{
		push(@hosts,$host); #put the current host back into the array
				    #since we havent pinged it yet 
			    	    #needed this hack because this current host 
				    #would get skipped due to the else statement
		$number_of_hosts=@hosts;
		foreach (sort keys(%running_jobs)) {
			waitpid($_, 0);
			@running_jobs=keys(%running_jobs);
			print "currently running: @running_jobs\n";
			#job is complete, delete entry from %running_jobs
			delete($running_jobs{$_});
		}
	}
}
