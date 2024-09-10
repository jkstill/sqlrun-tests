#!/bin/bash		

timestamp=$(date +%Y%m%d%H%M%S)

mkdir -p xaction-tally

declare sessions=$1
declare runtime=$2

./sqlrun.pl \
	--exe-mode sequential \
	--tx-behavior commit \
	--max-sessions $sessions \
	--exe-delay 0 \
	--init-trigger \
	--db 'lestrade/pdb01' \
	--username jkstill \
	--password grok \
	--runtime $runtime \
	--xact-tally \
	--xact-tally-file  "xaction-tally/xaction-$runtime-$sessions-$timestamp.log" \
	--sqldir $(pwd)/SQL 


	#--connect-mode flood \
	#--tracefile-id "TEST-${timestamp}" \
	#--trace \
	#--trace-level 12 \
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
