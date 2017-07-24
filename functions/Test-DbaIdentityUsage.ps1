function Test-DbaIdentityUsage {
	<# 
	.SYNOPSIS 
		Displays information relating to IDENTITY seed usage.  Works on SQL Server 2008 and above.

	.DESCRIPTION 
		IDENTITY seeds have max values based off of their data type.  This module will locate identity columns and report the seed usage.

	.PARAMETER SqlInstance
		Allows you to specify a comma separated list of servers to query.

	.PARAMETER SqlCredential
		Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:
		$cred = Get-Credential, this pass this $cred to the param. 

		Windows Authentication will be used if DestinationSqlCredential is not specified. To connect as a different Windows user, run PowerShell as that user.	

	.PARAMETER Database
		The database(s) to process - this list is auto-populated from the server. If unspecified, all databases will be processed.

	.PARAMETER ExcludeDatabase
		The database(s) to exclude - this list is auto-populated from the server

	.PARAMETER Threshold
		Allows you to specify a minimum % of the seed range being utilized.  This can be used to ignore seeds that have only utilized a small fraction of the range.

	.PARAMETER NoSystemDb
		Allows you to suppress output on system databases

	.PARAMETER Silent 
		Use this switch to disable any kind of verbose messages

	.NOTES 
		Author: Brandon Abshire, netnerds.net
		Tags: Identity

		Website: https://dbatools.io
		Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

	.LINK 
		https://dbatools.io/Test-DbaIdentityUsage

	.EXAMPLE   
		Test-DbaIdentityUsage -SqlInstance sql2008, sqlserver2012
		Check identity seeds for servers sql2008 and sqlserver2012.

	.EXAMPLE   
		Test-DbaIdentityUsage -SqlInstance sql2008 -Database TestDB
		Check identity seeds on server sql2008 for only the TestDB database

	.EXAMPLE   
		Test-DbaIdentityUsage -SqlInstance sql2008 -Database TestDB -Threshold 20
		Check identity seeds on server sql2008 for only the TestDB database, limiting results to 20% utilization of seed range or higher
	#>
	[CmdletBinding()]
	Param (
		[parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $True)]
		[Alias("ServerInstance", "SqlServer", "SqlServers")]
		[DbaInstanceParameter[]]$SqlInstance,
		[PSCredential]
		$SqlCredential,
		[Alias("Databases")]
		[object[]]$Database,
		[object[]]$ExcludeDatabase,
		[parameter(Position = 1, Mandatory = $false)]
		[int]$Threshold = 0,
		[parameter(Position = 2, Mandatory = $false)]
		[switch]$NoSystemDb,
		[switch]$Silent
	)

	BEGIN {
		
		$sql = ";WITH CTE_1
		AS
		(
		  SELECT SCHEMA_NAME(o.schema_id) AS SchemaName,
				 OBJECT_NAME(a.Object_id) as TableName,
				 a.Name as ColumnName,
				 seed_value AS SeedValue,
				 CONVERT(bigint, increment_value) as IncrementValue,

				 CONVERT(bigint, ISNULL(a.last_value, seed_value)) AS LastValue,

				 CONVERT(bigint,
								(
									CONVERT(bigint, ISNULL(last_value, seed_value)) 
									- CONVERT(bigint, seed_value) 
									+ (CASE WHEN CONVERT(bigint, seed_value) <> 0 THEN 1 ELSE 0 END) 
								)
								/
								CONVERT(bigint, increment_value)
						) AS NumberOfUses,

				 -- Divide by increment_value to shows the max number of values that can be used
				 -- E.g: smallint identity column that starts on the lower possible value (-32768) and have an increment of 2 will only accept ABS(32768 - 32767 - 1) / 2 = 32768 rows
				 CAST( 
						--ABS(
						CONVERT(bigint, seed_value) 
						- 
						Case
							When b.name = 'tinyint'   Then 255
							When b.name = 'smallint'  Then 32767
							When b.name = 'int'       Then 2147483647
							When b.name = 'bigint'    Then 9223372036854775807
						End 
						-
						-- When less than 0 the 0 counts too
						CASE 
							WHEN CONVERT(bigint, seed_value) <= 0 THEN 1
							ELSE 0
							END
						--) 
						/ CONVERT(bigint, increment_value) 
					AS Numeric(20, 0)) AS MaxNumberRows
			FROM sys.identity_columns a
				INNER JOIN sys.objects o
				   ON a.object_id = o.object_id
				INNER JOIN sys.types As b
				   ON a.system_type_id = b.system_type_id
		  WHERE a.seed_value is not null
		),
		CTE_2
		AS
		(
		SELECT SchemaName, TableName, ColumnName, CONVERT(BIGINT, SeedValue) AS SeedValue, CONVERT(BIGINT, IncrementValue) AS IncrementValue, LastValue, ABS(CONVERT(FLOAT,MaxNumberRows)) AS MaxNumberRows, NumberOfUses, 
			   CONVERT(Numeric(18,2), ((CONVERT(Float, NumberOfUses) / ABS(CONVERT(FLOAT,MaxNumberRows)) * 100))) AS [PercentUsed]
		  FROM CTE_1
		)
		SELECT DB_NAME() as DatabaseName, SchemaName, TableName, ColumnName, SeedValue, IncrementValue, LastValue, MaxNumberRows, NumberOfUses, [PercentUsed]
		  FROM CTE_2"

		if ($Threshold -gt 0) { 
			$sql += " WHERE [PercentUsed] >= " + $Threshold + " ORDER BY [PercentUsed] DESC" 
		}
		else { 
			$sql += " ORDER BY [PercentUsed] DESC" 
		}
	}

	process {
		foreach ($instance in $SqlInstance) {
			Write-Message -Level Verbose -Message "Attempting to connect to $instance"
			
			try {
				$server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential -MinimumVersion 10
			}
			catch {
				Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
			}
			
			$dbs = $server.Databases
			
			if ($Database) {
				$dbs = $dbs | Where-Object {$Database -contains $_.Name}
			}
			
			if ($ExcludeDatabase) {
				$dbs = $dbs | Where-Object Name -NotIn $ExcludeDatabase
			}
			
			if ($NoSystemDb) {
				$dbs = $dbs | Where-Object IsSystemObject -eq $false
			}
			
			foreach ($db in $dbs) {
				Write-Message -Level Verbose -Message "Processing $db on $instance"
				
				if ($db.IsAccessible -eq $false) {
					Stop-Function -Message "The database $db is not accessible. Skipping database." -Continue
				}
				
				foreach ($row in $db.ExecuteWithResults($sql).Tables[0]) {
					if ($row.PercentUsed -eq [System.DBNull]::Value) {
						continue
					}
					
					if ($row.PercentUsed -ge $threshold) {
						[PSCustomObject]@{
							ComputerName   = $server.NetName
							InstanceName   = $server.ServiceName
							SqlInstance    = $server.DomainInstanceName
							Database       = $row.DatabaseName
							Schema         = $row.SchemaName
							Table          = $row.TableName
							Column         = $row.ColumnName
							SeedValue      = $row.SeedValue
							IncrementValue = $row.IncrementValue
							LastValue      = $row.LastValue
							MaxNumberRows  = $row.MaxNumberRows
							NumberOfUses   = $row.NumberOfUses
							PercentUsed    = $row.PercentUsed
						}
					}
				}
			}
		}
	}
}

