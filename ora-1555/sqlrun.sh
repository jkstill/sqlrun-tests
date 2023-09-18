#!/bin/bash		
		
	#--db '//ora12c102rac01/p1.jks.com' \

./event-enable.sh

./sqlrun.pl \
	--exe-mode sequential \
	--max-sessions 35 \
	--db  'p1' \
	--username jkstill \
	--password grok \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--runtime 60 \
	--debug 
	#--trace 

./event-disable.sh

