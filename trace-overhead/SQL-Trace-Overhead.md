
Oracle SQL Trace: Is it Safe for Production Use?
============================================================

Perhaps you have been approached by a client or manager and given the task of troubleshooting one or more slow running SQL statements.

The request may have been even more broad: an application is slow, it has been determined that that problem must be the database, and so now it is on the DBA's desk. And you are the DBA.

When trying to solve such problems it is not too unusual to start with an AWR report, examining the execution plans, and drilling down in ASH to determine where the problem lies.

While some good information may have been found, it may not quite enough information to determine the cause of the application slowness.

While ASH, AWR and execution plans may be good at showing you where there may be some problems, they are not always enough show you just where a problem lies.

The most accurate represenation of where time is spent during a database session is by invoking SQL Trace.

There are multiple methods for doing this.

- alter session set events '10046 trace name context forever, level [8|12]';
- sys.dbms_system.set_ev(sid(n), serial(n), 10046, 8, '')
- alter session set sql_trace=true;
- [dbms_monitor](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_MONITOR.html#GUID-951568BF-D798-4456-8478-15FEEBA0C78E)

When requesting to run SQL Trace, the the client or responsible user may  object to using SQL Trace due to the additional overhead that tracing may incur.

Of course there must be some overhead when tracing is enabled.

The question is this:  Is the overhead more than the users can bear?

The answer to the question may depend on several factors:

- severity of the issue
- how much it is impacting users
- the urgency of resolving the issue

The answer to these questions help determine if SQL Trace will impose an unbearable burden on the user of affected applications.

So, just how much perceived  overhead is caused by SQL Trace?

The answer is as it is with many things:  It depends.

We can consdider the results of tests run with varying parameters.

## Test Configuration

The way to determine if the overhead is acceptable is do do some testing.

[sqlrun](https://github.com/jkstill/sqlrun) is a tool I developed for running SQL statements against a database using 1+ sessions.  It is highly configurable, following are some of the parameters and configuration possibilities:

* number of sessions
* think time between executions
* connection timing
** connect all simultaneously
** connect as quickly as possible, in succession
** interval between connections
* Multiple SQL statements can be run
* randomize frequency of statements run
* Placeholder values (bind variables) can be supplied from a text file.
* DML can be used
* PL/SQL blocks can be used

Testing will involve two servers: the database server, and the test software on another server.

Network latency between client and server is < 1ms.

Two sets of tests will be run

Note: 'no think time' means that the test SQL statements are run repeatedly in succession, as quickly as the client can submit them.

- no think time
  - latency is < 1ms
- localt client, but with 0.5 seconds think time
  - each client will pause 0.5 seconds between executions

Each of those preceding tests will also run with multiople trace levels

- no tracing
- trace level 8
- trace level 12


There will be 50 clients per test.


==>> NOTE: Be sure to create and populate this branch in the Pythian Git Repo.

All of the code and trace files used for this article are found here:  [pythian blog - Oracle Client Result Cache](https://github.com/pythian/blog-files/tree/oracle-trace-overhead)

Further details are found in the README.md in the github repo.

## Test Environment

The test environment is as follows:

* Database Server:
** ora192rac01 (one node of a 2 node rac
** allocated 4 vCPUs
** 16 G RAM
** 1G network
* Client 
** sqlrun
** VM with 3 vCPUs
** 8G RAM

Oracle database is 19.12
Oracle clients are 19.16
Test software uses Perl 5, with the DBI and DBD::Oracle modules


## Compiling Test Results

CHANGE THIS - not used $af, but am using `cull-snmfc.rc`.

The [mrskew](https://method-r.com/man/mrskew.pdf) utility is a tool created by [Method R](https://method-r.com/) (Cary Millsap and Jeff Holt).

It is used to generate metrics from Oracle SQL Trace files.

This testing makes use of the `mrskew` utility, and the `cull-snmfc.rc` file to skip 'SQL*Net message from client' events >= 1 second.

```text
# cull-snmfc.rc
# Jared Still 2023
# jkstill@gmail.com
# exlude snmfc (SQL*Net message from client) if >= 1 second

--init='

=encoding utf8

'

--where1='($name =~ q{message from client} and $af < 1) or ! ( $name =~ q{message from client})'
```

If you are a user of the Method R Workbench, you may find this rc file useful.



### EVS Schema

EVS is the `Electric Vehicles Sighting` Schema.


The data was obtained from the [Electric Vehicle Population](https://catalog.data.gov/dataset/electric-vehicle-population-data) data set.

See [create-csv.sh]( PUT PYTHIAN REPO URL FOR FILE HERE)


A subset of cities.csv and ev-models.csv will be used as bind variables for sqlrun


### sqlrun-trace-overhead.sh

This script is used to call `sqlrun.pl`.

It accepts up to two parameters:

- no-trace
- trace [8|12]

sqlrun.pl will start 50 clients that run for 10 minutes.

The parameter `--exe-delay` was set to 0 for tests with no think time, and '0.5' for tests that allowed think time.

```bash
#!/usr/bin/env bash

stMkdir () {
	mkdir -p "$@"

	[[ $? -ne 0 ]] && {
		echo
		echo failed to "mkdir -p $baseDir"
		echo
		exit 1
	}

}

# convert to lower case
typeset -l rcMode=$1
typeset -l traceLevel=$2

set -u

[[ -z $rcMode ]] && {
	echo
	echo include 'trace' or 'no-trace' on the command line
	echo
	echo "eg: $0 [trace|no-trace]"
	echo
	exit 1
}

# another method to convert to lower case
#rcMode=${rcMode@L}

echo rcMode: $rcMode

declare traceArgs

case $rcMode in
	trace) 
		[[ -z "$traceLevel" ]] && { echo "please set trace level.  eg $0 trace 8"; exit 1;}
		traceArgs=" --trace --trace-level $traceLevel ";;
	no-trace) 
		traceLevel=0
		traceArgs='';;
	*) echo 
		echo "arguments are [trace|no-trace] - case is unimportant"
		echo 
		exit 1;;
esac


db='ora192rac01/pdb1.jks.com'
#db='lestrade/orcl.jks.com'
username='evs'
password='evs'

baseDir=/mnt/vboxshare/trace-overhead
stMkdir -p $baseDir

ln -s $baseDir .

timestamp=$(date +%Y%m%d%H%M%S)
traceDir=$baseDir/trace/${rcMode}-${traceLevel}-${timestamp}
rcLogDir=$baseDir/trc-ovrhd
rcLogFile=$rcLogDir/xact-count-${rcMode}-${traceLevel}-${timestamp}.log 
traceFileID="TRC-OVRHD-$traceLevel-$timestamp"

[[ -n $traceArgs ]] && { traceArgs="$traceArgs --tracefile-id $traceFileID"; }

[[ $rcMode == 'trace' ]] && { stMkdir  -p $traceDir; }


stMkdir -p $rcLogDir

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode flood \
	--tx-behavior commit \
	--max-sessions 50 \
	--exe-delay 0 \
	--db "$db" \
	--username $username \
	--password "$password" \
	--runtime 600 \
	--tracefile-id $traceFileID \
	--xact-tally \
	--xact-tally-file  $rcLogFile \
	--pause-at-exit \
	--sqldir $(pwd)/SQL  $traceArgs

# do not continue until all sqlrun have exited
while :
do
	echo checking for perl sqlrun to exit completely
        chk=$(ps -flu$(id -un) | grep "[p]erl.*sqlrun")
        [[ -z $chk ]] && { break; }
        sleep 2
done

# cheating a bit as I know where the trace files are on the server
# ora192rac01:/u01/app/oracle/diag/rdbms/cdb/cdb1/trace/
[[ -n $traceArgs ]] && { 

	# get the trace files and remove them
	# space considerations require removing the trace files after retrieval
	rsync -av --remove-source-files oracle@ora192rac01:/u01/app/oracle/diag/rdbms/cdb/cdb1/trace/*${traceFileID}.trc ${traceDir}/

	# remove the .trm files
	ssh oracle@ora192rac01 rm /u01/app/oracle/diag/rdbms/cdb/cdb1/trace/*${traceFileID}.trm

	echo Trace files are in $traceDir/
	echo 
}

echo RC Log is $rcLogFile
echo 

```

### overhead.sh

The script `overhead.sh` was used to allow for unattended running of tests.

```bash
#!/usr/bin/env bash


# run these several times
# pause-at-exit will timeout in 20 seconds for unattended running

for i in {1..3}
do

	./sqlrun-trace-overhead.sh no-trace 

	./sqlrun-trace-overhead.sh trace 8

	./sqlrun-trace-overhead.sh trace 12
done
```

## The Results

The results are interesting

First, let's consider the tests that used a 0.5 second think time.

The number of transactions per client are recorded in a log at the end of each run.

Log results are from `overhead-xact-sums.sh`

The results are stored in directories named for the tests.

```bash
#!/usr/bin/env bash

#for rcfile in trace-overhead-no-think-time/trc-ovrhd/* 
for dir in trace-overhead-.5-sec-think-time trace-overhead-no-think-time
do
	echo
	echo "dir: $dir"
	echo

	for traceLevel in 0 8 12
	do
		testNumber=0
		echo "  Trace Level: $traceLevel"
		for rcfile in $dir/trc-ovrhd/*-$traceLevel-*.log
		do
			(( testNumber++ ))
			basefile=$(basename $rcfile)
			xactCount=$(awk '{ x+=$2 }END{printf("%10d\n",x)}'  $rcfile)
			printf "     Test: %1d  Transactions: %8d\n" $testNumber $xactCount
		done
		echo
	done
done

echo
```


### 0.5 Seconds Think Time

translate to tables?


chart?

dir: trace-overhead-.5-sec-think-time

  Trace Level: 0
     Test: 1  Transactions:    59386
     Test: 2  Transactions:    59454
     Test: 3  Transactions:    59476

  Trace Level: 8
     Test: 1  Transactions:    59415
     Test: 2  Transactions:    59365
     Test: 3  Transactions:    59334

  Trace Level: 12
     Test: 1  Transactions:    59411
     Test: 2  Transactions:    59177
     Test: 3  Transactions:    59200

### 0 Seconds Think Time


dir: trace-overhead-no-think-time

  Trace Level: 0
     Test: 1  Transactions:  7157228
     Test: 2  Transactions:  6758097
     Test: 3  Transactions:  6948090

  Trace Level: 8
     Test: 1  Transactions:  4529157
     Test: 2  Transactions:  4195232
     Test: 3  Transactions:  4509073

  Trace Level: 12
     Test: 1  Transactions:  4509640
     Test: 2  Transactions:  4126749
     Test: 3  Transactions:  4532872




