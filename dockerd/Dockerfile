FROM silarsis/base
MAINTAINER Kevin Littlejohn <kevin@littlejohn.id.au>
RUN apt-get -yq update && apt-get -yq upgrade

# DinD
RUN apt-get -yq install iptables ca-certificates lxc
ADD docker /usr/local/bin/docker
ADD wrapdocker /usr/local/bin/wrapdocker
VOLUME /var/lib/docker
ENV PORT 4243

ENTRYPOINT ["/usr/local/bin/wrapdocker"]
