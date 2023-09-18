
select *
from io_test
where id = sys_context('userenv','sid') || '.' ||  sys_context('userenv','sessionid')
