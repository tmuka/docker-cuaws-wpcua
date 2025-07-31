#!/bin/bash
#docker build -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
#docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
cp /usr/local/share/ca-certificates/cua_ca_certificate.crt .
docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:$(date +%Y%m%d%H%M%S) .
# docker login --username=$DOCKER_USER --password=$DOCKER_PASS $DOCKER_HOST
# echo docker login --username=$DOCKER_USER --password=$DOCKER_PASS 
echo "NOW YOU MUST MANUALLY RUN..."
echo "docker login -u tmuka && docker push cuaws/wpcua"

