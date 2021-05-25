# 
# Installs WordPress with wp-cli (wp.cli.org) installed and support for mysql, ssh, less, wp-cli, vim-tiny, rsync
# Docker Hub: https://registry.hub.docker.com/u/tmuka/wpcua/
# Github Repo: https://github.com/conetix/docker-wordpress-wp-cli
# https://github.com/tmuka/docker-cuaws-wpcua.git

#FROM wordpress:latest
#switching to php7.2-apache tag since :latest stopped working for auto build triggers
#FROM wordpress:php7.3-apache
FROM wordpress:php7.4-apache
MAINTAINER Tony Muka <tmuka@cuanswers.com>

# Add sudo in order to run wp-cli as the www-data user 
RUN apt-get update && apt-get install -y --no-install-recommends \
sudo \
less \
mariadb-client \
openssh-client \
vim-tiny \
rsync \
libldap2-dev \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
&& docker-php-ext-install ldap 

# setup https with self-signed cert for apache
RUN sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048  -subj "/C=US/ST=MI/L=Grand Rapids/O=.../OU=.../CN=.../emailAddress=..."  -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
&& a2enmod ssl \
&& a2ensite default-ssl.conf \
&& apache2ctl graceful

# Add WP-CLI 
RUN curl -k -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

# Cleanup
#RUN apt-get clean
#RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
