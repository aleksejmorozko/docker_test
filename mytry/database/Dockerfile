FROM postgres:latest
ENV POSTGRES_USER=test
ENV POSTGRES_DB=testdb
ENV POSTGRES_PASSWORD=12345678
RUN apt-get update && apt-get upgrade && apt-get install nano -y && apt-get install mc -y
EXPOSE 5432

#Start: docker run -p 5432:5432 -d IMAGES