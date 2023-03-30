# Virtual Machine
Azure 에서 제공하는 기본 이미지를 이용해서 base VM 을 생성하는 예제 입니다.

*변수는 안내 페이지의 [예제](https://github.com/dotnetpower/powershell-azure-vm#예제) 참고*
```powershell
$location = "KoreaCentral"
$basevm_rgname = "basevm-rg-koc"
$gallery_rgname = "gallery-rg-koc"
$compute_rgname = "compute-rg-koc"

$basevm_win_name = "mywinvm"
$basevm_linux_name = "mylinuxvm"

$username = "azureuser"
```

## Windows VM 생성
기본 이미지는 표준 이미지를 이용해서 urnAlias 로 생성
> 이미지가 생성될 때 패스워드 입력 필요(예제에서는 P@ssw0rd123! 로 통일하기로 함)

```powershell
# 표준 이미지 목록 확인
az vm image list -o table

# 표준 이미지 목록 중 Windows 서버만 sku 와 urnAlias 를 가져옴
az vm image list --query "[?offer == 'WindowsServer'].[sku,urnAlias]" -o table

# Win2022Datacenter 으로 이미지 생성(생성시 1~3분 가량 소요)
az vm create `
    --resource-group $basevm_rgname `
    --name $basevm_win_name `
    --image Win2022Datacenter `
    --public-ip-sku Standard `
    --admin-username $username

# 생성된 이미지 확인
az vm show -g $basevm_rgname -n $basevm_win_name

# VM 의 Public IP 조회(-o tsv 로 출력해야지 따옴표가 제거됨)
$ip = az vm show -d -g $basevm_rgname -n $basevm_win_name --query publicIps -o tsv
$ip

# VM에 IIS 기능 설치
az vm run-command invoke -g $basevm_rgname `
   -n $basevm_win_name `
   --command-id RunPowerShellScript `
   --scripts "Install-WindowsFeature -name Web-Server -IncludeManagementTools"

# (optional)VM에 chocolatey 설치
az vm run-command invoke -g $basevm_rgname `
   -n $basevm_win_name `
   --command-id RunPowerShellScript `
   --scripts "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

# 80 포트 열기
az vm open-port --port 80 --resource-group $basevm_rgname --name $basevm_win_name

# 접속 테스트
start "http://$ip"

# (optional) curl 호출 테스트
curl $ip
```
> run-command 로 chocolatey 를 설치하는 방법과 유사하게 이후에 커스텀 앱을 추가 설치할 수 있습니다.

## Linux VM 생성
```powershell
# 표준 이미지 목록 확인
az vm image list -o table

# UbuntuServer 인 목록를 검색
az vm image list --query "[?offer == 'UbuntuServer'].[sku,urnAlias]" -o table

# UtuntuLTS 생성하고 SSH키를 생성
az vm create `
    --resource-group $basevm_rgname `
    --name $basevm_linux_name `
    --image UbuntuLTS `
    --public-ip-sku Standard `
    --admin-username $username `
    --generate-ssh-keys

# VM 의 Public IP 조회
$ip = az vm show -d -g $basevm_rgname -n $basevm_linux_name --query publicIps -o tsv
$ip

# nginx 웹 서버 설치
az vm run-command invoke `
   --resource-group $basevm_rgname `
   --name $basevm_linux_name `
   --command-id RunShellScript `
   --scripts "sudo apt-get update && sudo apt-get install -y nginx"

# 80 포트 열기
az vm open-port --port 80 --resource-group $basevm_rgname --name $basevm_linux_name

# 브라우저로 접속 테스트
start "http://$ip"

# (optional) curl 호출 테스트
curl $ip


```