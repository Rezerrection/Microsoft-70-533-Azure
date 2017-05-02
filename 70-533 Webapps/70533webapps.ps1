Login-AzureRmAccount 
Get-AzureRmSubscription | Select-AzureRmSubscription
Get-AzureRmSubscription | Set-AzureRmContext 

$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServer"

############## APP SERVICE PLANS , WEBAPP STUFF
Get-AzureRmResourceGroup 
$resourcegroupname = "TestGMAzurePlanPS"
$appserviceplanname = "TestGMAzureAPPPlanPS"
$webappname = "TestGMAzureWebAppPS"
New-AzureRmResourceGroup -Name $resourcegroupname -Location $location 
New-AzureRmAppServicePlan -name $appserviceplanname -Location $location -ResourceGroupName $resourcegroupname -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzureRmWebApp -Name $webappname -ResourceGroupName $resourcegroupname  -Location $location -AppServicePlan $appserviceplanname

#Remove-AzureRmResourceGroup -Name $resourcegroupname