New-AzureRmSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -Location $location `
    -SqlAdministratorCredentials $(
        New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))