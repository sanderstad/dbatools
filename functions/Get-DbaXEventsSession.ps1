function Get-DbaXEventsSession
{
 <#
.SYNOPSIS
Get a list of Extended Events Sessions

.DESCRIPTION
Retrieves a list of Extended Events Sessions

.PARAMETER SqlInstance
The SQL Instances that you're connecting to.

.PARAMETER SqlCredential
Credential object used to connect to the SQL Server as a different user

.PARAMETER Sessions
Only return specific sessions. This parameter is auto-populated.

.NOTES
Tags: Memory
Author: Klaas Vandenberghe ( @PowerDBAKlaas )
	
dbatools PowerShell module (https://dbatools.io)
Copyright (C) 2016 Chrissy LeMaire
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

	
.LINK
https://dbatools.io/Get-DbaXEventsSession

.EXAMPLE
Get-DbaXEventsSession -SqlInstance ServerA\sql987

Returns a custom object with ComputerName, SQLInstance, Session, StartTime, Status and other properties.

.EXAMPLE
Get-DbaXEventsSession -SqlInstance ServerA\sql987 | Format-Table ComputerName, SQLInstance, Session, Status -AutoSize

Returns a formatted table displaying ComputerName, SQLInstance, Session, and Status.

.EXAMPLE
'ServerA\sql987','ServerB' | Get-DbaXEventsSession

Returns a custom object with ComputerName, SQLInstance, Session, StartTime, Status and other properties, from multiple SQL Instances.
#>
	[CmdletBinding()]
	param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer")]
		[DbaInstanceParameter[]]$SqlInstance,
		[PSCredential]$SqlCredential
	)

	begin {
		if ([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.XEvent") -eq $null)
		{
			throw "SMO version is too old. To collect Extended Events, you must have SQL Server Management Studio 2012 or higher installed."
		}
	}
	process {
		foreach ($instance in $SqlInstance)
		{
			Write-Verbose "Connecting to $instance."
			try
			{
				$server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $Credential -ErrorAction SilentlyContinue
				Write-Verbose "SQL Instance $instance is version $($server.versionmajor)."
			}
			catch
			{
				Write-Warning " Failed to connect to $instance."
				continue
			}
			if ($server.versionmajor -lt 11)
			{
				Write-Warning "$instance is lower than SQL Server 2012 and does not support extended events."
				continue
			}
			else
			{
				$SqlConn = $server.ConnectionContext.SqlConnectionObject
				$SqlStoreConnection = New-Object Microsoft.SqlServer.Management.Sdk.Sfc.SqlStoreConnection $SqlConn
				$XEStore = New-Object  Microsoft.SqlServer.Management.XEvent.XEStore $SqlStoreConnection
				Write-Verbose "Getting XEvents Sessions on $instance."
				
				$xesessions = $XEStore.sessions
				
				if ($Session)
				{
					$xesessions = $xesessions | Where-Object { $_.Name -in $Session }
				}
				
				try
				{
					$xesessions |
					ForEach-Object {
						[PSCustomObject]@{
							ComputerName = $server.NetName
							SQLInstance = $server.ServiceName
							Session = $_.Name
							Status = switch ($_.IsRunning) { $true { "Running" } $false { "Stopped" } }
							StartTime = $_.StartTime
							AutoStart = $_.AutoStart
							State = $_.State
							Targets = $_.Targets
							Events = $_.Events
							MaxMemory = $_.MaxMemory
							MaxEventSize = $_.MaxEventSize
						}
					}
				}
				catch
				{
					Write-Warning "Failed to get XEvents Sessions on $instance."
				}
			}
		}
	}
}
