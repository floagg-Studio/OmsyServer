#!/bin/bash
set -e

if ! command -v brew &> /dev/null; then
	echo "Veuillez exécuter ce script en tant qu'admin."
	exit 1
fi

PATH_ROOT=$(pwd)
SOURCE="$PATH_ROOT/source"

# mkdir -p "$SOURCE"
# wget -q --show-progress -O /tmp/main.zip "https://github.com/floagg-Studio/OmsyServerStore/archive/refs/heads/main.zip"
# TMP_DIR="$(mktemp -d)"
# unzip -q /tmp/main.zip -d "$TMP_DIR"
# find "$TMP_DIR" -type f -name "*.sh" -exec cp {} "$SOURCE/" \;
# rm -rf "$TMP_DIR" /tmp/main.zip
# if [[ "$(uname -s)" == "Darwin" ]]; then
#	SED_INPLACE=(-i '')
# else
#	SED_INPLACE=(-i)
# fi

find ./source -type f -name "*.sh" ! -name "omsy-stable.sh" -exec sed "${SED_INPLACE[@]}" \
	-e "s|PATH_ROOT=/omsy|PATH_ROOT=$PATH_ROOT|g" \
	-e "s|PATH_ROOT=\"/omsy\"|PATH_ROOT=\"$PATH_ROOT\"|g" \
	-e "s|PATH_ROOT='/omsy'|PATH_ROOT='$PATH_ROOT'|g" {} +

echo "Démarrage de l'installation"
sh "$SOURCE/omsy-0.1.sh"

echo "Installation du serveur de base"
sh "$SOURCE/openssl-3.5.sh"

echo "Installation des bases de données"
sh "$SOURCE/mysql-8.4.sh"
sh "$SOURCE/redis-7.2.sh"

echo "Installation des serveurs web"
sh "$SOURCE/nginx-1.28.sh"
sh "$SOURCE/apache-2.4.sh"

echo "Création de fichier pour omsyctl"

cat >> "$PATH_ROOT/share/config/omsyctl/omsy.conf" <<EOF
path="$PATH_ROOT"
confdir="$PATH_ROOT/share/config/omsystackctl/"
EOF

cat >> "$PATH_ROOT/share/config/omsyctl/openssl.conf" <<EOF
label="OpenSSL"
shell="$PATH_ROOT/src/services/openssl.sh"
bins="openssl"
EOF

cat >> "$PATH_ROOT/share/config/omsyctl/mysql.conf" <<EOF
label="MySQL / MariaDB"
shell="$PATH_ROOT/source/mysql.sh"
bins="mysqld","mariadbd","mysql"
start="$PATH_ROOT/sys/bin/mysqld --defaults-file=$PATH_ROOT/share/config/mysql/my.cnf --user=$USER"
stop="pkill -TERM mysqld_safe", "$PATH_ROOT/sys/bin/mysqladmin --socket=$PATH_ROOT/share/run/mysql.sock -u root shutdown"
EOF

cat >> "$PATH_ROOT/share/config/omsyctl/redis.conf" <<EOF
label="Redis"
shell="$PATH_ROOT/src/services/redis.sh"
bins="redis-server","redis"
start="$PATH_ROOT/sys/bin/redis-server $PATH_ROOT/share/config/redis/redis.conf --daemonize no"
stop="$PATH_ROOT/sys/bin/redis-cli shutdown"
EOF

cat >> "$PATH_ROOT/share/config/omsyctl/nginx.conf" <<EOF
label="Nginx"
shell="$PATH_ROOT/src/services/nginx.sh"
bins="nginx"
start="$PATH_ROOT/sys/bin/nginx -c $PATH_ROOT/share/config/nginx/nginx.conf"
stop="kill -QUIT \$(cat $PATH_ROOT/share/run/nginx.pid)"
EOF

cat >> "$PATH_ROOT/share/config/omsyctl/apache.conf" <<EOF
label="Apache"
shell="$PATH_ROOT/src/services/apache.sh"
bins="apache2","httpd"
start="$PATH_ROOT/sys/bin/apachectl -f $PATH_ROOT/share/config/apache/httpd.conf -k start"
stop="$PATH_ROOT/sys/bin/apachectl -f $PATH_ROOT/share/config/apache/httpd.conf -k stop"
EOF

cat >> "$PATH_ROOT/share/config/omsyctl/phpfpm85.conf" <<EOF
label="PHP-FPM85"
shell="$PATH_ROOT/src/services/php85.sh"
bins="php-fpm","php-fpm85","php8.5-fpm"
start="$PATH_ROOT/sys/bin/php-fpm85 --fpm-config $PATH_ROOT/share/config/php/php-fpm85.conf"
stop="kill \$(cat $PATH_ROOT/share/run/php-fpm85.pid)"
EOF

echo "Installation des extensions de code"
sh "$SOURCE/php-8.5.sh"

echo "Finalisation de l'installation"
sh "$SOURCE/omsyctl-0.1.sh"

echo "Finalisation de l'installation"
# sh "$SOURCE/clean.sh"