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
	--runtime 1200 \
	--tracefile-id $traceFileID \
	--xact-tally \
	--xact-tally-file  $rcLogFile \
	--pause-at-exit \
	--sqldir $(pwd)/SQL  $traceArgs

#EOF

#exit

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


