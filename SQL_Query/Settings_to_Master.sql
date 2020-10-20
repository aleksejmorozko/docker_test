-------------------------Start SETTINGS physic SERVER------------------------
Мастер
1) создание контейнеров postgres
2) в контейнере мастера делаем log-файл и правим конфиги postgres.conf по инструкции
	(touch /var/log/postgresql/postgresql.log && chmod a-r,u+r /var/log/postgresql/postgresql.log && chown postgres:postgres /var/log/postgresql/postgresql.log)
3) в конфиге pg_hba.conf добавляем строки 
	host	replication		postgres		172.17.0.0/24		trust
	host	all			all			172.17.0.0/24		trust
	закомментируем
	host	all			all			md5
4) меняем пароль пользователю postgres (su - postgres) 
5) перезагружаем контейнер
Мастер готов

Слейв
1) меняем пароль пользователю postgres (su - postgres) 
2) создаем поток копирования с мастера
su - postgres -c '/usr/lib/postgresql/13/bin/pg_basebackup -F plain -P -R -X stream -c fast -h 172.17.0.2 -p 5432 -U postgres -D /var/lib/postgresql/data1'
3) в файле postgres.conf добавляем строку (port = 5433) - порт запуска демона. работает параллельно основному. без основного потухнет сервер.
4) запускаем самого демона
su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl start -D /var/lib/postgresql/data1 -l /var/lib/postgresql/data1/slave.log'
5'') при перезагрузке тухнет параллельный демон реплики и его необходимо запустить заново
Слейв готов
--------------------------------COMPLETE SETTINNGS-------------------------------------------------
touch /var/log/postgresql/postgresql.log && chmod a-r,u+r /var/log/postgresql/postgresql.log && chown postgres:postgres /var/log/postgresql/postgresql.log

set transaction isolation level read committed;
alter system set listen_addresses to '*';
alter system set max_connections to 10;
alter system set log_destination to '';
alter system set logging_collector to 'on';
alter system set log_directory to '/var/log/postgresql';
alter system set log_filename to 'postgresql.log';
alter system set log_rotation_size to '100MB';
alter system set client_min_messages to 'notice';
alter system set log_min_messages to 'warning';
alter system set log_min_error_statement to 'error';
alter system set log_checkpoints to 'on';
alter system set log_connections to 'on';
alter system set log_disconnections to 'on'
alter system set log_hostname to 'on';
alter system set log_line_prefix to '%t';
--alter system set wal_level to 'hot_standby';
alter system set wal_level to 'replica';
alter system set wal_log_hints to 'on';
alter system set max_wal_senders to '3';
alter system set full_page_writes to 'on';

--Slave
alter system set hot_standby to 'on';

select pg_reload_conf();

--команды на Slave физический сервер
su - postgres
pg_basebackup -P -R -X stream -c fast -h 192.168.100.3 (хост мастера) -U postgres -D /var/db/postgres/data (путь папки данных Slave)
--OR FOR DOCKER Slave
su - postgres -c '/usr/lib/postgresql/13/bin/pg_basebackup -P -R -X stream -c fast -h 172.17.0.2 -U postgres -D /var/lib/postgresql/data1' 
su - postgres -c '/usr/lib/postgresql/13/bin/pg_basebackup -F plain -P -R -X stream -c fast -h 172.17.0.2 -p 5432 -U postgres -D /var/lib/postgresql/data1'
--~/slave/postgresql.conf строку port = 5433
--Исправление postgres.conf AND postgres.auto.conf строку port = 5433
su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl start -D /var/lib/postgresql/data1 -l /var/lib/postgresql/data1/slave.log'
su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl restart -D /var/lib/postgresql/data1'
--alter system set data_directory to '/var/lib/postgresql/data';

-------------------------------------------------------------------------------

----!!!!!!!!!!!!!!!---------LOGICAL REPLICATION ---------!!!!!!!!!!!!!---------
Т.е. у нас будет два локальных демона pg, которые будут друг другу реплицировать отдельные таблицы. Пусть один будет работать на порту 5433, другой — на 5434.
Для этого надо вписать в ~/master/postgresql.conf строку port = 5433, в ~/slave/postgresql.conf — строку port = 5434, соответственно.

/usr/local/pgsql/bin/initdb -D ~/master
/usr/local/pgsql/bin/initdb -D ~/slave
---------------------------------
В обоих конфигах postgresql.conf надо указать:
wal_level = logical 
---------------------------------
pg_hba.conf:
local   replication     postgres                                trust
---------------------------------
Запускаем оба демона:

su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl start -D /var/db/master/ -l /var/db/master/master.log'
su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl start -D /var/db/slave/ -l /var/db/slave/slave.log'

--------------SETUP REPLICATION---------------
--master:
/usr/local/pgsql/bin/psql -p 5433

CREATE TABLE repl (
   id int, 
   name text, 
   primary key(id)
);
CREATE PUBLICATION testpub;

ALTER PUBLICATION testpub ADD TABLE repl;

--slave:
/usr/local/pgsql/bin/psql -p 5434

REATE TABLE repl (
    id int, 
    name text, 
    primary key(id)
);

CREATE SUBSCRIPTION testsub CONNECTION 'port=5433 dbname=postgres' PUBLICATION testpub;

-----------------COMPLETE SETTINGS------------------