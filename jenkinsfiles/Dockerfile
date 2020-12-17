FROM aleksejmorozko/jenkins_docker:second
USER root
RUN usermod -a -G docker jenkins && gpasswd -a jenkins docker
USER jenkins