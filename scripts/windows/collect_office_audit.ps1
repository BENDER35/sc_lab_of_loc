<#
.SYNOPSIS
  Collects basic Office security-related registry values for audit/reporting.
#>
[CmdletBinding()]
param(
  [string]$Output = "$env:TEMP\office-audit.json"
)

$paths = @(
  'HKCU:\Software\Policies\Microsoft\Office\16.0\common\security',
  'HKCU:\Software\Policies\Microsoft\Office\16.0\word\security',
  'HKCU:\Software\Policies\Microsoft\Office\16.0\excel\security',
  'HKCU:\Software\Policies\Microsoft\Office\16.0\powerpoint\security'
)

$report = foreach ($p in $paths) {
  if (Test-Path $p) {
    $props = Get-ItemProperty -Path $p
    [pscustomobject]@{ Path=$p; Exists=$true; Values=$props }
  } else {
    [pscustomobject]@{ Path=$p; Exists=$false; Values=@{} }
  }
}

$report | ConvertTo-Json -Depth 6 | Set-Content -Path $Output -Encoding UTF8
Write-Host "Wrote audit report to $Output"
