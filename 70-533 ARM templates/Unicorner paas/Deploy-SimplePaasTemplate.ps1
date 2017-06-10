### Define variables
{
$resourcegrouplocation = 'west europe'
$resourceGroupName = 'pluralsight-arm-unicornerpaas-templategm'
$resourceDeploymentName = 'pluralsight-arm-unicornerpaas-template-deploymentgm'
$templatePath = 'C:\Users\breau\Documents\Visual Studio 2017\Projects'
$templateFile = 'unicornerPaas.json'
$template = $templatePath + '\' + $templateFile
}

### Create Resource Group

New-AzureRmResourceGroup `
    -Name $resourceGroupName `
    -Location $resourcegrouplocation `
    -Verbose -Force


### Deploy Resources

New-AzureRmResourceGroupDeployment `
    -Name $resourceDeploymentName `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $template `
    -Verbose -Force
