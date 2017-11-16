# 
# Ubuntu LAMP docker (Supervisor, Cron, SSH, Apache, PHP, MariaDB, Redis)
# 

FROM ubuntu:latest
MAINTAINER Marek Vit <marekvit@gmail.com>


# Initial essentila install and update
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update 
RUN apt-get install apt-utils -y
RUN apt-get upgrade -y

# Few handy utilities
RUN apt-get install nano snmp tcl --no-install-recommends -y

# Set root password: root
# ..password been hash generated using this command: openssl passwd -1 -salt marvis root
RUN sed -ri 's/root\:\*/root\:\$1\$marvis\$665TJ5RnVsp8E.w9H6Lfc\//g' /etc/shadow





# Install Supervisor
# --------------------------------------------------------------------------------------------------------
RUN apt-get install supervisor -y





# Install Cron
# --------------------------------------------------------------------------------------------------------
RUN apt-get install cron -y

# Cron start via Supervisor
RUN echo "[program:cron]"                         	  >> /etc/supervisor/conf.d/supervisord-cron.conf
RUN echo "command=/bin/bash -c \"/usr/sbin/cron -f\""     >> /etc/supervisor/conf.d/supervisord-cron.conf
RUN echo "autostart=false"                                >> /etc/supervisor/conf.d/supervisord-cron.conf
RUN echo "autorestart=true"                               >> /etc/supervisor/conf.d/supervisord-cron.conf
RUN echo "user=root"                                      >> /etc/supervisor/conf.d/supervisord-cron.conf
RUN echo "stdout_events_enabled=true"                     >> /etc/supervisor/conf.d/supervisord-cron.conf
RUN echo "stderr_events_enabled=true"                     >> /etc/supervisor/conf.d/supervisord-cron.conf





# Install OpenSSH server
# --------------------------------------------------------------------------------------------------------
RUN apt-get install openssh-server -y
RUN mkdir -p /var/run/sshd

# SSH - Configuration - Allow root login via password
RUN sed -ri 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# SSH start via Supervisor
RUN echo "[program:openssh]"         >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
RUN echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
RUN echo "numprocs=1"                >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
RUN echo "autostart=true"            >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
RUN echo "autorestart=true"          >> /etc/supervisor/conf.d/supervisord-openssh-server.conf





# Install Apache
# --------------------------------------------------------------------------------------------------------
RUN apt-get install apache2 libapache2-mod-php7.0 -y

# Apache - Configuration
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN chown -R www-data:www-data /var/www/
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -ri 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Apache start via Supervisor
RUN echo "[program:apache]"                                                    >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "command=/bin/bash -c \"/usr/sbin/apachectl -DFOREGROUND -k start\""  >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "autostart=true"                                                      >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "autorestart=true"                                                    >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "killasgroup=true"                                                    >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "stopasgroup=true"                                                    >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "user=root"                                                           >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "stdout_events_enabled=true"                                          >> /etc/supervisor/conf.d/supervisord-apache-server.conf
RUN echo "stderr_events_enabled=true"                                          >> /etc/supervisor/conf.d/supervisord-apache-server.conf





# Install PHP
# --------------------------------------------------------------------------------------------------------
RUN apt-get install -y \
	php7.0 \
	php7.0-bz2 \
	php7.0-cgi \
	php7.0-cli \
	php7.0-common \
	php7.0-curl \
	php7.0-dev \
	php7.0-enchant \
	php7.0-fpm \
	php7.0-gd \
	php7.0-gmp \
	php7.0-imap \
	php7.0-interbase \
	php7.0-intl \
	php7.0-json \
	php7.0-ldap \
	php7.0-mbstring \
	php7.0-mcrypt \
	php7.0-mysql \
	php7.0-odbc \
	php7.0-opcache \
	php7.0-pgsql \
	php7.0-phpdbg \
	php7.0-pspell \
	php7.0-readline \
	php7.0-recode \
	php7.0-snmp \
	php7.0-soap \
	php7.0-sqlite3 \
	php7.0-sybase \
	php7.0-tidy \
	php7.0-xmlrpc \
	php7.0-xsl \
	php7.0-zip


