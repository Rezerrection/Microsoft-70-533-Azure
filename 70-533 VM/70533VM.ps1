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

#you need to have made the networks previously and this will grab one of them and then the next grab the subnet ids

$vnet1 = (Get-AzureRmVirtualNetwork)[0]
$vnet2 = (Get-AzureRmVirtualNetwork)[1]
$Subnet1 = $Vnet1.Subnets[0].Id
$Subnet2 = $Vnet1.Subnets[1].Id

# Compute

#make the network cards for the VMs

# make 2 public IPs, attach them to 2 network cards
$Nicname1 = "Nic1"
$NicName2 = "Nic2"

$PIp1 = New-AzureRmPublicIpAddress -Name $Nicname1 -ResourceGroupName $Rgname -Location $Location -AllocationMethod Dynamic
$PIp2 = New-AzureRmPublicIpAddress -Name $Nicname2 -ResourceGroupName $Rgname -Location $Location -AllocationMethod Dynamic


$Nic1 = New-AzureRmNetworkInterface -Name $Nicname1 -ResourceGroupName $Rgname -Location $Location -SubnetId $Subnet1 -PublicIpAddressId $PIp1.Id
$Nic2= New-AzureRmNetworkInterface -Name $NicName2 -ResourceGroupName $Rgname -Location $Location -SubnetId $Subnet2 -PublicIpAddressId $PIp2.Id



## Setup local VM object in memory, you'll need a long password

$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServer"
$sku = "2016-Datacenter"
$offer = "WindowsServer"
$sku = "2016-Datacenter" 
$machinesize ="Basic_A0"
$OSDiskName = $VMName + "OSDisk"



$Credential = Get-Credential
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage


##make netwrkcards for VMs

$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName -ResourceGroupName $Rgname `-Location $Location -AllocationMethod Dynamic
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix
$VNet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $Rgname -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $SubnetConfig
$Interface = New-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $Rgname -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PIp.Id
