FROM armhf/ubuntu:16.04
MAINTAINER "nicolas@corrarello.com"

ENV PUPPET_SERVER_VERSION="2.7.2" UBUNTU_CODENAME="xenial" PUPPETSERVER_JAVA_ARGS="-Xms256m -Xmx256m" PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update && \
    apt-get install -y wget=1.17.1-1ubuntu1 && \
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-"$UBUNTU_CODENAME".deb && \
    dpkg -i puppetlabs-release-pc1-"$UBUNTU_CODENAME".deb && \
    rm puppetlabs-release-pc1-"$UBUNTU_CODENAME".deb dumb-init_"$DUMB_INIT_VERSION"_amd64.deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y puppetserver="$PUPPET_SERVER_VERSION"-1puppetlabs1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    gem install --no-rdoc --no-ri r10k

COPY puppetserver /etc/default/puppetserver
COPY logback.xml /etc/puppetlabs/puppetserver/
COPY request-logging.xml /etc/puppetlabs/puppetserver/

RUN puppet config set certname puppet.service.lhr.consul --section main
RUN puppet config set autosign true --section master

RUN mkdir /etc/puppetlabs/code/
RUN mkdir /etc/puppetlabs/r10k/
RUN mkdir /etc/puppetlabs/puppet/ssl/
RUN mkdir /opt/puppetlabs/server/data/puppetserver/

COPY r10k.yaml /etc/puppetlabs/r10k
COPY docker-entrypoint.sh /

EXPOSE 8140

ENTRYPOINT ["/docker-entrypoint.sh"]

COPY Dockerfile /
