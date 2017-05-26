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

#set the variables for global
$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$subscription = (Get-AzureRmSubscription).Subscriptionid
$RGname = "Testlabgmtest70533"

## Compute global
$offer = "WindowsServer"
$sku = "2016-Datacenter" 
$machinesize ="Basic_A0"
$OSDiskName = $VMName + "OSDisk"

## Storage
$StorageName = "testlabgmstorage"
$StorageType = "Standard_LRS"

#network 1
$Vnet1name = "TestlabgmVnet1"
$vnet1range = "172.16.0.0/16"

$Vnet1SN1name = "Vnet1SN1"
$vnet1SN1range = "172.16.5.0/24"

$Vnet1SN2name = "Vnet1SN2"
$vnet1SN2range = "172.16.10.0/24"

#network 2
$Vnet2name = "TestlabgmVnet2"
$vnet2range = "172.20.0.0/16"




## Network card 1
$InterfaceName = "ServerInterface06"
$Subnet1Name = "Subnet1"
$VNetName = "VNet09"
$VNetAddressPrefix = "10.0.0.0/16"
$VNetSubnetAddressPrefix = "10.0.0.0/24"

##Network card 2

$InterfaceName = "ServerInterface06"
$Subnet1Name = "Subnet1"
$VNetName = "VNet09"
$VNetAddressPrefix = "10.0.0.0/16"
$VNetSubnetAddressPrefix = "10.0.0.0/24"

$StorAcVM = "VMstestgm70533"
$StorAcApp = "Appstestgm70533"
$StorAcDiag  = "Diagtestgm70533"

$availSet1 = "VMAVset"
$availSet2 = "AppAVset"
# 1. Create new resource group>
New-AzureRmResourceGroup -Name $RGname -Location $location






# Resource Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

# Storage
$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName -Type $StorageType -Location $Location

# Network
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix
$VNet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $SubnetConfig
$Interface = New-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PIp.Id

# Compute

## Setup local VM object
$Credential = Get-Credential
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

## Create the VM in Azure
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine