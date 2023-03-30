# Virtual Machine With Custom Image
Compute Image Gallery에 등록해둔 이미지를 이용해서 base VM 을 생성하는 예제 입니다.

*변수는 안내 페이지의 [예제](https://github.com/dotnetpower/powershell-azure-vm#예제) 참고*
```powershell
$location = "KoreaCentral"
$basevm_rgname = "basevm-rg-koc"
$gallery_rgname = "gallery-rg-koc"
$compute_rgname = "compute-rg-koc"

$gallery_name = "myGallery"
$windows_imagedef_name = "windowsImageDef"
$linux_imagedef_name = "linuxImageDef"

$windows_vm_name = "winvm"

$storageaccount_name = "basevmstg"
$container_name = "script"
```

## 이미지 갤러리 목록 조회 후 이미지 생성(Windows)
[이미지 갤러리 생성](../compute-gallery/README.md)에서 생성한 갤러리를 사용하는 예제입니다.
기본 이미지를 그대로 사용하며, 기본 이미지 생성 시, IIS 설치와 80 포트를 오픈하였고, IIS 설치는 이미지에 포함되어서 신규 VM 에 적용이 되지만 80포트는 추가적으로 열어주어야 합니다.
```powershell

# 이미지 갤러리 목록를 조회
az sig image-definition list -g $gallery_rgname --gallery-name $gallery_name --query "[].name" -o tsv

# windows 이미지 갤러리의 이미지 버전 조회
$image_version = az sig image-version list -g $gallery_rgname --gallery-name $gallery_name `
    --gallery-image-definition $windows_imagedef_name `
    --query "[].name" -o tsv
$image_version

# 구독ID 설정
$subscriptionid = az account show --query id -o tsv 

# 신규로 생성되는 VM 은 $compute_rgname 에 생성이 되고, 이미지는 $gallery_rgname 에 등록된 이미지를 가져옴.
az vm create --resource-group $compute_rgname --name $windows_vm_name `
    --image /subscriptions/$subscriptionid/resourceGroups/$gallery_rgname/providers/Microsoft.Compute/galleries/$gallery_name/images/$windows_imagedef_name/versions/$image_version `
    --specialized

# VM 의 Public IP 조회(-o tsv 로 출력해야지 따옴표가 제거됨)
$ip = az vm show -d -g $compute_rgname -n $windows_vm_name --query publicIps -o tsv
$ip

# 80 포트 열기
az vm open-port --port 80 --resource-group $compute_rgname --name $windows_vm_name

# 접속 테스트
start "http://$ip"

# (optional) curl 호출 테스트
curl $ip

```

## 생성한 신규 VM 에 사용자 정의 스크립트 실행
Storage Account에 업로드 해둔 [Powershell 스크립트](../storage-account/install.ps1)를 Run-command 를 이용하여 실행 하는 방법 예제
```powershell
# 필요한 변수
$storageaccount_name = "basevmstg"
$container_name = "script"

# SAS 토큰 발급
$sas = az storage container generate-sas `
    --account-name $storageaccount_name `
    --name $container_name `
    --permissions acdlrw `
    --expiry ((Get-Date).AddDays(1)).ToString("yyyy-MM-dd") `
    --auth-mode login `
    --as-user -o tsv
$sas

# 스크립트 경로
$script_url = "https://$storageaccount_name.blob.core.windows.net/$container_name/install.ps1?$sas"

# 신규 생성된 $windows_vm_name 을 대상으로 install.ps1 스크립트 실행
az vm run-command invoke -g $compute_rgname `
   -n $windows_vm_name `
   --command-id RunPowerShellScript `
   --scripts "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('$script_url'))"
```
