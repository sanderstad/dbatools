Describe "Add-DbaComputerCertificate Integration Tests" -Tags "Integrationtests" {
    Context "Certificate is added properly" {
        $results = Add-DbaComputerCertificate -Path C:\github\appveyor-lab\certificates\localhost.crt -Confirm:$false
        
		It "Should show the proper thumbprint has been added" {
            $results.Thumbprint | Should Be "29C469578D6C6211076A09CEE5C5797EEA0C2713"
        }
		
		It "Should be in LocalMachine\My Cert Store" {
			$results.PSParentPath | Should Be "Microsoft.PowerShell.Security\Certificate::LocalMachine\My"
        }
    }
}