with data as (
	select 
		level id,
		dbms_random.string('L',floor(dbms_random.value(10,33))) c1
	from dual
	connect by level <= 1500
)
select * from data d
where d.id between floor(dbms_random.value(42,200))  and floor(dbms_random.value(900,1500))
