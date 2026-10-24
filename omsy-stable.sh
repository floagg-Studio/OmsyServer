#!/bin/bash
set -e

if ! command -v brew &> /dev/null; then
	echo "Veuillez exécuter ce script en tant qu'admin."
	exit 1
fi

PATH_ROOT=$(pwd)
SOURCE="$PATH_ROOT/source"

mkdir -p "$SOURCE"

wget -q --show-progress -O /tmp/main.zip "https://github.com/is-omini/OmsyServerStore/archive/refs/heads/main.zip"

TMP_DIR="$(mktemp -d)"
unzip -q /tmp/main.zip -d "$TMP_DIR"
find "$TMP_DIR" -type f -name "*.sh" -exec cp {} "$SOURCE/" \;
rm -rf "$TMP_DIR" /tmp/main.zip

if [[ "$(uname -s)" == "Darwin" ]]; then
	SED_INPLACE=(-i '')
else
	SED_INPLACE=(-i)
fi
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

echo "Installation des extensions de code"
sh "$SOURCE/php-8.5.sh"