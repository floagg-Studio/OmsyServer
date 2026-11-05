#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

download_source \
	"phpmyadmin" \
	"https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.tar.gz"

dirs=(
	"$PATH_ROOT/usr/phpmyadmin"
)
mkdir -p "${dirs[@]}"

PMA_DIR="${PATH_ROOT}/usr/phpmyadmin"
MYSQL_CRED="${PATH_ROOT}/share/config/mysql/.mysql_root_pass"

[ ! -f "$MYSQL_CRED" ] && echo "Fichier de credentials MySQL introuvable : ${MYSQL_CRED}. Exécutez install_mysql.sh d'abord."
MYSQL_ROOT_PASS=$(cat "$MYSQL_CRED")

cp -r "${SOURCE_DIR}/phpmyadmin/." "${PMA_DIR}/"
BLOWFISH_SECRET=$("$BINARY_DIR/openssl" rand -base64 32 | tr -d '+/=' | head -c 32)

sudo bash -c "cat > '${PMA_DIR}/config.inc.php'" <<EOF
<?php
declare(strict_types=1);
\$cfg['blowfish_secret'] = '${BLOWFISH_SECRET}';
\$cfg['TempDir'] = '/tmp/phpmyadmin';
\$i = 1;
\$cfg['Servers'][\$i]['auth_type']	   = 'cookie';
\$cfg['Servers'][\$i]['host']			= '127.0.0.1';
\$cfg['Servers'][\$i]['port']			= '3306';
\$cfg['Servers'][\$i]['socket']		  = '${PATH_ROOT}/share/run/mysql.sock';
\$cfg['Servers'][\$i]['connect_type']	= 'socket';
\$cfg['Servers'][\$i]['compress']		= false;
\$cfg['Servers'][\$i]['AllowNoPassword'] = false;
\$cfg['Servers'][\$i]['ssl']			 = false;
\$cfg['Servers'][\$i]['pmadb']		   = 'phpmyadmin';
\$cfg['Servers'][\$i]['controluser']	 = 'pmauser';
\$cfg['Servers'][\$i]['controlpass']	 = '${BLOWFISH_SECRET}pma';
\$cfg['Servers'][\$i]['bookmarktable']   = 'pma__bookmark';
\$cfg['Servers'][\$i]['relation']		= 'pma__relation';
\$cfg['Servers'][\$i]['table_info']	  = 'pma__table_info';
\$cfg['Servers'][\$i]['table_coords']	= 'pma__table_coords';
\$cfg['Servers'][\$i]['pdf_pages']	   = 'pma__pdf_pages';
\$cfg['Servers'][\$i]['column_info']	 = 'pma__column_info';
\$cfg['Servers'][\$i]['history']		 = 'pma__history';
\$cfg['Servers'][\$i]['table_uiprefs']   = 'pma__table_uiprefs';
\$cfg['Servers'][\$i]['tracking']		= 'pma__tracking';
\$cfg['Servers'][\$i]['userconfig']	  = 'pma__userconfig';
\$cfg['Servers'][\$i]['recent']		  = 'pma__recent';
\$cfg['Servers'][\$i]['favorite']		= 'pma__favorite';
\$cfg['Servers'][\$i]['users']		   = 'pma__users';
\$cfg['Servers'][\$i]['usergroups']	  = 'pma__usergroups';
\$cfg['Servers'][\$i]['navigationhiding'] = 'pma__navigationhiding';
\$cfg['Servers'][\$i]['savedsearches']   = 'pma__savedsearches';
\$cfg['Servers'][\$i]['central_columns'] = 'pma__central_columns';
\$cfg['Servers'][\$i]['designer_settings'] = 'pma__designer_settings';
\$cfg['Servers'][\$i]['export_templates'] = 'pma__export_templates';
\$cfg['DefaultLang']	  = 'fr';
\$cfg['ThemeDefault']	 = 'pmahomme';
\$cfg['DefaultCharset']   = 'utf-8';
\$cfg['UploadDir']		= '';
\$cfg['SaveDir']		  = '';
\$cfg['ShowPhpInfo']	  = false;
\$cfg['ShowServerInfo']   = false;
\$cfg['ShowChgPassword']  = true;
\$cfg['LoginCookieValidity'] = 1440;
\$cfg['MaxRows']		  = 50;
\$cfg['SendErrorReports'] = 'never';
\$cfg['ForceSSL']		 = false;
\$cfg['AllowArbitraryServer'] = false;
EOF

