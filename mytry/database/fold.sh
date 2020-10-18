#mkdir /var/lib/postgresql/data/archive && chmod 700 /var/lib/postgresql/data/archive && chown -R postgres:postgres /var/lib/postgresql/data/archive

touch /var/log/postgresql.log
chmod a-r,u+r /var/log/postgresql.log
chown postgres:postgres /var/log/postgresql.log
