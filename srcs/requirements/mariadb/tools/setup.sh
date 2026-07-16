#!/bin/sh

mkdir -p /run.mysqld
chown mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	cat << EOF > /tmp/db.sql
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
	mariadbd --user=mysql --bootstrap < /tmp/db.sql
	rm -f /tmp/db.sql
fi

exec mariadbd --user=mysql
