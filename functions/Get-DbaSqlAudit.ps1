Function Get-DbaSqlAudit
{
<#
.SYNOPSIS 
Get-DbaSqlAudit will collect SQL Audit files from remote servers and import them in to a central repository

.DESCRIPTION
Copy sqlaudit files from remote servers to a central repository and then import into a SQL table. 

.PARAMETER SqlServer
Source SQL Server. You must have sysadmin access and server version must be SQL Server version 2008 or greater

.PARAMETER Path
Destination Path where the *.sqlaudit files will be copied to be stored centrally or imported in to the destination SQL Server table

.PARAMETER Import
The import parameter will tell the function to import the *.sqlaudit collected to the destination SQL Server table

.PARAMETER Destination
Destination Sql Server. This will be the SQL Server where the copied sqlaudit files will be imported

.PARAMETER Database
Destination database where the sql audit files that were copied will be imported

.PARAMETER Table
Destination table where the sqlaudit files that where copied will be imported

.PARAMETER Archive
This parameter in conjunction with the -Import parameter will move the sqlaudit files to an Archive folder after being imported.  
If the -Archive parameter is not used the sqlaudit files will be deleted

.NOTES 
Original Author: Garry Bargsley (@gbargsley, blog.garrybargsley.com)

dbatools PowerShell module (https://dbatools.io, clemaire@gmail.com)
Copyright (C) 2016 Chrissy LeMaire

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

.LINK
https://dbatools.io/Get-DbaSqlAudit

.EXAMPLE   
Get-DbaSqlAudit -SqlServer sqlserver2014a -Path \\CentralServer\SecurityAuditFiles

Copies all the SQL Audit files from sqlserver2014a to the network path \\CentralServer\SecurityAuditFiles

.EXAMPLE   
Get-DbaSqlAudit -SqlServer sqlserver2014a -Path \\CentralServer\SecurityAuditFiles -Import -Destination centralsqlserver -Database dbadmin -Table securityaudit

Copies all the SQL Audit files from sqlserver2014a to the network path \\CentralServer\SecurityAuditFiles.  With the -Import parameter being used the 
SQL Audit Files will be imported in the the centralsqlserver into the securityaudit table in the dbadmin database. 

#>
	[CmdletBinding(DefaultParameterSetName = "Default", SupportsShouldProcess = $true)]
	param (
		[parameter(Mandatory = $true)]
		[object]$SqlServer,
		[parameter(Mandatory = $true)]
		[object]$Path,
		[switch]$Import,
		[object]$Destination,
        [string]$Database,
        [string]$Table,
        [switch]$Archive
	)
	DynamicParam { if ($SqlServer) { return (Get-DbaSqlAudit -SqlServer $Source -SqlCredential $SourceSqlCredential) } }
	
	BEGIN
	{
		$triggers = $psboundparameters.Triggers
		
		$sourceserver = Connect-SqlServer -SqlServer $Source -SqlCredential $SourceSqlCredential
		$destserver = Connect-SqlServer -SqlServer $Destination -SqlCredential $DestinationSqlCredential
		
		$source = $sourceserver.DomainInstanceName
		$destination = $destserver.DomainInstanceName
		
		if ($sourceserver.versionMajor -lt 9 -or $destserver.versionMajor -lt 9)
		{
			throw "Server Triggers are only supported in SQL Server 2005 and above. Quitting."
		}
		
		$servertriggers = $sourceserver.Triggers
		$desttriggers = $destserver.Triggers
		
	}
	PROCESS
	{
		foreach ($trigger in $servertriggers)
		{
			$triggername = $trigger.name
			if ($triggers.length -gt 0 -and $triggers -notcontains $triggername) { continue }
			
			if ($desttriggers.name -contains $triggername)
			{
				if ($force -eq $false)
				{
					Write-Warning "Server trigger $triggername exists at destination. Use -Force to drop and migrate."
					continue
				}
				else
				{
					If ($Pscmdlet.ShouldProcess($destination, "Dropping server trigger $triggername and recreating"))
					{
						try
						{
							Write-Verbose "Dropping server trigger $triggername"
							$destserver.triggers[$triggername].Drop()
						}
						catch { 
							Write-Exception $_ 
							continue
						}
					}
				}
			}

			If ($Pscmdlet.ShouldProcess($destination, "Creating server trigger $triggername"))
			{
				try
				{
					Write-Output "Copying server trigger $triggername"
					$sql = $trigger.Script() | Out-String
					$sql = $sql -replace [Regex]::Escape("'$source'"), [Regex]::Escape("'$destination'")
					$sql = $sql -replace "CREATE TRIGGER", "`nGO`nCREATE TRIGGER"
					$sql = $sql -replace "ENABLE TRIGGER", "`nGO`nENABLE TRIGGER"
					
					Write-Verbose $sql
					$destserver.ConnectionContext.ExecuteNonQuery($sql) | Out-Null
				}
				catch
				{
					Write-Exception $_
				}
			}
		}
	}
	
	END
	{
		$sourceserver.ConnectionContext.Disconnect()
		$destserver.ConnectionContext.Disconnect()
		If ($Pscmdlet.ShouldProcess("console", "Showing finished message")) { Write-Output "Server trigger migration finished" }
	}
}