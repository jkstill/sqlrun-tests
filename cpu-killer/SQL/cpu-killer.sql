select count(dummy)
from (
select dummy
from dual
connect by nocycle 1=1 
order by 1
)
