#Login-AzureRmAccount 
Get-AzureRmSubscription | Select-AzureRmSubscription
Get-AzureRmSubscription | Set-AzureRmContext 

$location = "westeurope"

Get-AzureRmVMImagePublisher -Location $location
Get-AzureRmVMImageOffer -Location $location




Get-AzureRmVMImage  -Location $location -PublisherName "microsoft" -o
