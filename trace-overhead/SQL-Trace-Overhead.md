
Oracle SQL Trace: Is it Safe for Production Use?
============================================================

Perhaps you have been approached by a client or manager and been given the task of troubleshooting one or more slow running SQL statements.

The request may have been even more broad:  an application is slow, it has been determined that that problem must be the database, and so now it is on the DBA's desk. And you are the DBA.

When trying to solve such problems it is not too unusual to start with an AWR report, examining the execution plans, and drilling down in ASH to determine where the problem lies.

While some good information may have been found, maybe it wasn't quite enough information to determine the cause of the application slowness.

While ASH, AWR and execution plans may be good at showing you where there may be some problems, they are not always enough show you just where a problem lies.


## Test Configuration

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


NOTE: Be sure to create and populate this branch.

All of the code and trace files used for this article are found here:  [pythian blog - Oracle Client Result Cache](https://github.com/pythian/blog-files/tree/oracle-trace-overhead)

Further details are found in the README.md in the github repo.

The following Bash script is used as a driver:

```bash
#!/usr/bin/env bash

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


db='ora192rac-scan/pdb1.jks.com'
username='evs'
password='evs'

baseDir=/mnt/vboxshare/trace-overhead
mkdir -p $baseDir
ln -s $baseDir .

timestamp=$(date +%Y%m%d%H%M%S)
traceDir=$baseDir/trace/${rcMode}-${traceLevel}-${timestamp}
rcLogDir=$baseDir/trc-ovrhd
rcLogFile=$rcLogDir/xact-count-${rcMode}-${traceLevel}-${timestamp}.log 
traceFileID="TRC-OVRHD-$traceLevel-$timestamp"

[[ -n $traceArgs ]] && { traceArgs="$traceArgs --tracefile-id $traceFileID"; }

[[ $rcMode == 'trace' ]] && { mkdir  -p $traceDir; }
mkdir -p $rcLogDir

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode flood \
	--tx-behavior commit \
	--max-sessions 50 \
	--exe-delay 0 \
	--db "$db" \
	--username $username \
	--password "$password" \
	--runtime 1200 \
	--tracefile-id $traceFileID \
	--xact-tally \
	--xact-tally-file  $rcLogFile \
	--pause-at-exit \
	--sqldir $(pwd)/SQL  $traceArgs


# cheating a bit as I know where the trace files are on the server
# ora192rac01:/opt/oracle/diag/rdbms/orcl/orcl/trace/orcl_ora_24103_RC-20230703142522.trc
[[ -n $traceArgs ]] && { 
	scp -p oracle@ora192rac01:/u01/app/oracle/diag/rdbms/cdb/cdb1/trace/orcl_ora_*_${traceFileID}.trc $traceDir
	scp -p oracle@ora192rac02:/u01/app/oracle/diag/rdbms/cdb/cdb2/trace/orcl_ora_*_${traceFileID}.trc $traceDir
	echo Trace files are in $traceDir/
	echo 
}

echo RC Log is $rcLogFile
echo 


```

## EVS Schema

EVS is the `Electric Vehicles Sighting` Schema.


The data was obtained from the [Electric Vehicle Population](https://catalog.data.gov/dataset/electric-vehicle-population-data) data set.

See [create-csv.sh]( PUT PYTHIAN REPO URL FOR FILE HERE)


====

A subset of cities.csv and ev-models.csv will be used as bind variables for sqlrun


## Testing

The testing will also use the `mrskew` option of `--where='$af<1'` to get test results, just as it was against the trace data from the application.

As discussed previously, the 0.7 second value was used to discern between application induced SNMFC and user induced SNMFC.

In automated testing there would normally be no such waits, but as seen later, there are two possible causes of lengthy SNMFC waits in this testing.

The standard value of 1 second will be used, as there are no 'users'.  There may be some lengthy SNMFC values caused by Client Result Cache, and one caused the test harness.

Each test will consist of 20 clients, each running for 20 minutes, with sql trace enabled.

The tracing is at level 12, so it included waits as well as bind variable values.

A total of 4 tests will be run:

* No additional network latency (client and database are co-located)
** without Client Result Cache
** with Client Result Cache
* Network latency of ~6ms added to simulate client 100 miles distant from database server.
** without Client Result Cache
** with Client Result Cache

The driver script `sqlrun-rc.sh` will call sqlplus and run a script to set table annotations to FORCE or MANUAL for the tests.

FORCE: the client will use client result cache
MANUAL: the client will not use client result cache


## Test Environment

The test environment is as follows:

* Database Server:
** Lestrade
** i5 with single socket and 4 cores
** 32 G RAM
** 1G network
* Client 1
** Poirot
** VM with 3 vCPUs
** 8G RAM
* Client 2
** sqlrun
** VM with 3 vCPUs
** 8G RAM

Oracle database is 19.3
Oracle clients are 19.16
Test software is Perl 5, with the DBI and DBD::Oracle modules


