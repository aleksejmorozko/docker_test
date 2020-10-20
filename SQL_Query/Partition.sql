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
