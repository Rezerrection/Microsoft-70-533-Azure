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

Add-AzureRmVMDataDisk 