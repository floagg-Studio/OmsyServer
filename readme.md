# OmsyServer

Un serveur local complet (Nginx, Apache, PHP, MySQL, Redis…) **installé et piloté depuis un seul dossier**, sans toucher aux services du système.

> ⚠️ Projet en développement : certaines parties sont encore incomplètes.

## Systèmes supportés

- macOS (Homebrew)
- Ubuntu

## Installation

```bash
git clone https://github.com/floagg-studio/OmsyServer.git
cd OmsyServer
sudo bash omsy-stable.sh
```

`omsy-stable.sh` prépare le système et installe les composants.

## Utilisation

Deux outils, tous deux configurés par `share/omsyctl/omsy.conf`.

### `omsyctl` : gérer les services

```bash
omsyctl -c share/omsyctl/omsy.conf start  mysql nginx
omsyctl -c share/omsyctl/omsy.conf stop   mysql nginx
omsyctl -c share/omsyctl/omsy.conf status mysql nginx
```

Chaque service est décrit par un fichier `<nom>.conf` avec : `label`, `shell`, `start`, `bins` et `stop`.

### `omsyd` : le démon

Écoute sur le port **8990** et relance automatiquement son processus en cas de plantage.

```bash
omsyd -c share/omsyctl/omsy.conf start    # lance en arrière-plan
omsyd -c share/omsyctl/omsy.conf stop
omsyd -c share/omsyctl/omsy.conf status
omsyd -c share/omsyctl/omsy.conf run      # lance au premier plan
```

Sans commande, `omsyd` bascule entre démarrage et arrêt.

## Avertissement

Ces scripts modifient le système (paquets, utilisateurs, fichiers). Lisez-les avant de les lancer et testez-les d'abord sur une machine virtuelle.