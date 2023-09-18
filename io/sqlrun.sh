#!/bin/bash		

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode flood \
	--tx-behavior commit \
	--max-sessions 10 \
	--exe-delay 0.1 \
	--db '//ora192rac01/pdb1.jks.com' \
	--username jkstill \
	--password grok \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--runtime 600 
	#--exit-trigger \
	#--debug 
	##--trace 
	#--timer-test
