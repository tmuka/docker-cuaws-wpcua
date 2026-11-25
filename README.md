# docker-cuaws-wpcua
this is the base image we customized for our local wordpress dev workflow found on internal only webint/kb/tony-dockerclisshkey-2017-workflow/

## Updating the image

The Dockerfile uses the floating `wordpress:7-php8.4-apache` tag, so picking up a new
WordPress or PHP patch release only needs a rebuild, not an edit.

1. Clone this repo and edit the Dockerfile if needed.
2. Run `./build.sh`. It builds with `--no-cache` and tags the image `cuaws/wpcua:latest`
   plus a dated tag (e.g. `cuaws/wpcua:20261125094907`).
3. Smoke test it, e.g.
   `docker run --rm --entrypoint sh cuaws/wpcua:latest -c 'php -v; wp --allow-root --version'`
4. Push both tags, using the commands `build.sh` prints at the end. The dated tag is the
   rollback point if `:latest` misbehaves. No `docker login` is needed when Docker Desktop's
   credential store is set up.

*for now Tony and Dave have write permissions on our dockerhub cuaws organization. ask them to add you if you need to write.*


# based on docker-wordpress-wp-cli
This repository contains the Dockerfile for the autobuild of [wordpress-with-wp-cli](https://registry.hub.docker.com/u/timbutler/wordpress-with-wp-cli/) Docker image.

The Dockerfile uses the official WordPress image and adds [wp-cli](http://wp-cli.org/).

To use, simply run: 

    docker run --name <containername> cuaws/wpcua

For all other configuration items, please see the official Docker WordPress [ReadMe](https://github.com/docker-library/docs/tree/master/wordpress).

You can then call the standard wp-cli commands via `docker exec`. For example, to install and activate the Quark theme:

    docker exec <containername> wp theme install quark
    docker exec <containername> wp theme activate quark

Please feel free to fork and use for your own projects.
