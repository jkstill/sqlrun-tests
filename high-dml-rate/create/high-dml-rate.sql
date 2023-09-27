
drop table high_dml_rate cascade constraints purge;

drop sequence high_dml_rate_seq;

create sequence high_dml_rate_seq start with 1000000 cache 10000;

create table high_dml_rate (
	pk number(12) not  null,
	load_time timestamp with time zone not null,
	payload varchar2(4000) not null
)
storage (maxextents unlimited)
tablespace high_dml_rate
/


create index high_dml_rate_pk_idx on high_dml_rate(pk) reverse
storage (maxextents unlimited)
tablespace high_dml_rate
/

alter table high_dml_rate add constraint high_dml_rate_pk primary key (pk);

create index high_dml_rate_load_time_idx on high_dml_rate(load_time, pk)
storage (maxextents unlimited)
tablespace high_dml_rate
/


col table_name format a30
col tablespace_name format a30
col index_name format a30
col sequence_name format a30
col min_value format 99,999,999
set linesize 200 trimspool on
set pagesize 100


select table_name, tablespace_name
from user_tables where tablespace_name = 'HIGH_DML_RATE';

select table_name,index_name, tablespace_name
from user_indexes where tablespace_name = 'HIGH_DML_RATE';



select sequence_name, min_value from user_sequences where sequence_name like 'HIGH%';






