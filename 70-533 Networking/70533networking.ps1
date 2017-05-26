
$location = "westeurope"
$subscription = (Get-AzureRmSubscription).Subscriptionid
$RGname = "Testlabgmtest70533"

New-AzureRmResourceGroup -Name $RGname -Location $location

#network variables
$Vnet1name = "TestlabgmVnet1"
$vnet1range = "172.16.0.0/16"

$Vnet1SN1name = "Vnet1SN1"
$vnet1SN1range = "172.16.5.0/24"

$Vnet1SN2name = "Vnet1SN2"
$vnet1SN2range = "172.16.10.0/24"


#rdp rule created to allow RDP in, this is just config - i.e. in Memory
$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name "rdp-rule" -Description "Allow RDP" -Access "Allow" -Protocol "Tcp"`
     -Direction Inbound -Priority 100 -SourceAddressPrefix "Internet" -SourcePortRange * `
     -DestinationAddressPrefix * -DestinationPortRange 3389

#this creates the actual security grup 
$networkSecurityGroup = New-AzureRmNetworkSecurityGroup -ResourceGroupName "TestResourceGroup" -Location centralus `
-Name "NSG-FrontEnd" -SecurityRules $rdpRule

$frontendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $Vnet1SN1name `
-AddressPrefix $vnet1SN1range -NetworkSecurityGroup $networkSecurityGroup

$backendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $Vnet1SN2name -AddressPrefix `
$vnet1SN2range -NetworkSecurityGroup $networkSecurityGroup

New-AzureRmVirtualNetwork -Name $Vnet1name -ResourceGroupName "TestResourceGroup"
    -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $frontendSubnet,$backendSubnet