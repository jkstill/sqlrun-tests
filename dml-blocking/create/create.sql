
-- contents unimportant

drop table dml_blocking purge;

create table dml_blocking (id number(20,0), dml_timestamp timestamp);

begin
	for i in 1..10
	loop
		insert into dml_blocking values(i,systimestamp);
	end loop;
	commit;
end;
/





