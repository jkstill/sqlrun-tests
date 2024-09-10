
declare
	i_invoice_number pls_integer;
	i_partnumber pls_integer;
	i_max_partnumber pls_integer;
	i_max_invoice_number pls_integer;
	i_invoice_chk pls_integer;
	i_invoice_hdr_lock pls_integer;
	i_price number;
	b_verbose boolean := false;
begin
	dbms_random.seed(to_number(to_char(sysdate,'sssssfx')));

	select max(invoice_number) into i_max_invoice_number from invoice_headers;

	i_invoice_number := floor(dbms_random.value(1, i_max_invoice_number * 2));
	--i_invoice_number := 850;
	if b_verbose then 
		dbms_output.put_line('Checking Invoice number: ' || i_invoice_number);
	end if;

	select count(*) into i_invoice_chk from invoice_headers where invoice_number = i_invoice_number;

	if i_invoice_chk > 0 then

		if b_verbose then 
			dbms_output.put_line('Deleting Invoice number: ' || i_invoice_number);
		end if;

		select invoice_number into i_invoice_hdr_lock from invoice_headers where invoice_number = i_invoice_number for update;
		
		declare
   		cursor c_invoice_lines is
      		select * from invoice_lines where invoice_number = 42 for update;
		begin
   		FOR invoice_rec IN c_invoice_lines
   		loop
      		-- Delete the current row if the quantity is 0
      		if invoice_rec.quantity = 0 then
         		delete from invoice_lines
         		where current of c_invoice_lines;
      		end if;
   		end loop;
		end;

		delete from invoice_headers where invoice_number = i_invoice_number;
	
	commit;

	end if;

	
end;


