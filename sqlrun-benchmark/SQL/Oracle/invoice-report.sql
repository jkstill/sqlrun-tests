
declare
	i_invoice_number invoice_headers.invoice_number%type;
	i_total number;
	i_low_invoice_number invoice_headers.invoice_number%type;
	i_high_invoice_number invoice_headers.invoice_number%type;
	i_max_invoice_number invoice_headers.invoice_number%type;
	i_min_invoice_number invoice_headers.invoice_number%type;
	b_verbose boolean := false;
begin
	select min(invoice_number), max(invoice_number)	into i_min_invoice_number, i_max_invoice_number from invoice_headers;

	dbms_random.seed(to_number(to_char(sysdate,'sssssfx')));

	i_low_invoice_number := trunc(dbms_random.value(i_min_invoice_number, i_max_invoice_number));
	i_high_invoice_number := trunc(dbms_random.value(i_low_invoice_number, i_max_invoice_number));

	if b_verbose then
		dbms_output.put_line('Low Invoice Number: ' || i_low_invoice_number);
		dbms_output.put_line('High Invoice Number: ' || i_high_invoice_number);
	end if;

	select  sum(ln.quantity * ln.price) into i_total
	from invoice_headers hr
	join invoice_lines ln on hr.invoice_number = ln.invoice_number
		and hr.invoice_number between i_low_invoice_number and i_high_invoice_number
	join products pr on ln.partnumber = pr.partnumber;

end;

