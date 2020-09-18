--create table t3 (a serial, b text);
/*
create or replace function afterinsert_t2()
returns trigger as
$$
begin
	insert into t3 (b, c) values
	(new.b, current_date);
	return new;
end;
$$
language 'plpgsql';*/

--alter table t3 add column c date ;
/*drop trigger after_insert_t2 on t;
create trigger after_insert_t2
after insert
on t2
for each row
execute procedure afterinsert_t2();*/
--insert into t2(b) values ('text');
--select * from t3;