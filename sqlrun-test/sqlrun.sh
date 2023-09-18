#!/bin/bash		

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode flood \
	--tx-behavior rollback \
	--max-sessions 20 \
	--exe-delay 0.1 \
	--db '//ora192rac-scan/pdb1.jks.com' \
	--username jkstill \
	--password grok \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--runtime 1200 \
	#--exit-trigger
	#--debug 
	##--trace 
	#--timer-test
