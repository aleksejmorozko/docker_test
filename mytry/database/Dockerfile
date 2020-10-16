FROM postgres:latest
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=postgres
ENV POSTGRES_PASSWORD=12345678
RUN apt-get update && apt-get upgrade && apt-get install nano -y && apt-get install mc -y
ADD ./fold.sh /home
WORKDIR /home
EXPOSE 5432

#Start: docker run -p 5432:5432 -d IMAGES