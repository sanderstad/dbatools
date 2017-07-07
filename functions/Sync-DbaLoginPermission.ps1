function Sync-DbaSqlLoginPermission {
	<#
		.SYNOPSIS
			Copies SQL login permission from one server to another.

		.DESCRIPTION
			Syncs only SQL Server login permissions, roles, etc. Does not add or drop logins. If a matching login does not exist on the destination, the login will be skipped.
			Credential removal not currently supported for Syncs. TODO: Application role sync

		.PARAMETER Source
			Source SQL Server.You must have sysadmin access and server version must be SQL Server version 2000 or greater.

		.PARAMETER SourceSqlCredential
			Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:

			$scred = Get-Credential, then pass $scred object to the -SourceSqlCredential parameter.

			Windows Authentication will be used if DestinationSqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials.
			To connect as a different Windows user, run PowerShell as that user.

		.PARAMETER Destination
			Destination SQL Server. You must have sysadmin access and server version must be SQL Server version 2000 or greater.

		.PARAMETER DestinationSqlCredential
			Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:

			$dcred = Get-Credential, then pass this $dcred to the -DestinationSqlCredential parameter.

			Windows Authentication will be used if DestinationSqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials.
			To connect as a different Windows user, run PowerShell as that user.

		.PARAMETER Login
			Migrates ONLY specified logins. This list is auto-populated for tab completion. Multiple logins allowed.

		.PARAMETER ExcludeLogin
			Excludes specified logins. This list is auto-populated for tab completion.

		.PARAMETER WhatIf
			Shows what would happen if the command were to run. No actions are actually performed.

		.PARAMETER Confirm
			Prompts you for confirmation before executing any changing operations within the command.

		.PARAMETER Silent 
			Use this switch to disable any kind of verbose messages

		.NOTES
			Tags: Migration, Login
			Original Author: Chrissy LeMaire (@cl), netnerds.net
			Requires: sysadmin access on SQL Servers
			Limitations: Does not support Application Roles yet

			Website: https://dbatools.io
			Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
			License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

		.LINK
			https://dbatools.io/Sync-DbaSqlLoginPermission

		.EXAMPLE
			Sync-DbaSqlLoginPermission -Source sqlserver2014a -Destination sqlcluster

			Syncs only SQL Server login permissions, roles, etc. Does not add or drop logins or users. To copy logins and their permissions, use Copy-SqlLogin.

		.EXAMPLE
			Sync-DbaSqlLoginPermission -Source sqlserver2014a -Destination sqlcluster -Exclude realcajun -SourceSqlCredential $scred -DestinationSqlCredential $dcred

			Authenticates to SQL Servers using SQL Authentication.

			Copies all login permissions except for realcajun. If a login already exists on the destination, the permissions will not be migrated.

		.EXAMPLE
			Sync-DbaSqlLoginPermission -Source sqlserver2014a -Destination sqlcluster -Login realcajun, netnerds

			Copies permissions ONLY for logins netnerds and realcajun.
	#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[object]$Source,
		[PSCredential][System.Management.Automation.CredentialAttribute()]
		$SourceSqlCredential,
		[parameter(Mandatory = $true)]
		[object]$Destination,
		[PSCredential][System.Management.Automation.CredentialAttribute()]
		$DestinationSqlCredential,
		[object[]]$Login,
		[object[]]$ExcludeLogin,
		[switch]$Silent
	)
	begin {

		function Update-SqlPermissions {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]
				[object]$sourceserver,
				[Parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]
				[object]$sourcelogin,
				[Parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]
				[object]$destserver,
				[Parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]
				[object]$destlogin
			)

			$destination = $destserver.DomainInstanceName
			$source = $sourceserver.DomainInstanceName
			$username = $sourcelogin.name

			# Server Roles: sysadmin, bulklogin, etc
			foreach ($role in $sourceserver.roles) {
				$rolename = $role.name
				$destrole = $destserver.roles[$rolename]
				if ($destrole -ne $null) {
					try { $destrolemembers = $destrole.EnumMemberNames() }
					catch { $destrolemembers = $destrole.EnumServerRoleMembers() }
				}
				try { $rolemembers = $role.EnumMemberNames() }
				catch { $rolemembers = $role.EnumServerRoleMembers() }
				if ($rolemembers -contains $username) {
					if ($destrole -ne $null) {
						If ($Pscmdlet.ShouldProcess($destination, "Adding $username to $rolename server role")) {
							try {
								$destrole.AddMember($username)
								Write-Message -Level Verbose -Message "Added $username to $rolename server role."
							}
							catch {
								Stop-Function -Message "Failed to add $username to $rolename server role." -Target $role -ErrorRecord $_
							}
						}
					}
				}

				# Remove for Syncs
				if ($rolemembers -notcontains $username -and $destrolemembers -contains $username -and $destrole -ne $null) {
					If ($Pscmdlet.ShouldProcess($destination, "Removing $username from $rolename server role")) {
						try {
							$destrole.DropMember($username)
							Write-Message -Level Verbose -Message "Removed $username from $rolename server role on $($destserver.name)."
						}
						catch {
							Stop-Function -Message "Failed to remove $username from $rolename server role on $($destserver.name)." -Target $role -ErrorRecord $_
						}
					}
				}
			}

			$ownedjobs = $sourceserver.JobServer.Jobs | Where-Object { $_.OwnerLoginName -eq $username }
			foreach ($ownedjob in $ownedjobs) {
				if ($destserver.JobServer.Jobs[$ownedjob.name] -ne $null) {
					If ($Pscmdlet.ShouldProcess($destination, "Changing job owner to $username for $($ownedjob.name)")) {
						try {
							Write-Message -Level Verbose -Message "Changing job owner to $username for $($ownedjob.name)"
							$destownedjob = $destserver.JobServer.Jobs | Where-Object { $_.name -eq $ownedjobs.name }
							$destownedjob.set_OwnerLoginName($username)
							$destownedjob.Alter()
						}
						catch {
							Stop-Function -Message "Could not change job owner for $($ownedjob.name)" -Target $ownedJob -ErrorRecord $_
						}
					}
				}
			}

			if ($sourceserver.versionMajor -ge 9 -and $destserver.versionMajor -ge 9) {
				# These operations are only supported by SQL Server 2005 and above.
				# Securables: Connect SQL, View any database, Administer Bulk Operations, etc.

				$perms = $sourceserver.EnumServerPermissions($username)
				foreach ($perm in $perms) {
					$permstate = $perm.permissionstate
					if ($permstate -eq "GrantWithGrant") { $grantwithgrant = $true; $permstate = "grant" }
					else { $grantwithgrant = $false }
					$permset = New-Object Microsoft.SqlServer.Management.Smo.ServerPermissionSet($perm.permissiontype)
					If ($Pscmdlet.ShouldProcess($destination, "Performing $permstate on $($perm.permissiontype) for $username")) {
						try {
							$destserver.PSObject.Methods[$permstate].Invoke($permset, $username, $grantwithgrant)
							Write-Message -Level Verbose -Message "Successfully performed $permstate $($perm.permissiontype) to $username"
						}
						catch {
							Stop-Function -Message "Failed to $permstate $($perm.permissiontype) to $username" -Target $perm -ErrorRecord $_
						}
					}

					# for Syncs
					$destperms = $destserver.EnumServerPermissions($username)
					foreach ($perm in $destperms) {
						$permstate = $perm.permissionstate
						$sourceperm = $perms | Where-Object { $_.PermissionType -eq $perm.Permissiontype -and $_.PermissionState -eq $permstate }
						if ($sourceperm -eq $null) {
							If ($Pscmdlet.ShouldProcess($destination, "Performing Revoke on $($perm.permissiontype) for $username")) {
								try {
									$permset = New-Object Microsoft.SqlServer.Management.Smo.ServerPermissionSet($perm.permissiontype)
									if ($permstate -eq "GrantWithGrant") { $grantwithgrant = $true; $permstate = "grant" }
									else { $grantwithgrant = $false }
									$destserver.PSObject.Methods["Revoke"].Invoke($permset, $username, $false, $grantwithgrant)
									Write-Message -Level Verbose -Message "Successfully revoked $($perm.permissiontype) from $username"
								}
								catch {
									Stop-Function -Message "Failed to revoke $($perm.permissiontype) from $username" -Target $perm -ErrorRecord $_
								}
							}
						}
					}
				}

				# Credential mapping. Credential removal not currently supported for Syncs.
				$logincredentials = $sourceserver.credentials | Where-Object { $_.Identity -eq $sourcelogin.name }
				foreach ($credential in $logincredentials) {
					if ($destserver.Credentials[$credential.name] -eq $null) {
						If ($Pscmdlet.ShouldProcess($destination, "Adding $($credential.name) to $username")) {
							try {
								$newcred = New-Object Microsoft.SqlServer.Management.Smo.Credential($destserver, $credential.name)
								$newcred.identity = $sourcelogin.name
								$newcred.Create()
								Write-Message -Level Verbose -Message "Successfully created credential for $username"
							}
							catch {
								Stop-Function -Message "Failed to create credential for $username" -Target $credential -ErrorRecord $_
							}
						}
					}
				}
			}

			if ($destserver.versionMajor -lt 9) {
				Stop-Function -Message "Database mappings skipped when destination is SQL Server 2000" -Continue
			}

			# For Sync, if info doesn't exist in EnumDatabaseMappings, then no big deal.
			foreach ($db in $destlogin.EnumDatabaseMappings()) {
				$dbname = $db.dbname
				$destdb = $destserver.databases[$dbname]
				$sourcedb = $sourceserver.databases[$dbname]
				$dbusername = $db.username
				$dblogin = $db.loginName

				if ($sourcedb -ne $null -and $sourcedb.IsAccessible) {
					if ($sourcedb.users[$dbusername] -eq $null -and $destdb.users[$dbusername] -ne $null) {
						If ($Pscmdlet.ShouldProcess($destination, "Dropping $dbusername from $dbname on destination.")) {
							try {
								if ($destdb.schemas.owner -contains $dbusername) {
									Write-Message -Level Verbose -Message "$dbusername (login: $dblogin) in $dbname owns a schema. Drop skipped."
								}
								else {
									$destdb.users[$dbusername].Drop()
									Write-Message -Level Verbose -Message "Dropped user $dbusername (login: $dblogin) from $dbname on destination."
								}
							}
							catch {
								Stop-Function -Message "Failed to drop $dbusername ($dblogin) from $dbname on destination." -Target $db -ErrorRecord $_
							}
						}
					}

					# Remove user from role. Role removal not currently supported for Syncs.
					# TODO: reassign if dbo, application roles
					foreach ($destrole in $destdb.roles) {
						$destrolename = $destrole.name
						$sourcerole = $sourcedb.roles[$destrolename]
						if ($sourcerole -ne $null) {
							if ($sourcerole.EnumMembers() -notcontains $dbusername -and $destrole.EnumMembers() -contains $dbusername) {
								if ($dbusername -ne "dbo") {
									If ($Pscmdlet.ShouldProcess($destination, "Dropping $username from $destrolename database role on $dbname")) {
										try {
											$destrole.DropMember($dbusername)
											$destdb.Alter()
											Write-Message -Level Verbose -Message "Dropped username $dbusername (login: $dblogin) from $destrolename on $destination"
										}
										catch {
											Stop-Function -Message "Failed to remove $dbusername from $destrolename database role on $dbname." -Target $destrole -ErrorRecord $_
										}
									}
								}
							}
						}
					}

					# Remove Connect, Alter Any Assembly, etc
					$destperms = $destdb.EnumDatabasePermissions($username)
					$perms = $sourcedb.EnumDatabasePermissions($username)
					# for Syncs
					foreach ($perm in $destperms) {
						$permstate = $perm.permissionstate
						$sourceperm = $perms | Where-Object { $_.PermissionType -eq $perm.Permissiontype -and $_.PermissionState -eq $permstate }
						if ($sourceperm -eq $null) {
							If ($Pscmdlet.ShouldProcess($destination, "Performing Revoke on $($perm.permissiontype) for $username on $dbname on $destination")) {
								try {
									$permset = New-Object Microsoft.SqlServer.Management.Smo.DatabasePermissionSet($perm.permissiontype)
									if ($permstate -eq "GrantWithGrant") {
										$grantwithgrant = $true
										$permstate = "grant"
									}
									else {
										$grantwithgrant = $false
									}
									$destdb.PSObject.Methods["Revoke"].Invoke($permset, $username, $false, $grantwithgrant)
									Write-Message -Level Verbose -Message "Successfully revoked $($perm.permissiontype) from $username on $dbname on $destination"
								}
								catch {
									Stop-Function -Message "Failed to revoke $($perm.permissiontype) from $username on $dbname on $destination" -Target $perm -ErrorRecord $_
								}
							}
						}
					}
				}
			}

			# Adding database mappings and securables
			foreach ($db in $sourcelogin.EnumDatabaseMappings()) {
				$dbname = $db.dbname
				$destdb = $destserver.databases[$dbname]
				$sourcedb = $sourceserver.databases[$dbname]
				$dbusername = $db.username; $dblogin = $db.loginName

				if ($destdb -ne $null) {
					if (!$destdb.IsAccessible) {
						Write-Message -Level Verbose -Message "Database [$($destdb.Name)] is not accessible. Skipping"
						Continue
					}

					if ($destdb.users[$dbusername] -eq $null) {
						If ($Pscmdlet.ShouldProcess($destination, "Adding $dbusername to $dbname")) {
							$sql = $sourceserver.databases[$dbname].users[$dbusername].script() | Out-String
							$sql = $sql -replace [Regex]::Escape("'$source'"), "'$destination'"
							try {
								$destdb.ExecuteNonQuery($sql)
								Write-Message -Level Verbose -Message "Added user $dbusername (login: $dblogin) to $dbname"
							}
							catch {
								Stop-Function -Message "Failed to add $dbusername ($dblogin) to $dbname on $destination." -Target $db -ErrorRecord $_
							}
						}
					}

					# Db owner
					If ($sourcedb.owner -eq $username -and $destdb.owner -ne $username) {
						If ($Pscmdlet.ShouldProcess($destination, "Changing $dbname dbowner to $username")) {
							try {
								$result = Update-SqlDbOwner $sourceserver $destserver -dbname $dbname
								Write-Message -Level Verbose -Message "Changed $($destdb.name) owner to $($sourcedb.owner)."
							}
							catch {
								Stop-Function -Message "Failed to update $($destdb.name) owner to $($sourcedb.owner)." -Target $db -ErrorRecord $_
							}
						}
					}

					# Database Roles: db_owner, db_datareader, etc
					foreach ($role in $sourcedb.roles) {
						if ($role.EnumMembers() -contains $username) {
							$rolename = $role.name
							$destdbrole = $destdb.roles[$rolename]
							if ($destdbrole -ne $null -and $dbusername -ne "dbo" -and $destdbrole.EnumMembers() -notcontains $username) {
								If ($Pscmdlet.ShouldProcess($destination, "Adding $username to $rolename database role on $dbname")) {
									try {
										$destdbrole.AddMember($username)
										$destdb.Alter()
										Write-Message -Level Verbose -Message "Added $username to $rolename database role on $dbname."

									}
									catch {
										Stop-Function -Message "Failed to add $username to $rolename database role on $dbname." -Target $db -ErrorRecord $_
									}
								}
							}
						}
					}

					# Connect, Alter Any Assembly, etc
					$perms = $sourcedb.EnumDatabasePermissions($username)
					foreach ($perm in $perms) {
						$permstate = $perm.permissionstate
						if ($permstate -eq "GrantWithGrant") {
							$grantwithgrant = $true
							$permstate = "grant"
						}
						else {
							$grantwithgrant = $false
						}

						$permset = New-Object Microsoft.SqlServer.Management.Smo.DatabasePermissionSet($perm.permissiontype)
						If ($Pscmdlet.ShouldProcess($destination, "Performing $permstate on $($perm.permissiontype) for $username on $dbname")) {
							try {
								$destdb.PSObject.Methods[$permstate].Invoke($permset, $username, $grantwithgrant)
								Write-Message -Level Verbose -Message "Successfully performed $permstate $($perm.permissiontype) to $username on $dbname"
							}
							catch {
								Stop-Function -Message "Failed to perform $permstate on $($perm.permissiontype) for $username on $dbname." -Target $perm -ErrorRecord $_
							}
						}
					}
				}
			}
		}

		function Sync-Only {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]
				[object]$sourceserver,
				[object]$destserver,
				[array]$Logins,
				[array]$Exclude
			)

			$source = $sourceserver.DomainInstanceName;
			$destination = $destserver.DomainInstanceName

			try {
				$sa = ($destserver.logins | Where-Object { $_.id -eq 1 }).Name
			}
			catch {
				$sa = "sa"
			}

			foreach ($sourcelogin in $sourceserver.logins) {

				$username = $sourcelogin.name
				$currentlogin = $sourceserver.ConnectionContext.truelogin
				if ($Logins -ne $null -and $Logins -notcontains $username) { continue }
				if ($exclude -contains $username -or $username.StartsWith("##") -or $username -eq $sa) { continue }

				if ($currentlogin -eq $username) {
					Write-Message -Level Warning -Message "Sync does not modify the permissions of the current user. Skipping."
					continue
				}

				$servername = Resolve-NetBiosName $sourceserver
				$userbase = ($username.Split("\")[0]).ToLower()
				if ($servername -eq $userbase -or $username.StartsWith("NT ")) { continue }
				if (($destlogin = $destserver.Logins.Item($username)) -eq $null) { continue }

				Update-SqlPermissions -sourceserver $sourceserver -sourcelogin $sourcelogin -destserver $destserver -destlogin $destlogin
			}
		}

		if ($source -eq $destination) { throw "Source and Destination SQL Servers are the same. Quitting." }

		Write-Message -Level Verbose -Message "Attempting to connect to SQL Servers.."
		$sourceserver = Connect-SqlServer -SqlServer $Source -SqlCredential $SourceSqlCredential
		$destserver = Connect-SqlServer -SqlServer $Destination -SqlCredential $DestinationSqlCredential

		$source = $sourceserver.DomainInstanceName
		$destination = $destserver.DomainInstanceName

		if ($sourceserver.versionMajor -lt 8 -or $destserver.versionMajor -lt 8) { throw "SQL Server 7 and below not supported. Quitting." }

		if (!$Login) {
			$logins = $sourceserver.Logins.Name
		}

		if ($Pscmdlet.ShouldProcess("console", "Showing sync start message")) {
			Write-Message -Level Verbose -Message "Syncing Login Permissions"
		}
	}
	process {
		if ($pipelinevariable.Length -gt 0) {
			$Source = $pipelinevariable[0].parent.name
			$logins = $pipelinevariable.name
		}

		Sync-Only -sourceserver $sourceserver -destserver $destserver -Logins $logins -Exclude $ExcludeLogin
	}
	end {
		Test-DbaDeprecation -DeprecatedOn "1.0.0" -Silent:$false -Alias Sync-DbaSqlLoginPermission
	}
}