FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%base:%%KOLLA_TAG%%
MAINTAINER Kolla Project (https://launchpad.net/kolla)

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
  docker \
  supervisor \
  git \
  && yum clean all

RUN git clone https://github.com/stackforge/kolla.git /opt/kolla/kolla
RUN git clone https://github.com/openstack/heat /opt/heat

COPY ./start.sh ./stack-create.sh ./deploy-undercloud.yaml /

#CMD ["/start.sh"]
