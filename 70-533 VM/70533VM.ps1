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

#you need to have made the storage account previously too 

$storageaccount = Get-AzureRmStorageAccount -ResourceGroupName $Rgname -Name "vmstestgm70533"


# Compute

#make the network cards for the VMs

# make 2 public IPs, attach them to 2 network cards
$Nicname1 = "Nic1"
$NicName2 = "Nic2"

$PIp1 = New-AzureRmPublicIpAddress -Name $Nicname1 -ResourceGroupName $Rgname -Location $Location -AllocationMethod Dynamic
$PIp2 = New-AzureRmPublicIpAddress -Name $Nicname2 -ResourceGroupName $Rgname -Location $Location -AllocationMethod Dynamic


$Nic1 = New-AzureRmNetworkInterface -Name $Nicname1 -ResourceGroupName $Rgname -Location $Location -SubnetId $Subnet1 -PublicIpAddressId $PIp1.Id
$Nic2 = New-AzureRmNetworkInterface -Name $NicName2 -ResourceGroupName $Rgname -Location $Location -SubnetId $Subnet2 -PublicIpAddressId $PIp2.Id



## Setup local VM object in memory, you'll need a long password

$location = "westeurope"
$publisher = "MicrosoftWindowsServer"
$Offer = "WindowsServer"
$sku = "2016-Datacenter" 
$VMSize ="Basic_A0"
$VMname1 = "VMtest1"   #this will also become the actual Computer object. so within the VM image. i.e. the OS or domain computer name
$VMname2 = "VMtest2"
$OSDiskName1 = $VMName1 + "OSDisk"
$OSDiskName2 = $VMName2 + "OSDisk"

##get login creds for the actual computers
$Credential = Get-Credential

##create vm1
# basic config, size and name
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName1 -VMSize $VMSize
#setting the core image (server 2016 prob. set above in variable)
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $publisher -Offer $offer -Skus $sku -Version "latest"
#setting the OS variables to appy with the deployment, watch for computer name
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $vmname1 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
#adding the previously made network card
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Nic1.Id
#add the OS disk location, dont think you actually need the ToString
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName1 + ".vhd"
#lastly the vm OS disk options 
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName1 -VhdUri $OSDiskUri -CreateOption FromImage
 
 #create the previously 'built' vm object in Azure
New-AzureRmVM -ResourceGroupName $Rgname -VM $VirtualMachine -Location $location

##create vm2
# basic config, size and name
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName2 -VMSize $VMSize
#setting the core image (server 2016 prob. set above in variable)
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $publisher -Offer $offer -Skus $sku -Version "latest"
#setting the OS variables to appy with the deployment, watch for computer name
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $vmname2 -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
#adding the previously made network card
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Nic2.Id
#add the OS disk location, dont think you actually need the ToString
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName2 + ".vhd"
#lastly the vm OS disk options 
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName2 -VhdUri $OSDiskUri -CreateOption FromImage
 
 #create the previously 'built' vm object in Azure
New-AzureRmVM -ResourceGroupName $Rgname -VM $VirtualMachine -Location $location