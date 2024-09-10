#!/usr/bin/env bash

: << 'COMMENT'

This script is an example of creating trace files, then copying them to another location when the test completes.

The trace files are moved with rsync, then 'ssh rm' is used to remove the .trm files

some variabled are hardcoded - search for hardcoded


COMMENT


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

# hardcoded 
server='ora192rac01'
database='pdb1.jks.com'

#server='lestrade'
#database='orcl'

db="$server/$database"
username='evs'
password='evs'

baseDir=/mnt/vboxshare/trace-overhead
stMkdir -p $baseDir

# hardcoded

ln -s $baseDir .

timestamp=$(date +%Y%m%d%H%M%S)
traceDir=$baseDir/trace/${rcMode}-${traceLevel}-${timestamp}
rcLogDir=$baseDir/trc-ovrhd
rcLogFile=$rcLogDir/xact-count-${rcMode}-${traceLevel}-${timestamp}.log 
traceFileID="TRC-OVRHD-$traceLevel-$timestamp"

[[ -n $traceArgs ]] && { traceArgs="$traceArgs --tracefile-id $traceFileID"; }

[[ $rcMode == 'trace' ]] && { stMkdir  -p $traceDir; }


stMkdir -p $rcLogDir

#cat <<-EOF
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

#EOF

#exit


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
	#scp -p oracle@ora192rac01:/u01/app/oracle/diag/rdbms/cdb/cdb1/trace/orcl_ora_*_${traceFileID}.trc $traceDir
	#scp -p oracle@ora192rac02:/u01/app/oracle/diag/rdbms/cdb/cdb2/trace/orcl_ora_*_${traceFileID}.trc $traceDir

	# get the trace files and remove them
	# space considerations require removing the trace files after retrieval
	# hardcoded
	rsync -av --remove-source-files oracle@ora192rac01:/u01/app/oracle/diag/rdbms/cdb/cdb1/trace/*${traceFileID}.trc ${traceDir}/

	# remove the .trm files
	ssh oracle@ora192rac01 rm /u01/app/oracle/diag/rdbms/cdb/cdb1/trace/*${traceFileID}.trm
	# hardcoded

	echo Trace files are in $traceDir/
	echo 
}

echo RC Log is $rcLogFile
echo 

	#--client-result-cache-trace \
	#--exit-trigger
	#--debug 
	##--trace 
	#--timer-test
	#--parmfile parameters.conf \
	#--sqlfile sqlfile.conf  \
	# --driver Oracle \
	#--username evs \
	#--password evs \


