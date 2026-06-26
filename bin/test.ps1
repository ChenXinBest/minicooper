#Requires -Version 5.1

$env:SCOOP_HOME = "$(Convert-Path '.\scoop_core')"

$testPath = Join-Path $PSScriptRoot '..' 'Scoop-Bucket.Tests.ps1'

$pesterConfig = New-PesterConfiguration -Hashtable @{
    Run    = @{
        Path     = $testPath
        PassThru = $true
    }
    Output = @{
        Verbosity = 'Detailed'
    }
}
$result = Invoke-Pester -Configuration $pesterConfig
exit $result.FailedCount