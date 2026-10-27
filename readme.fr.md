[English](README.md) | **Français**

# OmsyServer

Un serveur local complet (Nginx, Apache, PHP, MySQL, Redis…) **installé et piloté depuis un seul dossier**, sans toucher aux services du système.

> ⚠️ Projet en développement : certaines parties sont encore incomplètes.

## Systèmes supportés

- macOS (Apple Silicon, avec Homebrew)
- Ubuntu

## Installation

```bash
git clone https://github.com/floagg-studio/OmsyServer.git
cd OmsyServer
```

1. Dans `source/common.sh`, remplacez `PATH_ROOT` par le chemin de votre dossier.
2. Lancez l'installation :
   ```bash
   sudo bash omsy-stable.sh
   ```

Le script installe, dans l'ordre : les dépendances, OpenSSL, MySQL 8.4, Redis 7.2, Nginx 1.28, Apache 2.4 et PHP 8.5.

Nginx reçoit les requêtes (ports 80 et 443) et les transmet à Apache (port 8080), qui passe les fichiers PHP à PHP-FPM.

## Utilisation

Deux outils, tous deux configurés par `share/omsyctl/omsy.conf`.

### `omsyctl` : gérer les services

```bash
omsyctl -c share/omsyctl/omsy.conf start  mysql nginx
omsyctl -c share/omsyctl/omsy.conf stop   mysql nginx
omsyctl -c share/omsyctl/omsy.conf status mysql nginx
```

Services disponibles : `mysql`, `redis`, `nginx`, `apache`, `phpfpm85`.

### `omsyd` : le démon

Écoute sur le port **8990** et se relance automatiquement en cas de plantage.

```bash
omsyd -c share/omsyctl/omsy.conf start    # lance en arrière-plan
omsyd -c share/omsyctl/omsy.conf stop
omsyd -c share/omsyctl/omsy.conf status
omsyd -c share/omsyctl/omsy.conf run      # lance au premier plan
```

Sans commande, `omsyd` bascule entre démarrage et arrêt.

## Avertissement

Les scripts modifient votre système. Lisez-les avant de les lancer et testez-les d'abord sur une machine virtuelle.

### Hors du dossier du projet

- **Paquets :** installation de nombreux paquets via Homebrew (macOS) ou `apt` (Ubuntu). Sur macOS, Homebrew est installé s'il est absent.
- **Utilisateur :** création de l'utilisateur et du groupe système `omsy`.
- **Lien :** `/usr/local/bin/omsy-openssl` pointe vers l'OpenSSL d'Omsy.
- **Ubuntu uniquement :** création de fichiers dans `/etc/ld.so.conf.d/` (`omsy-openssl.conf`, `omsy-mysql.conf`, `omsy-apache.conf`, `omsy-extra.conf` et un fichier pour pcre2), puis exécution de `ldconfig`.

### Dans le dossier du projet

- **Droits :** `chown -R omsy:omsy` et `chmod -R 755` sur tout le dossier.
- **Scripts :** les fichiers `.sh` sont réécrits (remplacement de `PATH_ROOT`).
- **Arborescence créée :** `source/` (sources téléchargées), `sys/` (binaires, bibliothèques, modules), `share/` (config, logs, run, data, ssl) et `usr/` (sites web).
- **Certificats :** deux certificats auto-signés (`defaults` et `omsy-sql`), valables 10 ans, avec une copie des certificats CA du système dans `share/config/openssl/cert.pem`.
- **Mots de passe :** un mot de passe root MySQL aléatoire (`share/config/mysql/.mysql_root_pass`) et un mot de passe Redis aléatoire (`share/config/redis/redis_password.txt`).
- **Base de données MySQL :** initialisation de `share/data`, suppression des utilisateurs anonymes et de la base `test`, création de la base `phpmyadmin`.
- **Configurations générées :** `my.cnf`, `redis.conf`, `nginx.conf`, `httpd.conf`, les sites `default.com` (Nginx et Apache), `php85.ini`, `php-fpm85.conf` et les fichiers `share/config/omsyctl/*.conf`.
- **PHP :** `sys/bin/php` et `sys/bin/php-fpm` deviennent des liens vers `php85` et `php-fpm85`, et l'extension Redis est compilée.
- **Site par défaut :** `usr/default.com/public/index.php` affiche `phpinfo()`. Supprimez-le avant toute mise en ligne.
- **macOS uniquement :** modification des chemins des bibliothèques dans les exécutables MySQL (`install_name_tool`) et copie des bibliothèques OpenSSL dans `sys/lib`.

### Ports utilisés

80, 443 (Nginx), 8080 et 8880 (Apache), 3306 (MySQL, local), 6379 (Redis, local), 8990 (`omsyd`).

## Contribuer

Les contributions sont les bienvenues : voir [CONTRIBUTING.fr.md](CONTRIBUTING.fr.md).


# Canary 