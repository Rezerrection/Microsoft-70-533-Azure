<# 
Things to do for the virtual machines
- Create new virtual machines, Portal and Powershell - maybe CLI
- Take an existing VM from on prem into Azure
- Config with Powershell DSC and VM Agent.   
- enable remote debugging ? 
- Add a new disk to existing VM.   
- Configure disk caching
- plan storage capacity
- configure operating system disk redundancy
- configure shared storage using Azure File service
- configure geo-replication
- encrypt disks
- implement ARM VMs with Standard and Premium Storage
- Monitoring metrics on VMs - Portal and PShell
- Configure Alerts ad rules for cpu, storage, ram 
- Configure multiple ARM VMs in an availability set for redundancy
- configure each application tier into separate availability sets
- combine the Load Balancer with availability sets
- Scale up and scale down VM sizes
- deploy ARM VM Scale Sets (VMSS)
- configure ARM VMSS auto-scale
/#>

Login-AzureRmAccount 
Get-AzureRmSubscription | Select-AzureRmSubscription
Get-AzureRmSubscription | Set-AzureRmContext 

$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServer"
$sku = "2016-Datacenter"

#get all the vm extensions first line get all the image publishers, then all the image extensions types of the publishers, then all the extension images for each type
Get-AzureRmVMImagePublisher -Location $location |
Get-AzureRmVMExtensionImageType |
Get-AzureRmVMExtensionImage | select type -Unique | sort type


#list of image publishers, main one for vms is MicrosoftWindowsServer it seems
Get-AzureRmVMImagePublisher -Location $locationb

#then you have to get the offer, which appears to be WindowsServer
Get-AzureRmVMImageOffer -Location $location -PublisherName $publisher

#get list of sizes for vms
Get-AzureRmVMSize $location | Select-Object name 


#get list of operating systems
Get-AzureRmVMImageSku  -PublisherName $publisher -Offer $offer -Location $location

Get-AzureRmVMImage  -Location $location -PublisherName "microsoft" 

<#
# Variables    
## Global
$ResourceGroupName = "ResourceGroup11"
$Location = "WestEurope"

## Storage
$StorageName = "generalstorage6cc"
$StorageType = "Standard_GRS"

## Network
$InterfaceName = "ServerInterface06"
$Subnet1Name = "Subnet1"
$VNetName = "VNet09"
$VNetAddressPrefix = "10.0.0.0/16"
$VNetSubnetAddressPrefix = "10.0.0.0/24"

## Compute
$VMName = "VirtualMachine12"
$ComputerName = "Server22"
$VMSize = "Standard_A2"
$OSDiskName = $VMName + "OSDisk"

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
#>