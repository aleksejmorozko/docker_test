touch /var/log/postgresql.log
chmod a-r,u+r /var/log/postgresql.log
chown postgres:postgres /var/log/postgresql.log

alter system set listen_addresses to '*';
alter system set max_connections to 10;
alter system set log_destination to '';
alter system set logging_collector to 'on';
alter system set log_directory to '/var/log';
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
alter system set wal_level to 'replica';
alter system set wal_log_hints to 'on';
alter system set max_wal_senders to '3';
--alter system set wal_keep_segments to '64';
alter system set hot_standby to 'on';

select pg_reload_conf();

--команды на Slave
su - postgres
pg_basebackup -P -R -X stream -c fast -h 192.168.100.3 (хост мастера) -U postgres -D /var/db/postgres/data (путь папки данных Slave)
--or 
pg_basebackup -P -R -X stream -c fast -h 172.17.0.2 -U postgres -D /var/lib/postgresql/data1 (путь папки данных Slave)

alter system set data_directory to '/var/lib/postgresql/data1';
su - postgres -c '/var/lib/postgresql/data/pg_ctl stop -D /var/lib/postgresql/data1'