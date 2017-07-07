﻿function Disable-DbaForceNetworkEncryption {
<#
.SYNOPSIS
Disables Force Encryption for a SQL Server instance

.DESCRIPTION
Disables Force Encryption for a SQL Server instance. Note that this requires access to the Windows Server - not the SQL instance itself.

This setting is found in Configuration Manager.

.PARAMETER SqlInstance
The target SQL Server - defaults to localhost.

.PARAMETER Credential
Allows you to login to the computer (not sql instance) using alternative Windows credentials

.PARAMETER WhatIf 
Shows what would happen if the command were to run. No actions are actually performed

.PARAMETER Confirm 
Prompts you for confirmation before executing any changing operations within the command

.PARAMETER Silent 
Use this switch to disable any kind of verbose messages

.NOTES
Tags: Certificate

Website: https://dbatools.io
Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

.EXAMPLE
Disable-DbaForceNetworkEncryption
	
Disables Force Encryption on the default (MSSQLSERVER) instance on localhost - requires (and checks for) RunAs admin.

.EXAMPLE
Disable-DbaForceNetworkEncryption -SqlInstance sql01\SQL2008R2SP2

Disables Force Network Encryption for the SQL2008R2SP2 on sql01. Uses Windows Credentials to both login and modify the registry.

.EXAMPLE
Disable-DbaForceNetworkEncryption -SqlInstance sql01\SQL2008R2SP2 -WhatIf

Shows what would happen if the command were executed.

#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
	param (
		[Alias("ServerInstance", "SqlServer", "ComputerName")]
		[DbaInstanceParameter[]]$SqlInstance = $env:COMPUTERNAME,
		[PSCredential][System.Management.Automation.CredentialAttribute()]$Credential,
		[switch]$Silent
	)
	process {
		
		foreach ($instance in $sqlinstance) {
			
			Test-RunAsAdmin -ComputerName $instance
			
			Write-Message -Level Output -Message "Resolving hostname"
			$resolved = Resolve-DbaNetworkName -ComputerName $instance -Turbo
			
			if ($null -eq $resolved) {
				Write-Message -Level Warning -Message "Can't resolve $instance"
				return
			}
			
			Write-Message -Level Output -Message "Connecting to SQL WMI on $($instance.ComputerName)"
			try {
				$sqlwmi = Invoke-ManagedComputerCommand -Server $resolved.FQDN -ScriptBlock { $wmi.Services } -Credential $Credential -ErrorAction Stop | Where-Object DisplayName -eq "SQL Server ($($instance.InstanceName))"
			}
			catch {
				Stop-Function -Message $_ -Target $sqlwmi
				return
			}
			
			$regroot = ($sqlwmi.AdvancedProperties | Where-Object Name -eq REGROOT).Value
			$vsname = ($sqlwmi.AdvancedProperties | Where-Object Name -eq VSNAME).Value
			$instancename = $sqlwmi.DisplayName.Replace('SQL Server (', '').Replace(')', '') # Don't clown, I don't know regex :(
			$serviceaccount = $sqlwmi.ServiceAccount
			
			if ([System.String]::IsNullOrEmpty($regroot)) {
				$regroot = $sqlwmi.AdvancedProperties | Where-Object { $_ -match 'REGROOT' }
				$vsname = $sqlwmi.AdvancedProperties | Where-Object { $_ -match 'VSNAME' }

				if (![System.String]::IsNullOrEmpty($regroot)) {
					$regroot = ($regroot -Split 'Value\=')[1]
					$vsname = ($vsname -Split 'Value\=')[1]
				}
				else {
					Write-Message -Level Warning -Message "Can't find instance $vsname on $env:COMPUTERNAME"
					return
				}
			}
			
			if ([System.String]::IsNullOrEmpty($vsname)) { $vsname = $instance }
			
			Write-Message -Level Output -Message "Regroot: $regroot"
			Write-Message -Level Output -Message "ServiceAcct: $serviceaccount"
			Write-Message -Level Output -Message "InstanceName: $instancename"
			Write-Message -Level Output -Message "VSNAME: $vsname"
			
			$scriptblock = {
				$regpath = "Registry::HKEY_LOCAL_MACHINE\$($args[0])\MSSQLServer\SuperSocketNetLib"
				$cert = (Get-ItemProperty -Path $regpath -Name Certificate).Certificate
				$oldvalue = (Get-ItemProperty -Path $regpath -Name ForceEncryption).ForceEncryption
				Set-ItemProperty -Path $regpath -Name ForceEncryption -Value $false
				$forceencryption = (Get-ItemProperty -Path $regpath -Name ForceEncryption).ForceEncryption
				
				[pscustomobject]@{
					ComputerName = $env:COMPUTERNAME
					InstanceName = $args[2]
					SqlInstance = $args[1]
					ForceEncryption = ($forceencryption -eq $true)
					CertificateThumbprint = $cert
				}
				
				Write-Warning "Force encryption was successfully set on $env:COMPUTERNAME for the $($args[2]) instance. You must now restart the SQL Server for changes to take effect."
			}
			
			if ($PScmdlet.ShouldProcess("local", "Connecting to $instance to modify the ForceEncryption value in $regroot for $($instance.InstanceName)")) {
				try {
					Invoke-Command2 -ComputerName $resolved.fqdn -Credential $Credential -ArgumentList $regroot, $vsname, $instancename -ScriptBlock $scriptblock -ErrorAction Stop
				}
				catch {
					Stop-Function -Message $_ -ErrorRecord $_ -Target $ComputerName -Continue
				}
			}
		}
	}
}