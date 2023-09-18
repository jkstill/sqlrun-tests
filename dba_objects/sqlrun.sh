#!/bin/bash		
		
	#--db '//ora12c102rac01/p1.jks.com' \
	#--db p1 \
	#--db '//rac19c01/pdb1.jks.com' \

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode flood \
	--max-sessions 150 \
	--db '//192.168.1.236/pdb1' \
	--username jkstill \
	--password grok \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--exe-delay 0.01 \
	--runtime 120
	#--trace 
