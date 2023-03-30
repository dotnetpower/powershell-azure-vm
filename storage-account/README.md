# Storage Account
VM 에는 프로비저닝 될 때 처음 실행할 수 있는 Custom Data 와 필요시 마다 실행할 수 있는 User Data 를 지정하여 사용할 수 있습니다.
- Custom Data 는 VM 을 생성 할 때 스크립트 또는 텍스트 파일 형태로 지정 할 수 있고, 이렇게 지정된 스크립트는 단일 VM의 경우 업데이트할 수 없고, VMSS의 경우에 스케일 변경시 업데이트를 할 수 있습니다.
- User Data 는 Custom Data와 유사하지만 VM 수명동안 영구적으로 재 사용할수 있고, VM 을 중지하거나 다시 부팅하지 않고 업데이트 할 수 있습니다.
  기존 VM 에 [사용자 흐름 업데이트](https://learn.microsoft.com/ko-kr/azure/virtual-machines/user-data#updating-user-data)를 통해서도 스크립트를 업데이트할 수 있습니다.

*변수는 안내 페이지의 [예제](https://github.com/dotnetpower/powershell-azure-vm#예제) 참고*
```powershell
$location = "KoreaCentral"
$basevm_rgname = "basevm-rg-koc"

$storageaccount_name = "basevmstg"
$container_name = "script"
```

## Storage Account 생성
```powershell

# storage account 생성
az storage account create -g $basevm_rgname -n $storageaccount_name -l $location --sku Standard_LRS

# blob 컨테이너 생성
az storage container create --account-name $storageaccount_name -n $container_name

# TODO: https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-user-delegation-sas-create-cli

```

## SAS 토큰 발급
```powershell

$subscriptionid = az account show --query id -o tsv 
$email = az account show --query user.name -o tsv

# RBAC 권한 추가
az role assignment create `
    --role "Storage Blob Data Contributor" `
    --assignee $email `
    --scope "/subscriptions/$subscriptionid/resourceGroups/$basevm_rgname/providers/Microsoft.Storage/storageAccounts/$storageaccount_name"

# SAS 토큰 발급
$sas = az storage container generate-sas `
    --account-name $storageaccount_name `
    --name $container_name `
    --permissions acdlrw `
    --expiry ((Get-Date).AddDays(1)).ToString("yyyy-MM-dd") `
    --auth-mode login `
    --as-user
$sas

```

## Blob 스토리지에 설치 스크립트 업로드 
아래 스크립트 실행 시, /powershell-zure-vm/storage-account 에서 실행 필요
```powershell
az storage blob upload `
    --account-name $storageaccount_name `
    --container-name $container_name `
    --name install.ps1 `
    --file install.ps1 `
    --auth-mode login
```
이렇게 업로드 된 설치 스크립트를 해당 VM 에서 run-command 로 호출할 때 URL 뒤에 SAS 토큰을 붙여서 실행 하면 OK.

