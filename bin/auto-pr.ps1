#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'BuildHelpers'; ModuleVersion = '2.0.1' }
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }

[CmdletBinding()]
param(
    [switch]$Push
)

$ErrorActionPreference = 'Stop'

$env:SCOOP_HOME = "$(Convert-Path '.\scoop_core')"
$ExcavatorModule = Join-Path $PSScriptRoot '..\excavator\Excavator.psm1'
Import-Module $ExcavatorModule -Force

$repo = $env:SCOOP_BUCKET_REPO
if (-not $repo) {
    throw "SCOOP_BUCKET_REPO env var is required"
}

$token = $env:GH_TOKEN
if (-not $token) {
    throw "GH_TOKEN env var is required"
}

$dir = Resolve-Path "$PSScriptRoot\.."
$manifests = Get-ChildItem -Path "$dir\bucket" -Filter '*.json' -File

foreach ($manifest in $manifests) {
    Write-Host "Checking $($manifest.Name)..."
    try {
        $update = Invoke-BucketUpdate -ManifestPath $manifest.FullName -Outdated -ErrorAction Stop
        if ($update) {
            Write-Host "Update available for $($manifest.Name)"
            if ($Push) {
                $branch = "auto/$([System.IO.Path]::GetFileNameWithoutExtension($manifest.Name))-$($update.Version)"
                $title = "[$([System.IO.Path]::GetFileNameWithoutExtension($manifest.Name))] Update to $($update.Version)"
                $body = "Auto-updated by Excavator.`n`nDiff: https://github.com/$repo/compare/master...$branch"

                git config user.name "github-actions[bot]"
                git config user.email "github-actions[bot]@users.noreply.github.com"
                git checkout -B $branch
                git add $manifest.FullName
                git commit -m $title
                git push origin $branch --force

                $prPayload = @{
                    title = $title
                    head  = $branch
                    base  = "master"
                    body  = $body
                } | ConvertTo-Json

                $headers = @{
                    Authorization = "Bearer $token"
                    Accept        = "application/vnd.github+json"
                }
                Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$repo/pulls" -Headers $headers -Body $prPayload -ContentType 'application/json'
            }
        }
    } catch {
        Write-Warning "Failed to update $($manifest.Name): $_"
    }
}