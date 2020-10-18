FROM postgres:latest
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=postgres
ENV POSTGRES_PASSWORD=12345678
RUN apt-get update && apt-get upgrade && apt-get install nano -y && apt-get install mc -y && apt-get install net-tools -y
RUN touch /var/log/postgresql.log && chmod a-r,u+r /var/log/postgresql.log && chown postgres:postgres /var/log/postgresql.log
#RUN su - postgres -c 'pg_basebackup -P -R -X stream -c fast -h 172.17.0.2 -U postgres -D /var/lib/postgresql/data'
#RUN su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl stop -D /var/lib/postgresql/data'
#su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl restart -D /var/db/slave/ -l /var/db/slave/slave.log'
#ADD ./fold.sh /home
WORKDIR /usr/lib/postgresql/13/bin/
EXPOSE 5432

#Start: docker run -p 5432:5432 -d IMAGES