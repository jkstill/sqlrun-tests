insert into high_dml_rate(pk, load_time, payload)
select high_dml_rate_seq.nextval, systimestamp, rpad('X',4000,'X') from dual
