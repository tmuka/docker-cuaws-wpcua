#!/bin/bash
docker build -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
# docker login --username=$DOCKER_USER --password=$DOCKER_PASS $DOCKER_HOST
# echo docker login --username=$DOCKER_USER --password=$DOCKER_PASS 
echo "NOW YOU MUST MANUALLY RUN..."
echo "docker login && docker push cuaws/wpcua"

