Function Repair-DbaOrphanUser {
<#
.SYNOPSIS
Find orphan users with existing login and remap.

.DESCRIPTION
An orphan user is defined by a user that does not have their matching login. (Login property = "")

If the matching login exists it must be:
	Enabled
	Not a system object
	Not locked
	Have the same name that user

You can drop users that does not have their matching login by especifing the parameter -RemoveNotExisting This will be made by calling Remove-DbaOrphanUser function.


.PARAMETER SqlInstance
The SQL Server instance.

.PARAMETER SqlCredential
Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:

$scred = Get-Credential, then pass $scred object to the -SqlCredential parameter.

Windows Authentication will be used if SqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials. To connect as a different Windows user, run PowerShell as that user.

.PARAMETER Users
List of users to repair

.PARAMETER RemoveNotExisting
If passed, all users that not have their matching login will be dropped from database

.PARAMETER WhatIf
Shows what would happen if the command were to run. No actions are actually performed.

.PARAMETER Confirm
Prompts you for confirmation before executing any changing operations within the command.

.EXAMPLE
Repair-DbaOrphanUser -SqlInstance sql2005

Will find and repair all orphan users of all databases present on server 'sql2005'

.EXAMPLE
Repair-DbaOrphanUser -SqlInstance sqlserver2014a -SqlCredential $cred

Will find and repair all orphan users of all databases present on server 'sqlserver2014a'. Will be verified using SQL credentials.

.EXAMPLE
Repair-DbaOrphanUser -SqlInstance sqlserver2014a -Database db1, db2

Will find and repair all orphan users on both db1 and db2 databases

.EXAMPLE
Repair-DbaOrphanUser -SqlInstance sqlserver2014a -Database db1 -Users OrphanUser

Will find and repair user 'OrphanUser' on 'db1' database

.EXAMPLE
Repair-DbaOrphanUser -SqlInstance sqlserver2014a -Users OrphanUser

Will find and repair user 'OrphanUser' on all databases

.EXAMPLE
Repair-DbaOrphanUser -SqlInstance sqlserver2014a -RemoveNotExisting

Will find all orphan users of all databases present on server 'sqlserver2014a'
Will also remove all users that does not have their matching login by calling Remove-DbaOrphanUser function

.NOTES
Tags: Orphan
Original Author: Claudio Silva (@ClaudioESSilva)
dbatools PowerShell module (https://dbatools.io, clemaire@gmail.com)
Copyright (C) 2016 Chrissy LeMaire

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

.LINK
https://dbatools.io/Repair-DbaOrphanUser
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer")]
		[DbaInstanceParameter[]]$SqlInstance,
		[object]$SqlCredential,
		[parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[object[]]$Users,
		[switch]$RemoveNotExisting
	)

	begin {
		Write-Output "Attempting to connect to Sql Server.."
		$server = Connect-SqlInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential
	}

	process {

		if ($Database.Count -eq 0) {
			$Database = $server.Databases | Where-Object { $_.IsSystemObject -eq $false -and $_.IsAccessible -eq $true }
		}
		else {
			if ($pipedatabase.Length -gt 0) {
				$Source = $pipedatabase[0].parent.name
				$Database = $pipedatabase.name
			}
			else {
				$Database = $server.Databases | Where-Object { $_.IsSystemObject -eq $false -and $_.IsAccessible -eq $true -and ($Database -contains $_.Name) }
			}
		}

		if ($Database.Count -gt 0) {
			$start = [System.Diagnostics.Stopwatch]::StartNew()

			foreach ($db in $Database) {
				try {
					#if SQL 2012 or higher only validate databases with ContainmentType = NONE
					if ($server.versionMajor -gt 10) {
						if ($db.ContainmentType -ne [Microsoft.SqlServer.Management.Smo.ContainmentType]::None) {
							Write-Warning "Database '$db' is a contained database. Contained databases can't have orphaned users. Skipping validation."
							Continue
						}
					}

					Write-Output "Validating users on database '$db'"

					if ($Users.Count -eq 0) {
						#the third validation will remove from list sql users without login. The rule here is Sid with length higher than 16
						$Users = $db.Users | Where-Object { $_.Login -eq "" -and ($_.ID -gt 4) -and ($_.Sid.Length -gt 16 -and $_.LoginType -eq [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin) -eq $false }
					}
					else {
						if ($pipedatabase.Length -gt 0) {
							$Source = $pipedatabase[3].parent.name
							$Users = $pipedatabase.name
						}
						else {
							#the fourth validation will remove from list sql users without login. The rule here is Sid with length higher than 16
							$Users = $db.Users | Where-Object { $_.Login -eq "" -and ($_.ID -gt 4) -and ($Users -contains $_.Name) -and (($_.Sid.Length -gt 16 -and $_.LoginType -eq [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin) -eq $false) }
						}
					}

					if ($Users.Count -gt 0) {
						Write-Verbose "Orphan users found"
						$UsersToRemove = @()
						foreach ($User in $Users) {
							$ExistLogin = $server.logins | Where-Object {
								$_.Isdisabled -eq $False -and
								$_.IsSystemObject -eq $False -and
								$_.IsLocked -eq $False -and
								$_.Name -eq $User.Name
							}

							if ($ExistLogin) {
								if ($server.versionMajor -gt 8) {
									$query = "ALTER USER " + $User + " WITH LOGIN = " + $User
								}
								else {
									$query = "exec sp_change_users_login 'update_one', '$User'"
								}

								if ($Pscmdlet.ShouldProcess($db.Name, "Mapping user '$($User.Name)'")) {
									$server.Databases[$db.Name].ExecuteNonQuery($query) | Out-Null
									Write-Output "`r`nUser '$($User.Name)' mapped with their login"
								}
							}
							else {
								if ($RemoveNotExisting -eq $true) {
									#add user to collection
									$UsersToRemove += $User
								}
								else {
									Write-Warning "Orphan user $($User.Name) does not have matching login."
								}
							}
						}

						#With the colelction complete invoke remove.
						if ($RemoveNotExisting -eq $true) {
							if ($Pscmdlet.ShouldProcess($db.Name, "Remove-DbaOrphanUser")) {
								Write-Verbose "Calling 'Remove-DbaOrphanUser'"
								Remove-DbaOrphanUser -SqlInstance $sqlinstance -SqlCredential $SqlCredential -Database $db.Name -Users $UsersToRemove
							}
						}
					}
					else {
						Write-Output "No orphan users found on database '$db'"
					}
					#reset collection
					$Users = $null
				}
				catch {
					throw $_
				}
			}
		}
		else {
			Write-Output "There are no databases to analyse."
		}
	}
	end {

		$totaltime = ($start.Elapsed)
		Write-Output "Total Elapsed time: $totaltime"

		Test-DbaDeprecation -DeprecatedOn "1.0.0" -Silent:$false -Alias Repair-SqlOrphanUser
	}
}
