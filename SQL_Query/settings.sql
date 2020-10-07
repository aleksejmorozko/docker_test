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