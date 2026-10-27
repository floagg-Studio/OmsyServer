#!/bin/bash
set -e

# Détermination du dossier du script de manière robuste
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "Nettoyage du dossier source dans : $PATH_ROOT"

# Nettoyage sécurisé des sous-dossiers et des archives
rm -rf "${PATH_ROOT}/source"/*/
rm -f "${PATH_ROOT}/source"/*.tgz
rm -f "${PATH_ROOT}/source"/*.tar.gz

echo "Nettoyage terminé avec succès."
