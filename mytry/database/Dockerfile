FROM postgres:latest
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=postgres
ENV POSTGRES_PASSWORD=12345678
#RUN echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"'>> /etc/environment
#RUN echo 'http_proxy="http://linux:linux@10.245.3.194:3111/"' >> /etc/environment
#RUN echo 'https_proxy="https://linux:linux@10.245.3.194:3111/"' >> /etc/environment
#RUN echo 'ftp_proxy="ftp://linux:linux@10.245.3.194:3111/"' >> /etc/environment
RUN apt-get update && apt-get upgrade && apt-get install nano -y && apt-get install mc -y && apt-get install net-tools -y && apt-get autoclean
RUN touch /var/log/postgresql.log && chmod a-r,u+r /var/log/postgresql.log && chown postgres:postgres /var/log/postgresql.log
RUN mkdir /var/db/data -p && chmod -R 700 /var/db/data/ && chown postgres:postgres /var/db/data
#RUN su - postgres -c '/usr/lib/postgresql/13/bin/pg_basebackup -P -R -X stream -c fast -h 172.17.0.2 -U postgres -D /var/db/data'
#RUN su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl start -D /var/db/data/ -l /var/db/data/slave.log'
#RUN su - postgres -c '/usr/lib/postgresql/13/bin/pg_basebackup -P -R -X stream -c fast -h 172.17.0.2 -U postgres -D /var/lib/postgresql/data1'
#RUN su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl start -D /var/lib/postgresql/data1/ -l /var/lib/postgresql/data1/slave.log'
#RUN su - postgres -c '/usr/lib/postgresql/13/bin/pg_ctl stop -D /var/lib/postgresql/data'

#ADD ./fold.sh /home
WORKDIR /usr/lib/postgresql/13/bin/
EXPOSE 5432

#Start: docker run -p 5432:5432 -d IMAGES