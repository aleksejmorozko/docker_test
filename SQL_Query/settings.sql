select sourceline, name, setting, applied
from pg_file_settings
where sourcefile LIKE '%postgresql.conf';

select name, setting, unit, boot_val,reset_val, source, sourcefile, sourceline, pending_restart, context
from pg_settings
where name = 'work_mem'; --\gx --

select pg_reload_conf();

alter system set work_mem to '16MB';
set work_mem to '24MB';

select * from regexp_split_to_table(pg_read_file('postgresql.auto.conf'), '\n')
show work_mem;
alter system reset work_mem;
select current_setting('work_mem');

select set_config('work_mem', '32MB', false);           --(true/false показывает на постояннку поменять или на сеанс)

select * from pg_settings;                              --настройки работы БД

select * from pg_ls_waldir() order by name;

create extension pgcrypto; 
select digest('Hello world', 'md5');                    --создание исключения "extension" для шифрования строк. шифруется функцией "digest"
select pg_size_pretty(pg_database_size('testdb'));      --размер БД. Функция "pg_database_size"
select pg_size_pretty(pg_tablespace_size('ts'));        --размер табличного пространства ts;
select pg_size_pretty(pg_table_size('t'));              --размер таблицы без индексов
select pg_size_pretty(pg_indexes_size('t'));            --размер индексов
select pg_size_pretty(pg_total_relation_size('t'));     --размер таблицы и индекса

create tablespace ts location '/home/postgres/ts_dir';  --создание табличного пространства в определенном каталоге.
create database appdb tablespace ts;                    --создание БД с указанием табличного пространства.
alter table all in tablespace pg_default set tablespace ts;     --перевод всех таблиц в пространство ts 
drop tablespace ts;                                     --удаление при условии отсутствия в пространстве объектов
--процесс удаления: 
select oid from pg_tablespace where spcname = 'ts' \gset;               --узнаем OID
select oid as tsoid from pg_tablespace where spcname = 'ts' \gset;      --или так OID
select datname from pg_database where oid in (select pg_tablespace_databases(:tsoid));          --узнаем какие таблицы там расположены
select relnamespace::regnamespace, relname, relkind from pg_class where reltablespace = :tsoid; --все объекты в табличном пространстве
--если таблично пространства было введено как пространство БД по-умолчанию
--то идентификатор OID будет равен 0
select count (*) from pg_class where reltablespace = 0;
alter database appdb set tablespace pg_default;         --изменение табличного пространства по-умолчанию
--------Базовое "имя" файла относительно PGDATA
create database data_lowlevel;
\c data_lowlevel;
create table t(id serial primary key, n numeric);
insert into t(n) select g.id from generate_series(1,10000) as g(id);
select pg_relation_filepath('t');                       --отношенияфайлов по-умолчанию и завершающий файл
ls -l /usr/local/pgsql/data/base/24783/24786            --просмотр карты файлов
vacuum t; -- очистка
\d t                                                    --объекты таблицы
select pg_relation_filepath('t_pkey');                  --определение расположение файла ро индексу таблицы
oid2name -d "data_lowlevel";                            --просмотр всех объектов базы
select pg_relation_size('t', 'main') main, pg_relation_size('t', 'fsm') fsm, pg_relation_size('t', 'vm') vm; --???