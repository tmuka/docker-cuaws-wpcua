#!/bin/bash
# Build cuaws/wpcua from the latest wordpress base image, smoke test it, and print
# the push commands. Pushing stays a manual step on purpose.
set -uo pipefail

# Build from the repo folder no matter where the script is run from
cd "$(dirname "$0")" || exit 1

IMAGE=cuaws/wpcua
# Capture the tag so the push instructions below can name the same build
TAG=$(date +%Y%m%d%H%M%S)

# Record the git commit in the image so a dated tag can be traced back to its source
REVISION=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
	REVISION="$REVISION-dirty"
	echo "WARNING: uncommitted changes, image will be labeled $REVISION" >&2
fi

# --pull always fetches the newest base image (getting the latest WordPress is the
# point of rebuilding); --no-cache makes every layer, including apt, run fresh.
if ! docker build --pull --no-cache \
	--label org.opencontainers.image.revision="$REVISION" \
	--label org.opencontainers.image.created="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
	-t "$IMAGE:latest" -t "$IMAGE:$TAG" .; then
	echo "BUILD FAILED - nothing to push" >&2
	exit 1
fi

# Smoke test before suggesting a push: everything this image adds must work, and PHP
# must start without warnings (e.g. an extension that fails to load).
echo
echo "Smoke testing $IMAGE:$TAG..."
if ! REPORT=$(docker run --rm --entrypoint sh "$IMAGE:$TAG" -c '
	set -e
	fail() { echo "FAIL: $*"; exit 1; }
	php_out=$(php -m 2>&1)
	if echo "$php_out" | grep -qiE "warning|error"; then fail "PHP startup: $php_out"; fi
	echo "$php_out" | grep -qx ldap || fail "ldap extension not loaded"
	mem=$(php -r "echo ini_get(\"memory_limit\");")
	[ "$mem" = "$PHP_MEMORY_LIMIT" ] || fail "memory_limit is $mem, expected $PHP_MEMORY_LIMIT"
	wpcli=$(wp --allow-root --version 2>&1) || fail "wp-cli: $wpcli"
	wpver=$(sed -n "s/^\$wp_version = .\(.*\).;/\1/p" /usr/src/wordpress/wp-includes/version.php)
	[ -n "$wpver" ] || fail "could not read WordPress version"
	echo "WordPress $wpver"
	php -v | head -1
	echo "memory_limit $mem"
	echo "$wpcli"
' 2>&1); then
	echo "$REPORT" >&2
	echo "SMOKE TEST FAILED - do not push. $IMAGE:latest locally now points at this broken build;" >&2
	echo "the previous dated tag is still available if you need to retag it." >&2
	exit 1
fi
echo "$REPORT" | sed 's/^/  /'
echo "  git revision $REVISION"

echo
echo "Built and tested $IMAGE:latest and $IMAGE:$TAG (local only)."
# No docker login needed: Docker Desktop's credsStore (desktop.exe) supplies the
# Docker Hub credentials, and an interactive login fails without a TTY anyway.
echo "NOW YOU MUST MANUALLY RUN..."
echo "docker push $IMAGE:latest \\"
echo "  && docker push $IMAGE:$TAG"
echo
echo "Push the dated tag too, it is your rollback point if :latest misbehaves."
