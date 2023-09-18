#!/bin/bash		

sessions=200
runtime=60

	#--context-tag "SQLRUN-${sessions}" \

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode flood \
	--connect-delay 0.1 \
	--tx-behavior rollback \
	--max-sessions $sessions \
	--runtime $runtime \
	--exe-delay 0.1 \
	--db avail12c01/p01 \
	--username scott \
	--password tiger  
	#--trace
