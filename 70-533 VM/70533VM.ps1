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
#list of image publishers, main one for vms is MicrosoftWindowsServer it seems
Get-AzureRmVMImagePublisher -Location $location

#then you have to get the offer, which appears to be WindowsServer
Get-AzureRmVMImageOffer -Location $location -PublisherName $publisher

#get list of sizes for vms
Get-AzureRmVMSize $location | Select-Object name 


#get list of operating systems
Get-AzureRmVMImageSku  -PublisherName $publisher -Offer $offer -Location $location

#Get-AzureRmVMImage  -Location $location -PublisherName "microsoft" 
