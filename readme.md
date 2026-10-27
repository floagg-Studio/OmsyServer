**English** | [Français](README.fr.md)

# OmsyServer

A complete local server stack (Nginx, Apache, PHP, MySQL, Redis…) **installed and managed from a single folder**, without touching the system's own services.

> ⚠️ Work in progress: some parts are still incomplete.

## Supported systems

- macOS (Apple Silicon, with Homebrew)
- Ubuntu

## Installation

```bash
git clone https://github.com/floagg-studio/OmsyServer.git
cd OmsyServer
```

1. In `source/common.sh`, set `PATH_ROOT` to the path of your folder.
2. Run the installation:
   ```bash
   sudo bash omsy-stable.sh
   ```

The script installs, in order: dependencies, OpenSSL, MySQL 8.4, Redis 7.2, Nginx 1.28, Apache 2.4 and PHP 8.5.

Nginx receives requests (ports 80 and 443) and forwards them to Apache (port 8080), which hands PHP files to PHP-FPM.

## Usage

Two tools, both configured through `share/omsyctl/omsy.conf`.

### `omsyctl`: manage services

```bash
omsyctl -c share/omsyctl/omsy.conf start  mysql nginx
omsyctl -c share/omsyctl/omsy.conf stop   mysql nginx
omsyctl -c share/omsyctl/omsy.conf status mysql nginx
```

Available services: `mysql`, `redis`, `nginx`, `apache`, `phpfpm85`.

### `omsyd`: the daemon

Listens on port **8990** and restarts itself automatically if it crashes.

```bash
omsyd -c share/omsyctl/omsy.conf start    # run in the background
omsyd -c share/omsyctl/omsy.conf stop
omsyd -c share/omsyctl/omsy.conf status
omsyd -c share/omsyctl/omsy.conf run      # run in the foreground
```

With no command, `omsyd` toggles between start and stop.

## Contributing

Contributions are welcome: see [CONTRIBUTING.md](CONTRIBUTING.md).

## Warning

These scripts modify your system. Read them before running them, and test them on a virtual machine first.

### Outside the project folder

- **Packages:** installs many packages through Homebrew (macOS) or `apt` (Ubuntu). On macOS, Homebrew itself is installed if missing.
- **User:** creates the `omsy` system user and group.
- **Link:** `/usr/local/bin/omsy-openssl` points to Omsy's OpenSSL.
- **Ubuntu only:** creates files in `/etc/ld.so.conf.d/` (`omsy-openssl.conf`, `omsy-mysql.conf`, `omsy-apache.conf`, `omsy-extra.conf` and one for pcre2), then runs `ldconfig`.

### Inside the project folder

- **Permissions:** `chown -R omsy:omsy` and `chmod -R 755` on the whole folder.
- **Scripts:** the `.sh` files are rewritten (`PATH_ROOT` replacement).
- **Folders created:** `source/` (downloaded sources), `sys/` (binaries, libraries, modules), `share/` (config, logs, run, data, ssl) and `usr/` (websites).
- **Certificates:** two self-signed certificates (`defaults` and `omsy-sql`), valid for 10 years, plus a copy of the system CA certificates in `share/config/openssl/cert.pem`.
- **Passwords:** a random MySQL root password (`share/config/mysql/.mysql_root_pass`) and a random Redis password (`share/config/redis/redis_password.txt`).
- **MySQL database:** initializes `share/data`, removes anonymous users and the `test` database, and creates the `phpmyadmin` database.
- **Generated configuration:** `my.cnf`, `redis.conf`, `nginx.conf`, `httpd.conf`, the `default.com` sites (Nginx and Apache), `php85.ini`, `php-fpm85.conf` and the `share/config/omsyctl/*.conf` files.
- **PHP:** `sys/bin/php` and `sys/bin/php-fpm` become links to `php85` and `php-fpm85`, and the Redis extension is compiled.
- **Default site:** `usr/default.com/public/index.php` displays `phpinfo()`. Delete it before going public.
- **macOS only:** rewrites library paths in the MySQL executables (`install_name_tool`) and copies the OpenSSL libraries into `sys/lib`.

### Ports used

80, 443 (Nginx), 8080 and 8880 (Apache), 3306 (MySQL, local), 6379 (Redis, local), 8990 (`omsyd`).