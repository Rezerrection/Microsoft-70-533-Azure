#https://docs.microsoft.com/en-gb/powershell/module/azure.storage/?view=azurermps-4.0.0

##storage variables storage account names must always be lowercase
$StorageType = "Standard_LRS"
$StorAcVM = "vmstestgm70533"
$StorAcApp = "appstestgm70533"
$StorAcDiag  = "diagtestgm70533"
$StorageName = @($StorAcVM,$StorAcApp,$StorAcDiag)
$RGname = "testlabgmtest70533"
$location = "westeurope"
$srcBlob = 'osdisk1.vhd'
$srcCont = "src"
$destCont = 'dest'
$srcSA = $StorAcVM
$destSA = $StorAcApp

$StorageName | ForEach-Object {
    New-AzureRmStorageAccount -ResourceGroupName $RGname -Name $_ -Type $StorageType -Location $location

}

Get-Command -Module AzureRM.Storage

# Containers
$srcSAKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $RGname -Name $StorAcVM).value[0]
$destSAKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $RGname -Name $StorAcApp).value[0]
$srcContext = New-AzureStorageContext –StorageAccountName $SrcSA -StorageAccountKey $srcSAKey
$destContext = New-AzureStorageContext –StorageAccountName $destSA -StorageAccountKey $destSAKey
New-AzureStorageContainer -Name $srcCont  -Context $srcContext -Permission Off
New-AzureStorageContainer -Name $destCont -Context $destContext

# Async blob copy - container to container within 1 storage account

Start-AzureStorageBlobCopy -SrcBlob $srcBlob -DestContainer $DestCont -SrcContainer $SrcCont
$srcContext = New-AzureStorageContext –StorageAccountName $srcStorageAccount -StorageAccountKey $srcStorageKey
$destContext = New-AzureStorageContext –StorageAccountName $destStorageAccount -StorageAccountKey $destStorageKey
New-AzureStorageContainer -Name $destCont -Context $destContext
$copiedBlob = Start-AzureStorageBlobCopy -SrcBlob $srcBlob `
-SrcContainer $srcCont `
-Context $srcContext `
-DestContainer $destCont `
-DestBlob $vhdName `
-DestContext $destContext

# AzCopy reference: https://azure.microsoft.com/en-us/documentation/articles/storage-use-azcopy/#blob-copy

# AzCopy (copy blob within storage account)
AzCopy /Source:https://704stor1.blob.core.windows.net/cont1 /Dest:https://704stor2.blob.core.windows.net/cont2 /SourceKey:cUYFmD4vnMmmp88ysG2YEGo5AXxe7ivqP1+M9XcodzPzPmsYS99BYOoamk1NKcOakcBM3hqqb0tHPu0c8K6MFQ== /DestKey:azulvQvPXB/K2o+0wZBTvEuRAcMprAQb07YmBvboDZ2fQl44KrDjTVzDF1Ks6Xk6qlAvMW+4JHIgSdirugSfYg== /Pattern:report1.xlsx
