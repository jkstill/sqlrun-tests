#!/usr/bin/env bash


mkdir -p trace
mkdir -p logs

. oraenv <<< cdb2 >/dev/null 2>&1

unset SQLPATH ORACLE_PATH

while read pid file
do
	straceFile="trace/pid-$pid.strace"
	logFile="logs/pid-$pid.files"

	# if file exists, already tracing
	if [[ -r $straceFile ]]; then
		echo "skipping: trace file exists - $straceFile"
	else
		echo "tracing - pid: $pid file: $file"
		sudo ls -l /proc/$pid/fd > $logFile
		sudo strace -uoracle -p $pid -T -ttt -f -o $straceFile &
	fi

done < <(
sqlplus -S -L /nolog <<-EOF

	connect sys/grok@ora192rac02/pdb1.jks.com as sysdba

	set head off feed off pause off verify off
	set pagesize 0
	set linesize 500 trimspool on

	select spid || ' ' ||  tracefile
	from v\$process
	where tracefile like '%TRC-OVRHD%.trc';

	exit

EOF
)

