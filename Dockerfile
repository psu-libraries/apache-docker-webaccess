FROM ubuntu:18.04

LABEL maintainer="djb44@psu.edu"

COPY webaccess_3.3.0_amd64.deb /tmp

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get --no-install-recommends install \
    ca-certificates \
    apache2 \ 
    libapache2-mod-auth-openidc \
    libssl1.0.0 \ 
    libssl-dev \
    -y \
    && rm -rf /var/lib/apt/lists/* 

ADD files/addtrust-usertrust.pem /etc/ssl/certs/
ADD config/oidc.conf /etc/apache2/conf-available/oidc.conf

RUN dpkg -i /tmp/webaccess_3.3.0_amd64.deb
RUN rm /tmp/webaccess_3.3.0_amd64.deb

COPY apache-foreground /usr/local/bin

RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

RUN sed -i 's/\:80/:8080/1' /etc/apache2/sites-enabled/000-default.conf
RUN sed -i 's/\:443/:8443/1' /etc/apache2/sites-enabled/000-default.conf
RUN sed -i 's/443/8443/g' /etc/apache2/ports.conf
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf
RUN sed -i '/ServerAdmin.*/a\        \UseCanonicalName Off' /etc/apache2/sites-enabled/000-default.conf
RUN sed -i '/ServerAdmin.*/a\        \UseCanonicalPhysicalPort Off' /etc/apache2/sites-enabled/000-default.conf
RUN sed -i 's/^ErrorLog.*/ErrorLog \/proc\/self\/fd\/1/g' /etc/apache2/apache2.conf
RUN sed -i 's/\tCustomLog.*/\tCustomLog \/proc\/self\/fd\/1 combined/g' /etc/apache2/sites-available/000-default.conf

RUN mkdir -p /var/run/apache2
RUN chown -R www-data /var/run/apache2

RUN chown -R www-data /var/log/apache2

RUN chown -R www-data /etc/apache2/conf-available
RUN chown -R www-data /etc/apache2/conf-enabled
RUN chown -R www-data /etc/apache2/mods-available
RUN chown -R www-data /etc/apache2/mods-enabled
RUN chown -R www-data /var/lib/apache2
RUN chown -R www-data /etc/apache2/envvars

USER www-data

CMD ["apache-foreground"]
