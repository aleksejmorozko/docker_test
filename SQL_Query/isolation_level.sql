drop table if exists t; create table t(id serial, b int); insert into t (b) values (0);

begin;
set transaction isolation level repeatable read;
set transaction isolation level read committed;
set transaction isolation level read uncommitted;
set transaction isolation level serializable;

update t set b=b+1;

savepoint a0; 
savepoint a1;
rollback to savepoint a0;
commit;

select * from t order by id;
select xmin, xmax, * from t;

select txid_current();
select txid_current_snapshot();

select virtualxid, mode from pg_locks where pid = pg_backend_pid() and locktype = 'virtualxid';

create extension if not exists pgrowlocks;
select * from pgrowlocks('t');