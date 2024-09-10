
-- contents unimportant

define product_count=1000
define invoice_count=1000

drop table products cascade constraints purge;
drop table invoice_headers cascade constraints purge;
drop table invoice_lines cascade constraints purge;
drop table plsql_test cascade constraints purge;

exec dbms_random.seed(sys_context('userenv','sessionid'))

--#############
--### Products
--#############

-- 1000 rows
create table products
pctfree 5
initrans 50
as
select 
	level partnumber,
	dbms_random.string('L',floor(dbms_random.value(10,33))) name,
	dbms_random.string('L',floor(dbms_random.value(100,200))) description,
	dbms_random.value(10,1000) price
from dual
connect by level <= &product_count;

create index products_pk_idx on products(partnumber) pctfree 5 initrans 50 ;

alter table products add constraint products_pk primary key(partnumber);

exec dbms_stats.gather_table_stats(null,'PRODUCTS')

--####################
--### invoice_headers
--####################
create table invoice_headers
pctfree 5
initrans 50
as
select 
	level invoice_number,
	dbms_random.string('L',floor(dbms_random.value(10,33))) customer_name,
	dbms_random.string('L',floor(dbms_random.value(30,80))) customer_address,
	cast(null as number) total_amount
from dual
connect by level <= &invoice_count;

create index invoice_headers_pk_idx on invoice_headers(invoice_number) pctfree 5 initrans 50 ;
alter table invoice_headers add constraint invoice_headers_pk primary key(invoice_number);
exec dbms_stats.gather_table_stats(null,'INVOICE_HEADERS')

--####################
--### invoice_lines
--####################
create table invoice_lines(
	invoice_number integer,
	partnumber integer,
	quantity integer,
	price number
)
pctfree 5
initrans 50
/


create index invoice_lines_pk_idx on invoice_lines(invoice_number,partnumber) pctfree 5 initrans 50 ;
alter table invoice_lines add constraint invoice_lines_pk primary key(invoice_number,partnumber);

declare
	i_partnumber integer;
	i_quantity integer;
	i_price number;
begin
	for i in 1..&invoice_count loop
		for j in 1..floor(dbms_random.value(10,20)) loop

			<<insert_invoice_line>>
			begin
				i_partnumber := floor(dbms_random.value(1,&product_count));
				i_quantity := floor(dbms_random.value(1,10));
				select price into i_price from products where partnumber = i_partnumber;

				insert into invoice_lines (invoice_number,partnumber,quantity,price)
				values(
					i, -- invoice number
					i_partnumber, -- partnumber
					i_quantity, -- quantity
					i_price -- price
				);
			exception
				when dup_val_on_index then
					--dbms_output.put_line('Error inserting invoice line for invoice ' || i || ' partnumber ' || i_partnumber);
					goto insert_invoice_line;
			end;

		end loop;
	end loop;

	commit;

end;
/

exec dbms_stats.gather_table_stats(null,'INVOICE_LINES')


-- plsql test table

create table plsql_test (
	c1 varchar2(30),
	c2 integer
)
/



