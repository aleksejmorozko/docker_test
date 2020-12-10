FROM jenkins/jenkins:latest
USER root
RUN apt-get install && apt-get install apt-transport-https && apt-get install \
    && apt-get install ca-certificates && apt-get install curl \
    && apt-get install gnupg-agent && apt-get install software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod a+x /usr/local/bin/jenkins.sh
ENTRYPOINT ["/usr/local/bin/jenkins.sh"]