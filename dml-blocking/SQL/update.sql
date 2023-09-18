declare
   wait_expired exception;
   pragma exception_init(wait_expired,-30006);
   i integer;
	k integer;
begin
	dbms_output.enable(null);
	k := floor(dbms_random.value(1,10));
   select 1 into i from  dml_blocking where id = k for update wait 2;
	rollback;
	--dbms_output.put_line('ok');
exception
when wait_expired then
   null;
when others then
   raise;
end;


