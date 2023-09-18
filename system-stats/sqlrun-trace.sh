#!/bin/bash		
		
	#--db '//ora12c102rac01/p1.jks.com' \

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode tsunami \
	--max-sessions 1 \
	--db  '//ora12c102rac01/examples.jks.com' \
	--username jkstill \
	--password grok \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--exe-delay 0.005 \
	--runtime 10 \
	--trace 
