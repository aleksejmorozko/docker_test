----------------------- Horizontal sharding ----------------------------
-- SERVER Shard_1
create table news(
	id bigint not null,
	category_id int not null,
    constraint category_id_check CHECK (category_id = 1),
	author character varying not null,
	rate int not null,
	title character varying
);
create index news_category_id_idx on news
using btree(category_id);

-- SERVER Shard_2
create table news(
	id bigint not null,
	category_id int not null,
    constraint category_id_check CHECK (category_id = 2),
	author character varying not null,
	rate int not null,
	title character varying
);
create index news_category_id_idx on news
using btree(category_id);

-- SERVER Shard_3
create table news(
	id bigint not null,
	category_id int not null,
    constraint category_id_check CHECK (category_id <> 1 AND category_id <> 2),
	author character varying not null,
	rate int not null,
	title character varying
);
create index news_category_id_idx on news
using btree(category_id);
--------------------------------------
---Настройка на основном сервере (который распределяет по шардам)
drop table news, news_1, news_2;
create extension postgres_fdw;

--Mapping for Shard_1
create server news_1_server
foreign data wrapper postgres_fdw
options (host '172.17.0.3', port '5432', dbname 'postgres');

create user mapping for postgres
server news_1_server
options (user 'postgres', password '12345678');

--Mapping for Shard_2
create server news_2_server
foreign data wrapper postgres_fdw
options (host '172.17.0.4', port '5432', dbname 'postgres');

create user mapping for postgres
server news_2_server
options (user 'postgres', password '12345678');


--Mapping for Shard_Other
create server news_3_server
foreign data wrapper postgres_fdw
options (host '172.17.0.6', port '5432', dbname 'postgres');

create user mapping for postgres
server news_3_server
options (user 'postgres', password '12345678');

--//--
--drop server news_2_server cascade;
--//--
--Table on MAIN SERVER
create foreign table news_1(
	id bigint not null,
	category_id int not null,
	author character varying not null,
	rate int not null,
	title character varying
)
server news_1_server options (schema_name 'public', table_name 'news');

create foreign table news_2(
	id bigint not null,
	category_id int not null,
	author character varying not null,
	rate int not null,
	title character varying
)
server news_2_server options (schema_name 'public', table_name 'news');


create foreign table news_3(
	id bigint not null,
	category_id int not null,
	author character varying not null,
	rate int not null,
	title character varying
)
server news_3_server options (schema_name 'public', table_name 'news');
---Представление 
drop view news
create view news as 
	select * from news_1
		union
	select * from news_2
		union
	select * from news_3;
--Правило по которому в самой таблице ничего не делается. Делается только на шардах
create rule news_insert as on insert to news do instead nothing;	
create rule news_update as on update to news do instead nothing;	
create rule news_delete as on delete to news do instead nothing;	

create rule news_insert_to_1 as on insert to news 
	where (category_id = 1)
do instead insert into news_1 values (new.*);

create rule news_insert_to_2 as on insert to news 
	where (category_id = 2)
do instead insert into news_2 values (new.*);

create rule news_insert_to_3 as on insert to news 
	where (category_id <> 1 AND category_id <>2)
do instead insert into news_3 values (new.*);

------------------------------
delete from news_3;
select * from news;
select * from news_1;
select * from news_2;
select * from news_3;
insert into news (id, category_id, title, author, rate) VALUES 
	(1, 2, 'fake Channel', 'Jim', 0), 
	(2, 2, 'Yellow NEWS', 'BOB', 3), 
	(3, 1, 'fake NEWS', 'BumB', 4),
	(4, 4, 'Channel 1', 'Brim', 0), 
	(5, 1, 'NEWS NET', 'DovanDID', 3), 
	(6, 2, 'Vojik', 'HarrisonFORD', 4),
	(7, 2, 'fake Channel', 'JimBIM', 0), 
	(8, 2, 'Yellow NEWS', 'BOB', 3), 
	(9, 5, 'fake NEWS', 'BOBDumb', 4),
	(10, 3, 'Channel 1', 'Bim', 0), 
	(11, 1, 'NEWS NET', 'Dovan', 3), 
	(12, 2, 'Vojik', 'Harrison', 4);