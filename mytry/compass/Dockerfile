FROM ubuntu:20.10
RUN apt-get update -y && apt-get upgrade -y && apt-get install wget -y 
RUN wget https://downloads.mongodb.com/compass/mongodb-compass_1.22.1_amd64.deb
RUN dpkg -i compass.deb
WORKDIR /home/lex