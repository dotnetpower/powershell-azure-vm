# Compute Gallery
이미지 갤러리, 이미지 정의를 생성한 후 베이스 VM 으로 이미지 버전 생성하는 예제 입니다.
이미지 정의 생성할때 os-type 을 지정하게 되는데, Windows, Linux 타입을 각각 생성 합니다.

*변수는 안내 페이지의 [예제](https://github.com/dotnetpower/powershell-azure-vm#예제) 참고*
```powershell
$location = "KoreaCentral"
$basevm_rgname = "basevm-rg-koc"
$gallery_rgname = "gallery-rg-koc"
$compute_rgname = "compute-rg-koc"

$gallery_name = "myGallery"
$windows_imagedef_name = "windowsImageDef"
$linux_imagedef_name = "linuxImageDef"

$publisher_name = "contoso"
$offer_name = "contoso"
$windows_sku_name = "windows" #또는 "windows"
$linux_sku_name = "linux" #또는 "windows"
$os_type = "Linux" #또는 "Windows"
$os_state = "Specialized" #또는 Generalized

$gallery_image_version = "1.0.0"

```

## 공유 이미지 갤러리 생성 (Shared Image Gallery)
```powershell
# 이미지 갤러리 생성
az sig create --resource-group $gallery_rgname --gallery-name $gallery_name --location $location

# 이미지 정의 생성 (Windows)
az sig image-definition create --resource-group $gallery_rgname `
    --gallery-name $gallery_name --gallery-image-definition $windows_imagedef_name `
    --publisher $publisher_name --offer $offer_name --sku $windows_sku_name `
    --os-type "Windows" --os-state $os_state

# 이미지 정의 생성 (Linux)
az sig image-definition create --resource-group $gallery_rgname `
    --gallery-name $gallery_name --gallery-image-definition $linux_imagedef_name `
    --publisher $publisher_name --offer $offer_name --sku $linux_sku_name `
    --os-type "Linux" --os-state $os_state

# 이미지 버전 조회 
az sig image-version list -g $gallery_rgname --gallery-name $gallery_name --gallery-image-definition $windows_imagedef_name


# 이미지 버전 생성에 필요한 정보 조회
$subscriptionid = az account show --query id -o tsv

# 이미지 버전 생성(Windows), 리소스 그룹은 VM 이 있는 리소스 그룹 필요.
az sig image-version create --resource-group $gallery_rgname `
--gallery-name $gallery_name --gallery-image-definition $windows_imagedef_name `
--gallery-image-version $gallery_image_version `
--virtual-machine "/subscriptions/$subscriptionid/resourceGroups/$basevm_rgname/providers/Microsoft.Compute/virtualMachines/$basevm_win_name"

# 이미지 버전 생성(Linux)
az sig image-version create --resource-group $gallery_rgname `
--gallery-name $gallery_name --gallery-image-definition $linux_imagedef_name `
--gallery-image-version $gallery_image_version `
--virtual-machine "/subscriptions/$subscriptionid/resourceGroups/$basevm_rgname/providers/Microsoft.Compute/virtualMachines/$basevm_linux_name"

# 이미지 버전 조회 
az sig image-version list -g $gallery_rgname --gallery-name $gallery_name --gallery-image-definition $windows_imagedef_name
az sig image-version list -g $gallery_rgname --gallery-name $gallery_name --gallery-image-definition $linux_imagedef_name


```