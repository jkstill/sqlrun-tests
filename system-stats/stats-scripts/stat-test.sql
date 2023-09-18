
alter session set tracefile_identifier = 'STATS-TEST';

col value format a100
set linesize 200

select value from v$diag_info where name = 'Default Trace File';

@10046

begin

DBMS_STATS.GATHER_SYSTEM_STATS (
	gathering_mode => 'INTERVAL',
	interval => 1,
	stattab => 'SYSTEM_STATS',
	statid => 'ST' || to_Char(sysdate,'yyyymmddhh24miss'),
	statown => 'JKSTILL'
);

dbms_lock.sleep(90);

end;
/

@10046_off



