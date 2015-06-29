#!/bin/bash

docker run -it -v /var/run/docker.sock:/var/run/docker.sock --env-file=openstack.env kollaglue/centos-rdo-heat-standalone /bin/bash
#docker-compose -f compose/heat-standalone.yml up -d