# Set PHP timezone
RUN sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php/7.0/apache2/php.ini

# enable php short tags:
RUN sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini





# Install MariaDB
# --------------------------------------------------------------------------------------------------------
RUN apt-get install mariadb-common mariadb-server mariadb-client -y

# MariaDB start via Supervisor
RUN echo "[program:mysql]"                                >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "command=/bin/bash -c \"/usr/bin/mysqld_safe\""  >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "autostart=true"                                 >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "autorestart=true"                               >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "killasgroup=true"                               >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "stopasgroup=true"                               >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "user=root"                                      >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "stdout_events_enabled=true"                     >> /etc/supervisor/conf.d/supervisord-mysql-server.conf
RUN echo "stderr_events_enabled=true"                     >> /etc/supervisor/conf.d/supervisord-mysql-server.conf





# Build Redis
# --------------------------------------------------------------------------------------------------------
RUN apt-get install redis-server -y
RUN apt-get install php-redis -y

# Configure Redis
RUN echo "maxmemory 128mb"		     >> /etc/redis/redis.conf
RUN echo "maxmemory-policy allkeys-lru"	     >> /etc/redis/redis.conf
RUN sed -ri 's/daemonize yes/daemonize no/g' /etc/redis/redis.conf


# Redis start via Supervisor
RUN echo "[program:redis]"                         		  			>> /etc/supervisor/conf.d/supervisord-redis.conf
RUN echo "command=/bin/bash -c \"redis-server /etc/redis/redis.conf\""  		>> /etc/supervisor/conf.d/supervisord-redis.conf
RUN echo "autostart=false"                                 				>> /etc/supervisor/conf.d/supervisord-redis.conf
RUN echo "autorestart=true"                               				>> /etc/supervisor/conf.d/supervisord-redis.conf
RUN echo "user=root"                                      				>> /etc/supervisor/conf.d/supervisord-redis.conf
RUN echo "stdout_events_enabled=true"                     				>> /etc/supervisor/conf.d/supervisord-redis.conf
RUN echo "stderr_events_enabled=true"                     				>> /etc/supervisor/conf.d/supervisord-redis.conf





# Set after startup configuration file
# --------------------------------------------------------------------------------------------------------
RUN echo "#!/bin/bash" >> /after-config.sh
RUN echo "sleep 2s"    >> /after-config.sh
RUN echo "mysql -u root -e \"SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root'); GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;\"" >> /after-config.sh

RUN chmod +x /after-config.sh

# After startup configuration supervisor file
RUN echo "[program:after-config]"                    >> /etc/supervisor/conf.d/supervisord-after-config.conf
RUN echo "command=/bin/bash -c \"/after-config.sh\"" >> /etc/supervisor/conf.d/supervisord-after-config.conf
RUN echo "priority = 999"                            >> /etc/supervisor/conf.d/supervisord-after-config.conf
RUN echo "startsecs = 0"                             >> /etc/supervisor/conf.d/supervisord-after-config.conf
RUN echo "startretries = 1"                          >> /etc/supervisor/conf.d/supervisord-after-config.conf
RUN echo "autorestart = false"                       >> /etc/supervisor/conf.d/supervisord-after-config.conf




# --------------------------------------------------------------------------------------------------------
# Copy TOP config file
COPY ini/.toprc /root/

RUN mkdir /root/useful

# Copy Adminer
COPY ini/adminer.php /root/useful/

# Copy Useful info
COPY ini/tips /root/useful/


# --------------------------------------------------------------------------------------------------------
# Clean before end
RUN apt-get autoclean
RUN apt-get autoremove -y


# --------------------------------------------------------------------------------------------------------
# Expose SSH, Apache, MariaDB
EXPOSE 22
EXPOSE 80
EXPOSE 3306


# --------------------------------------------------------------------------------------------------------
# Start script
RUN echo "#!/bin/bash"		   >> /startup.sh
RUN echo "/usr/bin/supervisord -n" >> /startup.sh

CMD ["sh", "/startup.sh"]
