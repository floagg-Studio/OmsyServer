[English](CONTRIBUTING.md) | **Français**

# Contribuer à OmsyServer

Merci de votre intérêt ! OmsyServer est encore en développement, toute aide est la bienvenue : signalement de bugs, idées, corrections et documentation.

## Signaler un problème

Ouvrez une issue en indiquant :

- votre système et sa version (macOS ou Ubuntu),
- la commande lancée,
- le message d'erreur complet,
- les logs utiles de `share/logs/`.

## Proposer une modification

1. Forkez le dépôt et clonez votre fork.
2. Créez une branche : `git checkout -b ma-modification`
3. Faites vos changements et testez-les.
4. Faites un commit avec un message clair.
5. Poussez et ouvrez une pull request expliquant ce que vous avez changé et pourquoi.

Les petites pull requests ciblées sont plus faciles à relire.

## Tester sans risque

Les scripts modifient le système (voir la section Avertissement du [README](README.fr.md)). Testez toujours sur une machine virtuelle ou une machine jetable, et indiquez dans votre pull request le système testé (macOS, Ubuntu ou les deux).

## Règles

- Les scripts d'installation sont dans `source/`. Partez de `model.sh` et utilisez les fonctions de `common.sh` (comme `download_source`).
- Les scripts shell commencent par `set -e` et doivent fonctionner sur macOS et Ubuntu.
- Ne commitez jamais de chemins personnels, de mots de passe ou de fichiers générés. Utilisez `PATH_ROOT` plutôt qu'un chemin fixe.
- Gardez les outils en C (`omsyctl`, `omsyd`) portables entre Linux et macOS.
- Si votre changement touche le système (nouveau paquet, fichier hors du dossier du projet, port, utilisateur), ajoutez-le à la section Avertissement des deux README.
- Mettez à jour `README.md` et `README.fr.md` ensemble. Si vous n'écrivez que dans une langue, dites-le dans votre pull request et les mainteneurs traduiront.