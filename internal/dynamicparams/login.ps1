﻿#region Initialize Cache
if (-not [Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Cache["login"]) {
	[Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Cache["login"] = @{ }
}
#endregion Initialize Cache

#region Tepp Data return
$ScriptBlock = {
	param (
		$commandName,
		$parameterName,
		$wordToComplete,
		$commandAst,
		$fakeBoundParameter
	)
	
	$start = Get-Date
	[Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Scripts["login"].LastExecution = $start
	
	$server = $fakeBoundParameter['SqlInstance']
	
	if (-not $server) {
		$server = $fakeBoundParameter['Source']
	}
	
	if (-not $server) {
		$server = $fakeBoundParameter['ComputerName']
	}
	
	if (-not $server) { return }
	
	try {
		[DbaInstanceParameter]$parServer = $server | Select-Object -First 1
	}
	catch {
		[Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Scripts["login"].LastDuration = (Get-Date) - $start
		return
	}
	
	if ([Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Cache["login"][$parServer.FullSmoName.ToLower()]) {
		foreach ($name in ([Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Cache["login"][$parServer.FullSmoName.ToLower()] | Where-DbaObject -Like "$wordToComplete*")) {
			New-DbaTeppCompletionResult -CompletionText $name -ToolTip $name
		}
		[Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Scripts["login"].LastDuration = (Get-Date) - $start
		return
	}
	
	try {
		$serverObject = Connect-SqlInstance -SqlInstance $parServer -SqlCredential $fakeBoundParameter['SqlCredential'] -ErrorAction Stop
		foreach ($name in ([Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Cache["login"][$parServer.FullSmoName.ToLower()] | Where-DbaObject -Like "$wordToComplete*")) {
			New-DbaTeppCompletionResult -CompletionText $name -ToolTip $name
		}
		[Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Scripts["login"].LastDuration = (Get-Date) - $start
		return
	}
	catch {
		[Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Scripts["login"].LastDuration = (Get-Date) - $start
		return
	}
}

Register-DbaTeppScriptblock -ScriptBlock $ScriptBlock -Name Login
#endregion Tepp Data return

#region Update Cache
$ScriptBlock = {
	[Sqlcollective.Dbatools.TabExpansion.TabExpansionHost]::Cache["login"][$FullSmoName] = $server.Logins.Name
}
Register-DbaTeppInstanceCacheBuilder -ScriptBlock $ScriptBlock
#endregion Update Cache