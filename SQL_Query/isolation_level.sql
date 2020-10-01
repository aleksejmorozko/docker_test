create table t(id serial, name text);
insert into t (name) values ('dura'),('lex'),('sed'),('lexxx');

begin;
set transaction isolation level repeatable read;
update t set name = 'lex1' where id = 1;
update t set name = 'lex1' where id = 2;
update t set name = 'lex1' where id = 3;

rollback;
commit;

select * from t;
select xmin, xmax, * from t;

select txid_current();
select txid_current_snapshot();

select virtualxid, mode from pg_locks 
where pid = pg_backend_pid() and locktype = 'virtualxid';

create extension if not exists pgrowlocks;
select * from pgrowlocks('t');