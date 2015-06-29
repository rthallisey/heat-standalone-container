FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%base:%%KOLLA_TAG%%
MAINTAINER Kolla Project (https://launchpad.net/kolla)
# docker run -it -v /var/run/docker.sock:/var/run/docker.sock kollaglue/centos-rdo-heat-standalone /bin/bash
# might need privileged flag?

RUN yum -y install openstack-heat-api-cfn \
  python-openstackclient \
  openstack-heat-api \
  openstack-heat-engine \
  python-barbicanclient \
  python-zaqarclient \
  openstack-keystone \
  python-keystoneclient \
  mariadb \
  mariadb-server \
  MySQL-python \
  hostname \ 
  rabbitmq-server \
  supervisor \
  git \
  && yum clean all

RUN git clone https://github.com/stackforge/kolla.git /opt/kolla/kolla
RUN git clone https://github.com/openstack/heat /opt/heat

COPY config.sh /opt/kolla/config.sh
COPY standalone.env /opt/kolla/standalone.env
