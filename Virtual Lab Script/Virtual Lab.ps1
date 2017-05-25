<# 
1. Create new Resource Group - Testlabgmtest70533
2. Create virtual netwrk with 172.16.0.0/16 
3. Create virtual netwrk with 172.20.0.0/16 
4. Create subnet 172.16.5.0 /24
5. Create Subnet 172.16.10.0 /24
6. Create NSGs for each
7. Create 3 Storage accounts - VMs , App, Diagnostics
8. Create 2 Availability Sets VMs and APPs 
9. Create 2 basic srv 2016 VMs into availability set , one in each subnet, one with managed disk, one with blob storage
10.  Azure VM agent will be installed auto from he Azure gallery
#>

#set the variables for all
$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServer"
$sku = "2016-Datacenter" 
$subscription = (Get-AzureRmSubscription).Subscriptionid

$RGname = "Testlabgmtest70533"

$Vnet1name = "TestlabgmVnet1"
$vnet1range = "172.16.0.0/16"

$Vnet2name = "TestlabgmVnet2"
$vnet2range = "172.20.0.0/16"

$Vnet1SN1name = "Vnet1SN1"
$vnet1SN1range = "172.16.5.0/24"

$Vnet1SN2name = "Vnet1SN2"
$vnet1SN2range = "172.16.10.0/24"

$StorAcVM = "VMs"
$StorAcApp = "Apps"
$StorAcDiag  = "Diag"

$availSet1 = "VM"
$availSet2 = "App"
# 1. Create new resource group>
New-AzureRmResourceGroup -Name $RGname -Location $location