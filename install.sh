#!/bin/bash
set -e

if ! command -v brew &> /dev/null; then
	echo "Veuillez execute ce script en tant que admin."
	exit 1
fi

PATH_ROOT="/Users/julie/Documents/OmsyServer"

echo "Installation du serveur de base"
sh "$PATH_ROOT/store/openssl.sh"
# sh "$PATH_ROOT/store/vsftpd.sh"
# sh "$PATH_ROOT/store/nodejs.sh"

echo "Installation des base de donées"
sh "$PATH_ROOT/store/mysql.sh"
sh "$PATH_ROOT/store/redis.sh"

echo "Installation des serveur web"
sh "$PATH_ROOT/store/nginx.sh"
sh "$PATH_ROOT/store/apache.sh"

echo "Installation des extention de codes"
sh "$PATH_ROOT/store/php85.sh"
sh "$PATH_ROOT/store/phpmyadmin.sh"