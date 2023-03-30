# chocolately 설치 부터 VSCode 설치 까지
Set-ExecutionPolicy Bypass -Scope Process -Force 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$Packages = @(
    'vscode',
    'git'    
)

foreach ($Package in $Packages) {
    choco install $Package -y
}

#Reboot
Restart-Computer -Force