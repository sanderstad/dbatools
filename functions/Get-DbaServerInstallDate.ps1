function Get-DbaServerInstallDate {
<#
.SYNOPSIS
Returns the install date of a SQL Instance and Windows Server, depending on what is passed. 
	
.DESCRIPTION
By default, this command returns for each SQL Instance instance passed in:
SQL Instance install date, formatted as a string
Hosting Windows server install date, formatted as a string
	
.PARAMETER SqlInstance
The SQL Server that you're connecting to.

.PARAMETER SqlCredential
Credential object used to connect to the SQL Server as a different user

.PARAMETER Credential
Credential object used to connect to the SQL Server as a different user

.PARAMETER IncludeWindows
Includes the Windows Server Install date information 

.PARAMETER Silent 
Use this switch to disable any kind of verbose messages

.NOTES
Tags: CIM 
Original Author: Mitchell Hamann (@SirCaptainMitch), mitchellhamann.com
	
Website: https://dbatools.io
Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

.LINK
https://dbatools.io/Get-DbaInstallDate

.EXAMPLE
Get-DbaInstallDate -SqlInstance SqlBox1\Instance2

Returns an object with SQL Instance Install date as a string and the Windows install date as string. 

.EXAMPLE
Get-DbaInstallDate -SqlInstance winserver\sqlexpress, sql2016

Returns an object with SQL Instance Install date as a string and the Windows install date as a string for both SQLInstances that are passed to the cmdlet.  
	
.EXAMPLE   
Get-DbaInstallDate -SqlInstance sqlserver2014a, sql2016 

Returns an object with only the SQL Server Install date as a string. 

.EXAMPLE   
Get-DbaInstallDate -SqlInstance sqlserver2014a, sql2016 -IncludeWindows

Returns an object with the Windows Install date and the SQL install date as a string. 

.EXAMPLE   
Get-DbaRegisteredServerName -SqlInstance sql2014 | Get-DbaInstallDate

Returns an object with SQL Instance install date as a string for every server listed in the Central Management Server on sql2014
	
#>
	[CmdletBinding()]
	Param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer", "ComputerName")]
		[DbaInstanceParameter[]]$SqlInstance,
		[PSCredential]
		$SqlCredential,
		[PSCredential]
		$Credential,
		[Switch]$IncludeWindows,
		[switch]$Silent
	)
	
	process {
		foreach ($instance in $SqlInstance) {
			try {
				Write-Message -Level VeryVerbose -Message "Connecting to $instance" -Target $instance
				$server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential
			}
			catch {
				Stop-Function -Message "Failed to process Instance $Instance" -ErrorRecord $_ -Target $instance -Continue
			}
			
			if ($server.VersionMajor -ge 9) {
				Write-Message -Level Verbose -Message "Getting Install Date for: $instance"
				$sql = "SELECT create_date FROM sys.server_principals WHERE sid = 0x010100000000000512000000"
				[DbaDateTime]$sqlInstallDate = $server.Query($sql, 'master', $true).create_date
				
			}
			else {
				Write-Message -Level Verbose -Message "Getting Install Date for: $instance"
				$sql = "SELECT schemadate FROM sysservers"
				[DbaDateTime]$sqlInstallDate = $server.Query($sql, 'master', $true).create_date
			}
			
			$WindowsServerName = $server.ComputerNamePhysicalNetBIOS
			
			if ($IncludeWindows) {
				try {
					[DbaDateTime]$windowsInstallDate = (Get-DbaCmObject -ClassName win32_OperatingSystem -ComputerName $WindowsServerName -Credential $Credential -Silent).InstallDate
				}
				catch {
					Stop-Function -Message "Failed to connect to: $WindowsServerName" -Continue -Target $instance -ErrorRecord $_
				}
			}
			
			$object = [PSCustomObject]@{
				ComputerName = $server.NetName
				InstanceName = $server.ServiceName
				SqlInstance = $server.DomainInstanceName
				SqlInstallDate = $sqlInstallDate
				WindowsInstallDate = $windowsInstallDate
			}
			
			if ($IncludeWindows) {
				Select-DefaultView -InputObject $object -Property ComputerName, InstanceName, SqlInstance, SqlInstallDate, WindowsInstallDate
			}
			else {
				Select-DefaultView -InputObject $object -Property ComputerName, InstanceName, SqlInstance, SqlInstallDate
			}
			
		}
	}
}