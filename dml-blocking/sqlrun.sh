#!/bin/bash		

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode tsunami \
	--max-sessions 31 \
	--exe-delay 0.001 \
	--db '//rac19c01/pdb1.jks.com' \
	--username jkstill \
	--password grok \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--runtime 1800
	#--debug 
	#--exit-trigger
	##--trace 
	#--timer-test
