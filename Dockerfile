# 
# Installs WordPress with wp-cli (wp.cli.org) installed and support for mysql, ssh, less, wp-cli, vim-tiny, rsync
# Docker Hub: https://registry.hub.docker.com/u/tmuka/wpcua/
# Github Repo: https://github.com/conetix/docker-wordpress-wp-cli
# https://github.com/tmuka/docker-cuaws-wpcua.git

#FROM wordpress:latest
#switching to php7.2-apache tag since :latest stopped working for auto build triggers
#FROM wordpress:php7.3-apache
#FROM wordpress:5.8.2-php7.4-apache
FROM wordpress:6-php8.2-apache
LABEL org.opencontainers.image.authors="tmuka@cuanswers.com"

ENV PHP_MEMORY_LIMIT=512M

# Install the ca-certificate package
RUN apt-get update && apt-get install -y ca-certificates
# Copy the CA certificate from the context to the build container
COPY cua_ca_certificate.crt /usr/local/share/ca-certificates/
# Update the CA certificates in the container
RUN update-ca-certificates

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
RUN curl -k -o /bin/wp-cli.phar --resolve raw.githubusercontent.com:443:185.199.109.133 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

# Cleanup
#RUN apt-get clean
#RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
