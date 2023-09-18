#!/bin/bash		
		
	#--db '//ora12c102rac01/p1.jks.com' \

./sqlrun.pl \
	--exe-mode truly-random \
	--connect-mode tsunami \
	--max-sessions 5 \
	--db '//ora12c102rac01/p1.jks.com' \
	--username jkstill \
	--password grok \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--exe-delay 0.005 \
	--runtime 120
	#--trace 
