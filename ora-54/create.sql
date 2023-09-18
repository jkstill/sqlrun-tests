
drop table ora54_test purge;

create table ora54_test
as 
select rownum pk, o.*
from dba_objects o
/

create unique index ora54_test_pk on ora54_test(pk);

alter table ora54_test add constraint ora54_pk primary key(pk);

exec dbms_stats.gather_table_stats(user,'ORA54_TEST')





