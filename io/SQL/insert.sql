
insert into io_test
select o.*, sys_context('userenv','sid') || '.' ||  sys_context('userenv','sessionid')
from dba_objects o


