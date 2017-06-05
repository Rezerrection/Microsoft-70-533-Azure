
#create the logical sql server. this is basically a container for your SQl databases and not a real server as such
New-AzureRmSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -Location $location `
    -SqlAdministratorCredentials $(
        New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

#server firewall rule SQL Database communicates over port 1433. 
# If you are trying to connect from within a corporate network, 
# outbound traffic over port 1433 may not be allowed by your network's firewall. 
# If so, you will not be able to connect to your Azure SQL Database server 
# unless your IT department opens port 1433.+

        New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -FirewallRuleName "AllowSome" -StartIpAddress $startip -EndIpAddress $endip

#create a new database with sample data 
    New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -DatabaseName $databasename `
    -SampleName "AdventureWorksLT" `
    -RequestedServiceObjectiveName "S0"

Get-AzureRmResourceGroup

$resourcegroupname = 'TestazureSWL70533RG' 
Get-AzureRmSqlServer -ResourceGroupName $resourcegroupname
$sqlservername= 'Testsql70533'
$sqlfailover = 'testsqlserver270533failover'
Get-AzureRmSqlDatabaseFailoverGroup -ServerName $sqlservername -ResourceGroupName $resourcegroupname
$failovergroup = 'testfailoversql7055'
    #switch failover groups
    Switch-AzureRmSqlDatabaseFailoverGroup -ResourceGroupName $resourcegroupname -ServerName $sqlfailover `
    -FailoverGroupName $failovergroup
    #switch it back to prod
    Switch-AzureRmSqlDatabaseFailoverGroup -ResourceGroupName $resourcegroupname -ServerName $sqlservername`
     -FailoverGroupName $failovergroup