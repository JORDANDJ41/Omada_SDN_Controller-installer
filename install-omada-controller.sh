#!/usr/bin/env bash
#title        : install-omada-controller.sh
#description  : Installe ou met a jour le controleur TP-Link Omada (Omada Network Application)
#supported    : Ubuntu 20.04 / 22.04 / 24.04, Debian 11 / 12 (x86_64 uniquement)
#author       : JORDANDJ41 (cloud41)
#created      : 2022-11-17
#updated      : 2026-11-15
#
# Usage :
#   curl -fsSL https://raw.githubusercontent.com/JORDANDJ41/Omada_SDN_Controller-installer/main/install-omada-controller.sh | sudo bash
#
# Pour forcer une autre version, passer l'URL du .deb officiel :
#   curl -fsSL .../install-omada-controller.sh | sudo OMADA_URL="https://static.tp-link.com/....deb" bash

set -euo pipefail

# --- Version par defaut (page officielle : https://support.omadanetworks.com/download/software/omada-controller/)
OMADA_VERSION_DEFAUT="6.3.0.45"
OMADA_URL_DEFAUT="https://static.tp-link.com/upload/software/2026/202609/20260904/Omada_Network_Application_v6.3.0.45_linux_x64_20260903171910.deb"
OMADA_URL="${OMADA_URL:-$OMADA_URL_DEFAUT}"

ROUGE='\e[1;31m'; VERT='\e[1;32m'; JAUNE='\e[1;33m'; RAZ='\e[0m'
info()   { echo -e "${VERT}==>${RAZ} $*"; }
alerte() { echo -e "${JAUNE}ATTENTION :${RAZ} $*"; }
erreur() { echo -e "${ROUGE}ERREUR :${RAZ} $*" >&2; exit 1; }

# --- Verifications prealables -------------------------------------------------
[[ $EUID -eq 0 ]] || erreur "Lancer le script en root (sudo)."

[[ "$(uname -m)" == "x86_64" ]] || erreur "Seule l'architecture x86_64 est supportee par TP-Link."

# MongoDB 5.0 et plus exige un processeur avec AVX (souvent absent sur les vieux CPU
# ou les VM Proxmox en type de CPU 'kvm64' : passer le CPU de la VM en 'host').
grep -qw avx /proc/cpuinfo || erreur "Le processeur ne supporte pas AVX, requis par MongoDB 7/8.
  Sur une VM Proxmox : Materiel > Processeurs > Type = host."

[[ -r /etc/os-release ]] || erreur "Impossible de detecter le systeme (/etc/os-release absent)."
# shellcheck disable=SC1091
. /etc/os-release

case "${ID}:${VERSION_ID}" in
    ubuntu:20.04) DEPOT="ubuntu"; CODENAME="focal";    MONGO="8.0" ;;
    ubuntu:22.04) DEPOT="ubuntu"; CODENAME="jammy";    MONGO="8.0" ;;
    ubuntu:24.04) DEPOT="ubuntu"; CODENAME="noble";    MONGO="8.0" ;;
    debian:11)    DEPOT="debian"; CODENAME="bullseye"; MONGO="7.0" ;;
    debian:12)    DEPOT="debian"; CODENAME="bookworm"; MONGO="8.0" ;;
    *) erreur "Systeme non supporte : ${PRETTY_NAME:-inconnu}.
  Systemes supportes : Ubuntu 20.04 / 22.04 / 24.04, Debian 11 / 12." ;;
esac
info "Systeme detecte : ${PRETTY_NAME} -> MongoDB ${MONGO}"

LIBRE_GO=$(df -BG --output=avail / | tail -1 | tr -dc '0-9')
(( LIBRE_GO >= 10 )) || alerte "Seulement ${LIBRE_GO} Go libres sur / (10 Go conseilles)."

# --- Installation existante ? -------------------------------------------------
if dpkg -s omadac >/dev/null 2>&1 || [[ -d /opt/tplink/EAPController ]]; then
    VERSION_ACTUELLE=$(dpkg-query -W -f='${Version}' omadac 2>/dev/null || echo "inconnue")
    alerte "Omada est deja installe (version ${VERSION_ACTUELLE}). Le script va le mettre a jour."
    alerte "Pensez a faire une sauvegarde avant : Parametres > Maintenance > Sauvegarde."
    REP="o"   # sans terminal (installation automatisee) : on continue
    read -r -p "Continuer la mise a jour ? [o/N] " REP < /dev/tty 2>/dev/null || true
    [[ "$REP" =~ ^[oOyY]$ ]] || { info "Abandon."; exit 0; }
fi

# --- Dependances --------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
info "Mise a jour des paquets et installation des dependances..."
apt-get update -qq
apt-get install -y -qq ca-certificates curl gnupg openjdk-17-jre-headless jsvc

# --- MongoDB (depot officiel, cle signee, sans apt-key obsolete) ---------------
CLE="/usr/share/keyrings/mongodb-server-${MONGO}.gpg"
LISTE="/etc/apt/sources.list.d/mongodb-org-${MONGO}.list"
if ! dpkg -s mongodb-org-server >/dev/null 2>&1; then
    info "Ajout du depot MongoDB ${MONGO}..."
    curl -fsSL "https://www.mongodb.org/static/pgp/server-${MONGO}.asc" | gpg --dearmor --yes -o "$CLE"
    if [[ "$DEPOT" == "ubuntu" ]]; then
        echo "deb [ arch=amd64 signed-by=${CLE} ] https://repo.mongodb.org/apt/ubuntu ${CODENAME}/mongodb-org/${MONGO} multiverse" > "$LISTE"
    else
        echo "deb [ arch=amd64 signed-by=${CLE} ] https://repo.mongodb.org/apt/debian ${CODENAME}/mongodb-org/${MONGO} main" > "$LISTE"
    fi
    apt-get update -qq
    info "Installation de MongoDB ${MONGO}..."
    apt-get install -y -qq mongodb-org
else
    info "MongoDB deja present ($(dpkg-query -W -f='${Version}' mongodb-org-server)), on le garde."
fi

# --- Omada ----------------------------------------------------------------------
FICHIER="/tmp/$(basename "$OMADA_URL")"
info "Telechargement d'Omada : $(basename "$OMADA_URL")"
curl -fL --retry 3 -o "$FICHIER" "$OMADA_URL"

info "Installation d'Omada (quelques minutes, le premier demarrage est long)..."
apt-get install -y "$FICHIER"
rm -f "$FICHIER"

# --- Fin ------------------------------------------------------------------------
IP=$(hostname -I | awk '{print $1}')
echo
info "Omada est installe !"
echo -e "   Interface : ${VERT}https://${IP}:8043${RAZ} (patienter 2-3 min au premier demarrage)"
echo    "   Etat      : sudo tpeap status"
echo    "   Demarrer  : sudo tpeap start"
echo    "   Arreter   : sudo tpeap stop"
