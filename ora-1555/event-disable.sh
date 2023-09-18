#!/bin/bash		
		
	#--db '//ora12c102rac01/p1.jks.com' \



unset ORAENV_ASK
. /usr/local/bin/oraenv <<< c12 >/dev/null

sqlplus -L -s jkstill/grok@p1 << EOF
set feedback off term off heading off
alter system set events '1555 trace name context off';
exit;
EOF

