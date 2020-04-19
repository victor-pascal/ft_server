CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';
CREATE USER 'ft_server_pma'@'localhost' IDENTIFIED BY '42@pma-control';

CREATE DATABASE ft_server_db;
CREATE DATABASE phpmyadmin;

GRANT ALL PRIVILEGES ON ft_server_db.* TO 'admin'@'localhost';
GRANT ALL PRIVILEGES ON ft_server_db.* TO 'wordpress'@'localhost';
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'ft_server_pma'@'localhost';

FLUSH PRIVILEGES;
