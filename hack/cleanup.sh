#!/bin/bash
docker image prune -f
docker image ls | grep keepalived | grep -v infra | awk '{print $1":"$2}' | xargs docker rmi
