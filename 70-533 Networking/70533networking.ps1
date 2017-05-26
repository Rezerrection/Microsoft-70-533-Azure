
$location = "westeurope"
$RGname = "Testlabgmtest70533"

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

#create the role group
New-AzureRmResourceGroup -Name $RGname -Location $location

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
$vnet1 = New-AzureRmVirtualNetwork -Name $Vnet1name -ResourceGroupName $RGname `
-Location $location -AddressPrefix $vnet1range -Subnet $frontendSubnet,$backendSubnet



#this creates the subnet for network 2 using the variables declared about
$frontendSubnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name $Vnet2SN1name `
-AddressPrefix $vnet2SN1range -NetworkSecurityGroup $networkSecurityGroup

 $vnet2 = New-AzureRmVirtualNetwork -Name $Vnet2name -ResourceGroupName $RGname `
 -Location $location -AddressPrefix $vnet2range -Subnet $frontendSubnet2