

begin
	dbms_stats.gather_system_stats('START');

	dbms_lock.sleep(3600);

	dbms_stats.gather_system_stats('STOP');
end;
/

