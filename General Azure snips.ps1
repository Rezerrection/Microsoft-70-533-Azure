(Get-AzureRmResourceProvider  -ProviderNamespace microsoft.compute).locations | sort -Unique

Get-AzureRmProviderOperation -OperationSearchString "microsoft.compute/*"

Get-AzureRmProviderOperation -OperationSearchString "microsoft.compute/virtualMachines*/action" | ft Operation, operationname

Get-AzureRmRoleDefinition



