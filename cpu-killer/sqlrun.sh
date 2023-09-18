#!/bin/bash		
		
	#--db '//ora12c102rac01/p1.jks.com' \
	#--db  '//ora192rac-scan/pdb1.jks.com' \

timeout 180 ./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode tsunami \
	--max-sessions 12 \
	--db  '//o77-swingbench02/soe' \
	--username soe \
	--password soe \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--exe-delay 0.005 \
	--runtime 180 \
	--debug 
	#--trace 
