# OmsyServer

Environnement serveur local (web, base de données, PHP, cache) **installé et piloté depuis un seul dossier**, sans toucher aux services du système.

OmsyServer fonctionne avec [OmsyServerStore](https://github.com/is-omini/OmsyServerStore) :

- **OmsyServerStore** fournit les scripts qui compilent et installent chaque composant (Apache, Nginx, MySQL, PHP, Redis, OpenSSL…).
- **OmsyServer** prépare l'environnement, lance l'installation et permet de **démarrer / arrêter** les services installés.

> ⚠️ Projet en cours de développement : certaines parties sont encore incomplètes.

## Contenu

| Fichier | Rôle |
|---|---|
| `omsy.sh` | Prépare le système : dépendances, utilisateur `omsy`, sources, arborescence |
| `install.sh` | Lance l'installation des composants depuis le dossier `store/` |
| `store/` | Scripts d'installation des composants (voir OmsyServerStore) |
| `systemcontroler.json` | Description des services : nom, binaires, commandes de démarrage et d'arrêt |
| `omsy-stackctl.py` | Script Python qui démarre ou arrête les services décrits dans le JSON |

## Systèmes supportés

- macOS (Homebrew)
- Ubuntu

## Installation

```bash
git clone https://github.com/is-omini/OmsyServer.git
cd OmsyServer
```

1. **Définir le dossier d'installation.** Dans `omsy.sh` et `install.sh`, modifiez la variable `PATH_ROOT` (actuellement un chemin personnel : `/Users/julie/Documents/OmsyServer`) pour qu'elle pointe vers votre dossier.
2. **Préparer le système :**
   ```bash
   sudo bash omsy.sh
   ```
   Ce script installe les dépendances de compilation, crée l'utilisateur et le groupe `omsy`, télécharge les bibliothèques sources (apr, apr-util, pcre2, nghttp2, zlib, extension PHP redis) et crée l'arborescence :
   ```
   PATH_ROOT/
   ├── source/     (sources téléchargées)
   ├── sys/        (bin, lib, module)
   ├── share/      (config, logs, empty)
   └── usr/
   ```
3. **Installer les composants :**
   ```bash
   bash install.sh
   ```
   Installe dans l'ordre : OpenSSL, MySQL, Redis, Nginx, Apache, PHP 8.5, phpMyAdmin.

> `install.sh` vérifie actuellement la présence de Homebrew : il est donc prévu pour macOS pour le moment.

## Gestion des services

`omsy-stackctl.py` lit `systemcontroler.json` pour démarrer ou arrêter les services :

```bash
python3 omsy-stackctl.py systemcontroler.json start mysql nginx phpfpm85
python3 omsy-stackctl.py systemcontroler.json stop  mysql nginx phpfpm85
```

Le dossier racine est celui du script, ou la variable d'environnement `ROOT_PATH` si elle est définie.

### Services déclarés

| Nom | Service | Démarrage / arrêt |
|---|---|---|
| `mysql` | MySQL / MariaDB | ✅ |
| `nginx` | Nginx | ✅ |
| `apache` | Apache | ✅ |
| `phpfpm85` | PHP-FPM 8.5 | ✅ |
| `redis` | Redis | ✅ |
| `vsftpd` | vsftpd (FTP) | ✅ |
| `openssl` | OpenSSL | installation seulement |
| `nodejs` | Node.js | installation seulement |
| `postgresql` | PostgreSQL | à venir |
| `docker` | Docker | à venir |
| `ssh` | SSH | à venir |

Pour ajouter un service, ajoutez une entrée dans `systemcontroler.json` avec :
- `sh` : le script d'installation
- `label` : le nom affiché
- `bins` : les binaires associés
- `start` / `stop` : les commandes de démarrage et d'arrêt (`${root_path}` est remplacé par le dossier racine)

## Avertissement

Ces scripts modifient le système (paquets, utilisateurs, fichiers). Lisez-les avant de les exécuter et testez-les d'abord sur une machine virtuelle ou un serveur de test.