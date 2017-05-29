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


## Storage

##storage variables storage account names must always be lowercase
$StorageType = "Standard_LRS"
$StorAcVM = "vmstestgm70533"
$StorAcApp = "appstestgm70533"
$StorAcDiag  = "diagtestgm70533"
$StorageName = @($StorAcVM,$StorAcApp,$StorAcDiag)
$RGname = "testlabgmtest70533"
$location = "westeurope"



#network variables
##network 1 and 2 subnets
$Vnet1name = "TestlabgmVnet1"
$vnet1range = "172.16.0.0/16"

$Vnet1SN1name = "Vnet1SN1"
$vnet1SN1range = "172.16.5.0/24"

$Vnet1SN2name = "Vnet1SN2"
$vnet1SN2range = "172.16.10.0/24"

#network 2 - 1 subnet
$Vnet2name = "TestlabgmVnet2"
$vnet2range = "172.20.0.0/16"

$Vnet2SN1name = "Vnet1SN2"
$vnet2SN1range = "172.20.5.0/24"


$availSet1 = "VMAVset"
$availSet2 = "AppAVset"
# 1. Create new resource group>
New-AzureRmResourceGroup -Name $RGname -Location $location

############# build the network 2-6
#okay so, make the NSG rule, make the NSG, make the subnets config in memory, then actually create the network with subnets
#rdp rule created to allow RDP in, this is just config - i.e. in Memory
$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name "rdp-rule" -Description "Allow RDP" -Access "Allow" -Protocol "Tcp"`
     -Direction Inbound -Priority 100 -SourceAddressPrefix "Internet" -SourcePortRange * `
     -DestinationAddressPrefix * -DestinationPortRange 3389

#this creates the actual NSG which will be used for both networks and all subs
$networkSecurityGroup = New-AzureRmNetworkSecurityGroup -ResourceGroupName $RGname -Location $location `
-Name "NSG-FrontEnd" -SecurityRules $rdpRule

#this creates both the subnets for network 1 using the variables declared about
$frontendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $Vnet1SN1name `
-AddressPrefix $vnet1SN1range -NetworkSecurityGroup $networkSecurityGroup

$backendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $Vnet1SN2name -AddressPrefix `
$vnet1SN2range -NetworkSecurityGroup $networkSecurityGroup

# this creates the first network, using the subnets and NSG described above
$Vnet1 = New-AzureRmVirtualNetwork -Name $Vnet1name -ResourceGroupName $RGname `
-Location $location -AddressPrefix $vnet1range -Subnet $frontendSubnet,$backendSubnet

#this creates  the subnets for network 2 using the variables declared about
$frontendSubnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name $Vnet2SN1name `
-AddressPrefix $vnet2SN1range -NetworkSecurityGroup $networkSecurityGroup

$vnet2 = New-AzureRmVirtualNetwork -Name $Vnet2name -ResourceGroupName $RGname `
 -Location $location -AddressPrefix $vnet2range -Subnet $frontendSubnet2

#####################network end 





# make Storage account 
$StorageName | ForEach-Object {
    New-AzureRmStorageAccount -ResourceGroupName $RGname -Name $_ -Type $StorageType -Location $location

}


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