PMA_CONTROL_PASS="${BLOWFISH_SECRET}pma"

$PATH_ROOT/sys/bin/mysqld_safe --defaults-file="$PATH_ROOT/share/config/mysql/my.cnf" --user=omsy &>/dev/null &
sleep 3

$PATH_ROOT/sys/bin/mysql \
	--socket=$PATH_ROOT/share/run/mysql.sock \
	--user=root \
	--password="${MYSQL_ROOT_PASS}" <<SQL
CREATE USER IF NOT EXISTS 'pmauser'@'localhost'
  IDENTIFIED BY '${PMA_CONTROL_PASS}';
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pmauser'@'localhost';
FLUSH PRIVILEGES;
SQL

if [ -f "${PMA_DIR}/sql/create_tables.sql" ]; then
	$PATH_ROOT/sys/bin/mysql \
		--socket=$PATH_ROOT/share/run/mysql.sock \
		--user=root \
		--password="${MYSQL_ROOT_PASS}" \
		phpmyadmin < "${PMA_DIR}/sql/create_tables.sql"
fi

$PATH_ROOT/sys/bin/mysqladmin \
	--socket=$PATH_ROOT/share/run/mysql.sock \
	--user=root \
	--password="${MYSQL_ROOT_PASS}" \
	shutdown || true

mkdir -p /tmp/phpmyadmin
chmod 777 /tmp/phpmyadmin

sudo chown -R omsy:omsy "${PMA_DIR}"
sudo chmod -R 755 "${PMA_DIR}"
sudo chmod 640 "${PMA_DIR}/config.inc.php"

$PATH_ROOT/sys/bin/openssl req -x509 -nodes -days 3650 \
	-newkey rsa:4096 \
	-keyout $PATH_ROOT/share/ssl/private/phpmyadmin.key \
	-out $PATH_ROOT/share/ssl/certs/phpmyadmin.crt \
	-subj "/C=CA/ST=Quebec/L=Montreal/O=OMSY/CN=phpmyadmin"

CONFDIR="$PATH_ROOT/share/config/nginx"
cat > "${CONFDIR}/sites/phpmyadmin.conf" <<EOF
# PHPMyAdmin — accessible sur :8888 (HTTPS)
server {
    listen 8888 ssl;
    http2  on;
    server_name _;

    ssl_certificate     $PATH_ROOT/share/ssl/certs/phpmyadmin.crt;
    ssl_certificate_key $PATH_ROOT/share/ssl/private/phpmyadmin.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_session_cache   shared:PMASSL:5m;
    ssl_session_timeout 10m;

    # Restriction IP recommandée (décommente et adapte)
    # allow 192.168.0.0/24;
    # deny all;

    location / {
        proxy_pass http://127.0.0.1:8880;
    }
}
EOF
CONFDIR="$PATH_ROOT/share/config/apache"
cat > "${CONFDIR}/vhosts/phpmyadmin.conf" <<EOF
# Vhost PHPMyAdmin — Apache interne port 8880
<VirtualHost *:8880>
	ServerName phpmyadmin.local
	DocumentRoot ${PATH_ROOT}/usr/phpmyadmin

	DirectoryIndex index.php

	# PHP-FPM LINE AUTO INCLUDE
	IncludeOptional ${CONFDIR}/php-handlers/default.com.conf

	<Directory "${PATH_ROOT}/usr/phpmyadmin">
		Options -Indexes +FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ErrorLog  ${PATH_ROOT}/share/logs/apache/phpmyadmin-error.log
	CustomLog ${PATH_ROOT}/share/logs/apache/phpmyadmin-access.log combined
</VirtualHost>
EOF