##storage variables storage account names must always be lowercase
$StorageType = "Standard_LRS"
$StorAcVM = "vmstestgm70533"
$StorAcApp = "appstestgm70533"
$StorAcDiag  = "diagtestgm70533"
$StorageName = @($StorAcVM,$StorAcApp,$StorAcDiag)
$RGname = "testlabgmtest70533"
$location = "westeurope"

$StorageName | ForEach-Object {
    New-AzureRmStorageAccount -ResourceGroupName $RGname -Name $_ -Type $StorageType -Location $location

}