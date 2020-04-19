# Dockerfile FT_SERVER
# Author : Victor PASCAL <vpascal@student.42.fr>

FROM debian:buster
LABEL maintainer="vpascal@student.42.fr"

# System update and instalation of :
# - nginx
# - php7.3 + fpm + cgi + mbstring
# - mysql server
# - zip
# - openssl
RUN apt-get update -yq && \
	apt-get upgrade -y && \
	apt-get install nginx -y && \
	apt-get install php7.3 -y && \
	apt-get install php7.3-fpm -y && \
	apt-get install php7.3-cgi -y && \
	apt-get install php7.3-mysql -y && \
	apt-get install php7.3-mbstring && \
	apt-get -y install mariadb-server && \
	apt-get install vim -y && \
	apt-get install zip -y && \
	apt-get install openssl -y

# delete apache2 server installed by php-mysql depot
RUN apt-get purge apache2 -y

RUN mkdir /home/ft_server /home/ft_server/wordpress /home/ft_server/phpmyadmin && \
	chown www-data:www-data /home/ft_server/wordpress /home/ft_server/phpmyadmin

COPY srcs/config/php.ini /etc/php/7.3/php.ini
COPY srcs/config/wordpress.conf /etc/nginx/sites-available/wordpress.conf
COPY srcs/config/ssl-domains-config.conf /etc/ssl/ssl-domains-config.conf
COPY srcs/phpmyadmin.zip /home/ft_server/phpmyadmin.zip
COPY srcs/wordpress.zip /home/ft_server/wordpress.zip
COPY srcs/config/setup.sh /var/scripts/setup.sh
COPY srcs/config/setup-db.sql /var/scripts/setup-db.sql
COPY srcs/config/ft_server_db.sql /var/scripts/ft_server_db.sql

RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf

EXPOSE 80 443

RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# Extract PMA & WP
RUN unzip /home/ft_server/wordpress.zip -d /home/ft_server && \
	unzip /home/ft_server/phpmyadmin.zip -d /home/ft_server && \
	rm -f /home/ft_server/wordpress.zip /home/ft_server/phpmyadmin.zip

# DATABASE SETUP
RUN service mysql restart && \
	mysql -u root --password= < /var/scripts/setup-db.sql && \
	mysql ft_server_db -u root --password= < /var/scripts/ft_server_db.sql && \
	mysql phpmyadmin -u root --password= < /home/ft_server/phpmyadmin/sql/create_tables.sql

# SSL CONFIGURATION : CA
RUN mkdir /etc/ssl/csr /etc/ssl/public && \
	openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout /etc/ssl/private/RootCAFTServer.key -out /etc/ssl/certs/RootCAFTServer.pem -subj "/C=FR/CN=localhost" && \
	openssl x509 -outform pem -in /etc/ssl/certs/RootCAFTServer.pem -out /etc/ssl/public/RootCAFTServer.crt

# SSL CONFIGURATION : WORDPRESS
RUN openssl req -new -nodes -newkey rsa:2048 -keyout /etc/ssl/private/localhost.key -out /etc/ssl/csr/localhost.csr -subj "/C=FR/ST=idf/L=Paris/O=42 Shool/CN=localhost" && \
	openssl x509 -req -sha256 -days 365 -in /etc/ssl/csr/localhost.csr -CA /etc/ssl/certs/RootCAFTServer.pem -CAkey /etc/ssl/private/RootCAFTServer.key -CAcreateserial -extfile /etc/ssl/ssl-domains-config.conf -out /etc/ssl/public/localhost.crt


CMD bash /var/scripts/setup.sh
