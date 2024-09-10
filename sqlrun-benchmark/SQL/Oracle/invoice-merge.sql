
declare
	i_invoice_number pls_integer;
	i_partnumber pls_integer;
	i_max_partnumber pls_integer;
	i_max_invoice_number pls_integer;
	i_invoice_chk pls_integer;
	i_invoice_hdr_lock pls_integer;
	i_price number;
	b_verbose boolean := false;
	b_insert_success boolean := false;
	b_update_success boolean := false;
begin
	dbms_random.seed(to_number(to_char(sysdate,'sssssfx')) * sys_context('userenv','sid') + sys_context('userenv','sessionid'));

	select max(partnumber) into i_max_partnumber from products;
	select max(invoice_number) into i_max_invoice_number from invoice_headers;

	i_invoice_number := floor(dbms_random.value(1, i_max_invoice_number + 100));
	if b_verbose then
		dbms_output.put_line('merge i_invoice_number: ' || i_invoice_number);
	end if;
	--i_invoice_number := 850;

	select count(*) into i_invoice_chk from invoice_headers where invoice_number = i_invoice_number;

	if i_invoice_chk = 0 then

		begin 

			b_insert_success := true;

			insert into invoice_headers (invoice_number, customer_name, customer_address, total_amount)
			values(
				i_invoice_number,
				dbms_random.string('L',floor(dbms_random.value(10,33))),
				dbms_random.string('L',floor(dbms_random.value(30,80))),
				cast(null as number)
			);

			for i in floor(dbms_random.value(1, 10)) loop
	
				i_partnumber := floor(dbms_random.value(1, i_max_partnumber));

				select price into i_price from products where partnumber = i_partnumber;

				insert into invoice_lines (invoice_number, partnumber, quantity, price)
				values (i_invoice_number, i_partnumber, floor(dbms_random.value(1, 100)), i_price);

			end loop;
		exception
		when dup_val_on_index then
			b_insert_success := false;
		end;

	else

		begin
			select invoice_number into i_invoice_hdr_lock from invoice_headers where invoice_number = i_invoice_number for update;
		
			declare
   			cursor c_invoice_lines is
      			select * from invoice_lines where invoice_number = i_invoice_number for update;
			begin

				b_update_success := true;

   			for invoice_rec in c_invoice_lines
   			loop
      			-- Update the price for the current row
      			update invoice_lines
      			set quantity = floor(dbms_random.value(1,5))
      			where current of c_invoice_lines;
   			end loop;
			end;
	exception
	when others then
		b_update_success := false;
	end;

	end if;

	if b_update_success or b_insert_success then
		update invoice_headers set total_amount = (select sum(quantity * price) from invoice_lines where invoice_number = i_invoice_number)
		where invoice_number = i_invoice_number;
	end if;

	commit;
	
end;


