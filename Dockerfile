FROM ubuntu:18.04

LABEL maintainer="djb44@psu.edu"

COPY webaccess_3.3.0_amd64.deb /tmp

RUN apt-get update && \
    apt-get --no-install-recommends install ca-certificates apache2=2.4.29-1ubuntu4.11 libssl1.0.0=1.0.2n-1ubuntu5.3 libssl-dev=1.1.1-1ubuntu2.1~18.04.4 -y \
    && rm -rf /var/lib/apt/lists/* 

RUN dpkg -i /tmp/webaccess_3.3.0_amd64.deb
RUN rm /tmp/webaccess_3.3.0_amd64.deb

COPY apache-foreground /usr/local/bin

RUN sed -i 's/^ErrorLog.*/ErrorLog \/proc\/self\/fd\/1/g' /etc/apache2/apache2.conf
RUN sed -i 's/\tCustomLog.*/\tCustomLog \/proc\/self\/fd\/1 combined/g' /etc/apache2/sites-available/000-default.conf

CMD ["apache-foreground"]
