FROM ubuntu:saucy
MAINTAINER Kevin Littlejohn <kevin@littlejohn.id.au>

# Strange little bug in /tmp permissions
RUN chmod go+w,u+s /tmp

# Fix the locale
RUN localedef -c -i en_AU -f UTF-8 en_AU.UTF-8

RUN apt-get -yq update && apt-get -yq upgrade

# Requirements for DinD as per https://github.com/jpetazzo/dind
RUN apt-get -yq install iptables ca-certificates lxc
#ADD https://get.docker.io/builds/Linux/x86_64/docker-latest /usr/local/bin/docker
ADD docker-latest /usr/local/bin/docker
#ADD https://raw.githubusercontent.com/jpetazzo/dind/master/wrapdocker /usr/local/bin/wrapdocker
ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker
VOLUME /var/lib/docker
ENV PORT 4243
EXPOSE 4243

ENTRYPOINT ["/usr/local/bin/wrapdocker"]
