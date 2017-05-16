(Get-AzureRmResourceProvider  -ProviderNamespace microsoft.compute).locations | sort -Unique

Get-AzureRmProviderOperation -OperationSearchString "microsoft.compute/*"

Get-AzureRmProviderOperation -OperationSearchString "microsoft.compute/virtualMachines*/action" | ft Operation, operationname

Get-AzureRmRoleDefinition



Get-AzureRmRoleAssignment 
#can do it fo resource group or for individual -expandprincipalgroups to see the groups they're in and have permissions hat way. 

Get-AzureRmAuthorizationChangeLog -StartTime ([datetime]::Now - [timespan]::FromDays((7)

Set-AzureRmVMAccessExtension  #name is just name of the action

#if have to manually install the service agent then you have to
#update the azure fabric of the machine to let it know
$vm = Get-AzureRmVm -ResourceGroupName -Name
$vm.OSProfile.WindowsConfiguration.ProvisionVMAgent = $true
update-azurermvm -ResourceGroupName -VM $vm 

get-azurermvm | Set-AzureRmVMOSDisk
Get-AzureRmVM | Set-AzureRmVMOSDisk