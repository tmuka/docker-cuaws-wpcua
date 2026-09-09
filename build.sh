#!/bin/bash
#docker build -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
#docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
CA_CERT=/usr/local/share/ca-certificates/cua_ca_certificate.crt
if [ -f "$CA_CERT" ]; then
	cp "$CA_CERT" .
else
	echo "WARNING: $CA_CERT not found, building without it" >&2
fi
docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:$(date +%Y%m%d%H%M%S) .
# docker login --username=$DOCKER_USER --password=$DOCKER_PASS $DOCKER_HOST
# echo docker login --username=$DOCKER_USER --password=$DOCKER_PASS 
echo "NOW YOU MUST MANUALLY RUN..."
echo "docker login -u tmuka && docker push cuaws/wpcua"

