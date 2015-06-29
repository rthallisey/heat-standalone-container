#!/bin/bash -x

. standalone.env
pscfg=/etc/supervisord.conf

# linking so all files can access kolla-common.sh
ln -s kolla/docker/common/mariadb-app/mysql-entrypoint.sh
ln -s kolla/docker/common/mariadb-app/config-mysql.sh

ln -s kolla/docker/common/keystone/start.sh keystone-start.sh

ln -s kolla/docker/common/rabbitmq/start.sh rabbit-start.sh
cp kolla/docker/common/rabbitmq/rabbitmq-env.conf /etc/rabbitmq
cp kolla/docker/common/rabbitmq/rabbitmq.config /etc/rabbitmq

ln -s kolla/docker/common/heat/heat-base/config-heat.sh
ln -s kolla/docker/common/heat/heat-api/start.sh heat-api-start.sh
ln -s kolla/docker/common/heat/heat-api-cfn/start.sh heat-api-cfn-start.sh
ln -s kolla/docker/common/heat/heat-engine/start.sh heat-engine-start.sh

# allow builtin changes to be inherited (in some cases?)
export SHELLOPTS

# disable builtin, services will be started with supervisord instead
# scripts that use exec must be source executed!
enable -n exec

#[eventlistener:stdout]
#command = supervisor_stdout
#buffer_size = 100
#events = PROCESS_LOG
#result_handler = supervisor_stdout:event_handler

#under program:
#stderr_events_enabled=true
#stdout_events_enabled=true

#[supervisord]
#nodaemon=true
#logfile = /var/log/supervisor/supervisord.log
#logfile_maxbytes = 200KB
#logfile_backups = 1
#pidfile = /var/run/supervisord.pid
#childlogdir = /var/log/supervisor


# configure mysql
./mysql-entrypoint.sh mysqld_safe
crudini --set $pscfg program:mysql command "mysqld_safe --init-file=/tmp/mysql-first-time.sql"

supervisord -c $pscfg

# hack, would be nice to block until process started instead
sleep 5

# configure keystone
cp /usr/bin/keystone-all /usr/bin/keystone-all-real
echo 'kill -1 $(<"/var/run/supervisord.pid")' > /usr/bin/keystone-all
crudini --set $pscfg program:keystone command "keystone-all-real"

./keystone-start.sh

# configure rabbit
(. rabbit-start.sh)
crudini --set $pscfg program:rabbit command "rabbitmq-server"

# reload supervisord (executes rabbit)
kill -1 $(<"/var/run/supervisord.pid")

# configure heat
./config-heat.sh
(. heat-api-start.sh)
(. heat-api-cfn-start.sh)
(. heat-engine-start.sh)
crudini --set $pscfg program:heat-api command "heat-api"
crudini --set $pscfg program:heat-api-cfn command "heat-api-cfn"
crudini --set $pscfg program:heat-engine command "heat-engine"

# configure heat docker plugin
pushd /opt/heat/contrib/heat_docker
pip install docker-py # docker-python package installs more dependencies
python setup.py install

# reload supervisord (executes heat)
kill -1 $(<"/var/run/supervisord.pid")

echo "Heat and dependent services running"
