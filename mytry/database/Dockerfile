FROM postgres:latest
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=postgres
ENV POSTGRES_PASSWORD=12345678
RUN apt-get update && apt-get upgrade && apt-get install nano -y && apt-get install mc -y && apt-get install net-tools -y && apt-get autoclean
RUN mkdir /var/log/postgresql -p && touch /var/log/postgresql/postgresql.log && chmod a-r,u+r /var/log/postgresql/postgresql.log && chown postgres:postgres /var/log/postgresql/postgresql.log
ADD ./pg_hba.conf /var/lib/postgresql/
RUN cat /var/lib/postgresql/pg_hba.conf > /var/lib/postgresql/data/pg_hba.conf
WORKDIR /var/lib/postgresql/
EXPOSE 5432
