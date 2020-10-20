--------------------Partitions - Vertical sharding-----------------------
create table news(
	id bigint not null,
	category_id int not null,
	author character varying not null,
	rate int not null,
	title character varying
);
-- партицирование по ID
create table news_1(
	check (category_id = 1)
) inherits (news);

create table news_2(
	check (category_id = 2)
) inherits (news);
-- условия проверки могут быть с различными диапазонами
-- check(author = 'name') || check (author in ('name 1', 'name 2', 'name 3')) || check (rate > 100 and rate <= 200)
-- еще пример разделения. партицирование по рейтингу. Between обычно не используют т.к. 
-- неизвестнырезультаты занесения граничных значений (100, 200, 300)
create table news_rate_100_200(
	check (rate > 100 and rate <=200)
) inherits (news);

create table news_rate_200_300(
	check (rate > 200 and rate <= 300)
) inherits (news);
-- надо использовать партицирование с одним условием. т.к.если будут использованы два условия, 
-- то неизвестно куда будут уходить данные

create rule news_insert_to_1 as on insert to news
where(category_id = 1)
do instead insert into news_1 values (new.*);

create rule news_insert_to_2 as on insert to news
where(category_id = 2)
do instead insert into news_2 values (new.*);
--Примеры внесения строк
insert into news (id, category_id, title, author, rate) VALUES (5, 1, 'fake NEWS', 'BOB', 4);
insert into news (id, category_id, title, author, rate) VALUES (3, 2, 'Yellow NEWS', 'BOB', 3);
insert into news (id, category_id, title, author, rate) VALUES (4, 2, 'fake Channel', 'Jim', 0);

Select * from news;
select * from only news;
select * from news where category_id = 2;

--индексы надо создавать на партицию отдельно
create index news_rate_idx on news(rate);
create index news_1_rate_idx on news_1(rate);
create index news_2_rate_idx on news_2(rate);

--2gis_partition_magic - утилита для автоматического партицирования.
--https://github.com/2gis/partition_magic.git

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
--------------------------------------
---Настройка на основном сервере (который распределяет по шардам)
drop table news, news_1, news_2;
create extension postgres_fdw;

--Mapping for Shard_1
create server news_1_server
foreign data wrapper postgres_fdw
options (host '172.17.0.4', port '5432', dbname 'postgres');

create user mapping for postgres
server news_1_server
options (user 'postgres', password '12345678');

--Mapping for Shard_2
create server news_2_server
foreign data wrapper postgres_fdw
options (host '172.17.0.5', port '5432', dbname 'postgres');

create user mapping for postgres
server news_2_server
options (user 'postgres', password '12345678');
--//--
drop server news_2_server cascade;
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

---Представление 
create view news as 
	select * from news_1
		union
	select * from news_2;
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

------------------------------
delete from news_2;
select * from news;
select * from news_1;
select * from news_2;
insert into news (id, category_id, title, author, rate) VALUES 
	(7, 2, 'fake Channel', 'Jim', 0), 
	(3, 2, 'Yellow NEWS', 'BOB', 3), 
	(5, 1, 'fake NEWS', 'BOB', 4),
	(6, 3, 'Channel 1', 'Bim', 0), 
	(3, 1, 'NEWS NET', 'Dovan', 3), 
	(5, 2, 'Vojik', 'Harrison', 4);