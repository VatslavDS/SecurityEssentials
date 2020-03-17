<#
.SYNOPSIS
    Enables Azure Devops agent to connect to the sql database
.DESCRIPTION
	Opens a port in the firewall so that the unit tests can change the database state before running integration tests
	Changes the connection string for the test so that it points to the test database
.NOTES
    Author: John Staveley
    Date:   17/03/2020    
#>
param (
	[Parameter(Mandatory=$true)]
	[string] $TestConfigPath,
	[Parameter(Mandatory=$true)]
	[string] $ResourceGroup, 
	[Parameter(Mandatory=$true)]
	[string] $SqlServerName,
	[Parameter(Mandatory=$true)]
	[string] $WebDatabaseName,
	[Parameter(Mandatory=$true)]
	[string] $RuleName,
	[Parameter(Mandatory=$true)]
	[string] $SqlAdminUserName,
	[Parameter(Mandatory=$true)]
	[string] $SqlAdminPassword
	)

Write-Host ("Configure for Testing Started")

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#NB: This puts a dependency on the website http://ipinfo.io/json, but it seems to work fine
$agentIPAddresss = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
Write-Host ("Adding firewall rule $RuleName for Server $SqlServerName allowing IP Address $agentIPAddresss")
New-AzureRmSqlServerFirewallRule -ResourceGroupName $ResourceGroup -ServerName $SqlServerName -FirewallRuleName $RuleName -StartIpAddress "$($agentIPAddresss)" -EndIpAddress "$($agentIPAddresss)"
Write-Host ("Eanble Database access for Testing Complete")

Write-Host ("Getting test config file from $TestConfigPath")
$appConfig = (Get-Content $TestConfigPath) -as [Xml]
Write-Host('app.config '+ $appConfig.OuterXml)
$appConfigRoot = $appConfig.get_DocumentElement()
Write-Host('app.config root '+ $appConfigRoot.OuterXml)
$defaultConnection = $appConfigRoot.connectionStrings.SelectNodes("add")
Write-Host('defaultConnection '+ $defaultConnection.OuterXml)
[string] $defaultConnectionString = "Data Source=tcp:$SqlServerName.database.windows.net,1433;Initial Catalog=$WebDatabaseName;User Id=$SqlAdminUserName;Password=$SqlAdminPassword"
$defaultConnection.SetAttribute("connectionString", $defaultConnectionString)
Write-Host ("Changing connection string to Data Source=tcp:$SqlServerName.database.windows.net,1433;Initial Catalog=$WebDatabaseName;User Id=$SqlAdminUserName;Password=*******")
Write-Host($appConfig.OuterXml)
$appConfig.Save($TestConfigPath)

Write-Host ("Configure for Testing Complete")