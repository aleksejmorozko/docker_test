FROM ubuntu:latest
RUN apt-get update && apt-get upgrade -y && apt-get install nano -y && apt-get install wget -y
RUN apt-get install apt-transport-https && apt-get install software-properties-common -y && apt-get install ca-certificates -y
RUN wget https://download.docker.com/linux/ubuntu/gpg && apt-key add gpg
RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" >> /etc/apt/sources.list && apt-get update -y
RUN apt-get install docker-ce -y
