FROM postgres:latest
ENV POSTGRES_USER=test
ENV POSTGRES_DB=testdb
ENV POSTGRES_PASSWORD=12345678
#RUN apt-get update && apt-get upgrade && apt-get install nano -y && apt-get install mc -y
#RUN /bin/sh -c 'mkdir /var/lib/postgresql/data/archive && chmod 700 /var/lib/postgresql/data/archive && chown -R postgres:postgres /var/lib/postgresql/data/archive'
EXPOSE 5432

#Start: docker run -p 5432:5432 -d IMAGES