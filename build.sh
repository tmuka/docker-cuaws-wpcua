#!/bin/bash
#docker build -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
#docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:1.1 .
# Capture the tag so the push instructions below can name the same build
TAG=$(date +%Y%m%d%H%M%S)

if docker build --no-cache -t cuaws/wpcua:latest -t cuaws/wpcua:"$TAG" .; then
	# No docker login needed: Docker Desktop's credsStore (desktop.exe) supplies the
	# Docker Hub credentials, and an interactive login fails without a TTY anyway.
	echo
	echo "Built cuaws/wpcua:latest and cuaws/wpcua:$TAG (local only)."
	echo "NOW YOU MUST MANUALLY RUN..."
	echo "docker push cuaws/wpcua:latest \\"
	echo "  && docker push cuaws/wpcua:$TAG"
	echo
	echo "Push the dated tag too, it is your rollback point if :latest misbehaves."
else
	echo "BUILD FAILED - nothing to push" >&2
	exit 1
fi
