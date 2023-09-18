declare
	ora1555 exception;
	pragma exception_init(ora1555,-1555);
begin
	-- the error will still cause a trace file to be created via the 'set events' command
	-- without causing the script to fail
	begin
		raise ora1555;
	exception
	when others then null;
	end;
end;
