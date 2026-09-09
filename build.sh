#!/bin/bash
#docker build -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
#docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
CA_CERT=/usr/local/share/ca-certificates/cua_ca_certificate.crt
if [ -f "$CA_CERT" ]; then
	cp "$CA_CERT" .
else
	echo "WARNING: $CA_CERT not found, building without it" >&2
fi

# Capture the tag so the push instructions below can name the same build
TAG=$(date +%Y%m%d%H%M%S)

if docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:"$TAG" .; then
	# docker login --username=$DOCKER_USER --password=$DOCKER_PASS $DOCKER_HOST
	# echo docker login --username=$DOCKER_USER --password=$DOCKER_PASS
	echo
	echo "Built cuaws/wpcua:latest and cuaws/wpcua:$TAG (local only)."
	echo "NOW YOU MUST MANUALLY RUN..."
	echo "docker login -u tmuka \\"
	echo "  && docker push cuaws/wpcua:latest \\"
	echo "  && docker push cuaws/wpcua:$TAG"
	echo
	echo "Push the dated tag too, it is your rollback point if :latest misbehaves."
else
	echo "BUILD FAILED - nothing to push" >&2
	exit 1
fi
