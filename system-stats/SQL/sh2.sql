with data as (
	select /*+ index(sales) no_merge */ *
	from sh.sales
)
select sum(amount_sold) from data
