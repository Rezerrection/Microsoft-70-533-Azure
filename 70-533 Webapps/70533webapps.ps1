Login-AzureRmAccount 
Get-AzureRmSubscription | Select-AzureRmSubscription
Get-AzureRmSubscription | Set-AzureRmContext 

$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServer"

############## APP SERVICE PLANS , WEBAPP STUFF
Get-AzureRmResourceGroup 
$resourcegroupname = "TestGMAzureAppPlanPS"
$appserviceplanname = "TestGMAzureAPPPlanPS1"
$appserviceplanname2 = "TestGmAzureAppPlanPS2"
$webappname = "TestGMAzureWebAppPS1"
New-AzureRmResourceGroup -Name $resourcegroupname -Location $location 
New-AzureRmAppServicePlan -name $appserviceplanname -Location $location -ResourceGroupName $resourcegroupname -Tier Free -NumberofWorkers 1 -WorkerSize Small
New-AzureRmAppServicePlan -name $appserviceplanname2 -Location $location -ResourceGroupName $resourcegroupname -Tier Free -NumberofWorkers 1 -WorkerSize Small

New-AzureRmWebApp -Name $webappname -ResourceGroupName $resourcegroupname  -Location $location -AppServicePlan $appserviceplanname

#Remove-AzureRmResourceGroup -Name $resourcegroupname

# move an app from app service plan to another (switch out app service plan)
Set-AzureRmWebApp -Name $webappname -ResourceGroupName $resourcegroupname -AppServicePlan $appserviceplanname
#move a slot from one app service to another
# Set-AzureRmWebAppSlot -Name <webapp name> -Slot <slot name> -ResourceGroupName <resource group name> -AppServicePlan <new app service plan>


$gitrepo="<Replace with your GitHub repo URL>"
$webappname="mywebapp$(Get-Random)"
$location="West Europe"

# Create a resource group.
New-AzureRmResourceGroup -Name myResourceGroup -Location $location

# Create an App Service plan in Free tier.
New-AzureRmAppServicePlan -Name $webappname -Location $location `
-ResourceGroupName myResourceGroup -Tier Free

# Create a web app.
New-AzureRmWebApp -Name $webappname -Location $location `
-AppServicePlan $webappname -ResourceGroupName myResourceGroup

# Upgrade App Service plan to Standard tier (minimum required by deployment slots)
Set-AzureRmAppServicePlan -Name $webappname -ResourceGroupName myResourceGroup `
-Tier Standard

#Create a deployment slot with the name "staging".
New-AzureRmWebAppSlot -Name $webappname -ResourceGroupName myResourceGroup `
-Slot staging

# Configure GitHub deployment to the staging slot from your GitHub repo and deploy once.
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
}
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName myResourceGroup `
-ResourceType Microsoft.Web/sites/slots/sourcecontrols `
-ResourceName $webappname/staging/web -ApiVersion 2015-08-01 -Force

# Swap the verified/warmed up staging slot into production.
Swap-AzureRmWebAppSlot -Name $webappname -ResourceGroupName myResourceGroup `
-SourceSlotName staging -DestinationSlotName production