--function to create new users
select more_users(100000);
select count(*) from users;
select * from users limit(5);
--delete not needed users
delete from users
--how fast work query 
explain 
select * from users 
where b = CONCAT('user_', cast(round(random()*1000000) as text));
select CONCAT('user_', cast(round(random()*1000000) as text));
--make function
create or replace function more_users(val int) returns void as
$$
declare
t integer =(select count(*) from users);
begin
	for t in t..$1
	loop 
		insert into users values(t, Concat('user_', cast(t as text)), current_date);
	end loop; 
--commit;
end;
$$ language plpgsql;

truncate users;
drop table users;
drop function more_users;
drop index fast_user;
create index fast_user on users(b);
--select Concat('user_',  cast((select count (*) from users) as char(20)));
create table users(a int, b text, c date);
SELECT pg_size_pretty(pg_database_size('postgres'));
