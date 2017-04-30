Login-AzureRmAccount 
Get-AzureRmSubscription | Select-AzureRmSubscription
Get-AzureRmSubscription | Set-AzureRmContext 

$location = "westeurope"

Get-AzureRmVMImagePublisher -Location $location
Get-AzureRmVMImageOffer -Location $location

#get list of sizes for vms
Get-AzureRmVMSize $location | Select-Object name 


#get list of operating systems
Get-AzureRmVMImageSku  -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Location $location

#Get-AzureRmVMImage  -Location $location -PublisherName "microsoft" 
