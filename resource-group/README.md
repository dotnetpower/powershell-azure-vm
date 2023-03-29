# Resource Group
본 예제는 Powershell 스크립트 기반이므로 변수 및 함수는 대상 스크립트에 맞게 수정이 필요합니다.

*변수는 안내 페이지의 [예제](https://github.com/dotnetpower/powershell-azure-vm#예제) 참고*
```powershell
$location = "KoreaCentral"
$basevm_rgname = "basevm-rg-koc"
$gallery_rgname = "gallery-rg-koc"
$compute_rgname = "compute-rg-koc"
```

## Base VM 을 위한 리소스 그룹 생성
```powershell
# base vm, storage account를 위한 리소스 그룹 생성
az group create -n $basevm_rgname -l $location

# gallery 리소스 그룹 생성
az group create -n $gallery_rgname -l $location

# vm을 생성할 리소스 그룹 생성
az group create -n $compute_rgname -l $location

# 리소스 그룹 생성 확인
az group show -n $basevm_rgname
az group show -n $gallery_rgname
az group show -n $compute_rgname
```

## 리소스 정리
> **생성한 3개의 리소스 그룹 및 하위 리소스 삭제**
```powershell
az group delete -n $basevm_rgname -y
az group delete -n $gallery_rgname -y
az group delete -n $compute_rgname -y
```
