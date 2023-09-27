#!/bin/bash		

timestamp=$(date +%Y%m%d%H%M%S)

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode trickle \
	--connect-delay 1 \
	--tx-behavior commit \
	--tx-per-transaction 100 \
	--max-sessions 3 \
	--exe-delay 0 \
	--db 'ora192rac02/pdb3.jks.com' \
	--username jkstill \
	--password grok \
	--runtime 3600 \
	--sqldir $(pwd)/SQL 


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
