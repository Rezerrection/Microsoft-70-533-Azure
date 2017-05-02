Login-AzureRmAccount 
Get-AzureRmSubscription | Select-AzureRmSubscription
Get-AzureRmSubscription | Set-AzureRmContext 

$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServer"
#list of image publishers, main one for vms is MicrosoftWindowsServer it seems
Get-AzureRmVMImagePublisher -Location $location

#then you have to get the offer, which appears to be WindowsServer
Get-AzureRmVMImageOffer -Location $location -PublisherName $publisher

#get list of sizes for vms
Get-AzureRmVMSize $location | Select-Object name 


#get list of operating systems
Get-AzureRmVMImageSku  -PublisherName $publisher -Offer $offer -Location $location

#Get-AzureRmVMImage  -Location $location -PublisherName "microsoft" 

############## APP SERVICE PLANS , WEBAPP STUFF
Get-AzureRmResourceGroup 
$resourcegroupname = "TestGMAzurePlanPS"
$appserviceplanname = "TestGMAzureAPPPlanPS"
$webappname = "TestGMAzureWebAppPS"
New-AzureRmResourceGroup -Name $resourcegroupname -Location $location 
New-AzureRmAppServicePlan -name $appserviceplanname -Location $location -ResourceGroupName $resourcegroupname -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzureRmWebApp -Name $webappname -ResourceGroupName $resourcegroupname  -Location $location -AppServicePlan $appserviceplanname

#Remove-AzureRmResourceGroup -Name $resourcegroupname