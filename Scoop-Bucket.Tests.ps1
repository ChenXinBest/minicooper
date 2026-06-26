#Requires -Version 5.1

BeforeAll {
    $BucketName = 'minicooper'
    $BucketDir  = Join-Path $PSScriptRoot 'bucket'
    $Manifests  = Get-ChildItem -Path $BucketDir -Filter '*.json' -File
}

Describe 'Manifest JSON syntax' {
    It 'has at least one manifest' {
        $Manifests.Count | Should -BeGreaterThan 0
    }

    It '<_> parses as valid JSON' -ForEach $Manifests {
        (Get-Content -Raw $_.FullName) | ConvertFrom-Json -ErrorAction Stop | Out-Null
    }
}

Describe 'Manifest required fields' {
    BeforeAll {
        $RequiredTopLevel = @('version', 'description', 'homepage', 'license')
    }

    It '<_> has all required fields' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        foreach ($field in $RequiredTopLevel) {
            $json.PSObject.Properties.Name | Should -Contain $field -Because "manifest must declare $field"
        }
    }
}

Describe 'Manifest architecture coverage' {
    It '<_> declares both 64bit and arm64' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.architecture.PSObject.Properties.Name | Should -Contain '64bit'
        $json.architecture.PSObject.Properties.Name | Should -Contain 'arm64'
    }

    It '<_> has url and hash for both architectures' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        foreach ($arch in @('64bit', 'arm64')) {
            $json.architecture.$arch.url  | Should -Not -BeNullOrEmpty
            $json.architecture.$arch.hash | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'License is SPDX identifier' {
    It '<_> uses SPDX license id' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.license | Should -Match '^[A-Za-z0-9\-\.\+]+$'
    }
}

Describe 'checkver and autoupdate are present' {
    It '<_> has checkver field' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.PSObject.Properties.Name | Should -Contain 'checkver'
    }

    It '<_> has autoupdate field' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.PSObject.Properties.Name | Should -Contain 'autoupdate'
    }
}

Describe 'URLs are reachable' -Skip:(-not $env:RUN_URL_CHECK) {
    It '<_> <_.architecture.64bit.url> returns 200' -ForEach $Manifests {
        $url = (Get-Content -Raw $_.FullName | ConvertFrom-Json).architecture.'64bit'.url
        (Invoke-WebRequest -Uri $url -UseBasicParsing -Method Head -MaximumRedirection 5).StatusCode | Should -Be 200
    }

    It '<_> <_.architecture.arm64.url> returns 200' -ForEach $Manifests {
        $url = (Get-Content -Raw $_.FullName | ConvertFrom-Json).architecture.arm64.url
        (Invoke-WebRequest -Uri $url -UseBasicParsing -Method Head -MaximumRedirection 5).StatusCode | Should -Be 200
    }
}