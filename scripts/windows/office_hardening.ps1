<#
.SYNOPSIS
  Audit/apply basic Microsoft Office macro hardening settings (defensive, lab use).
.DESCRIPTION
  Checks common registry-based Office hardening controls. In -AuditOnly mode it
  reports current state. Without -AuditOnly it applies recommended values.
  Run as Administrator in an isolated Windows lab VM. Review before using broadly.
#>
[CmdletBinding()]
param(
  [switch]$AuditOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Ensure-Key {
  param([Parameter(Mandatory)][string]$Path)
  if (-not (Test-Path $Path)) {
    if ($AuditOnly) { return $false }
    New-Item -Path $Path -Force | Out-Null
  }
  return $true
}

function Set-Dword {
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][int]$Value
  )
  $exists = Test-Path $Path
  $current = $null
  if ($exists) {
    $props = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
    if ($null -ne $props -and $props.PSObject.Properties.Name -contains $Name) {
      $current = [int]$props.$Name
    }
  }
  $status = if ($null -eq $current) { 'missing' } elseif ($current -eq $Value) { 'ok' } else { "drift($current)" }
  if (-not $AuditOnly) {
    Ensure-Key -Path $Path | Out-Null
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
    $status = 'applied'
  }
  [pscustomobject]@{ Path=$Path; Name=$Name; Desired=$Value; Current=$current; Status=$status }
}

$results = @()

# Office Common security settings - versions 16.0/15.0 (Office 2016+/2013)
foreach ($ver in @('16.0','15.0')) {
  $base = "HKCU:\Software\Policies\Microsoft\Office\$ver\common\security"
  $results += Set-Dword -Path $base -Name 'blockcontentexecutionfrominternet' -Value 1
  $results += Set-Dword -Path $base -Name 'DisableAllActiveX' -Value 1
}

# VBAWarnings: 4 = disable all macros without notification (lab hardening).
# Adjust to organizational policy as needed.
foreach ($app in @('word','excel','powerpoint')) {
  foreach ($ver in @('16.0','15.0')) {
    $path = "HKCU:\Software\Policies\Microsoft\Office\$ver\$app\security"
    $results += Set-Dword -Path $path -Name 'VBAWarnings' -Value 4
    $results += Set-Dword -Path $path -Name 'blockcontentexecutionfrominternet' -Value 1
  }
}

# Protected View: 0 = enabled
foreach ($ver in @('16.0','15.0')) {
  foreach ($app in @('word','excel','powerpoint')) {
    $pv = "HKCU:\Software\Policies\Microsoft\Office\$ver\$app\security\protectedview"
    $results += Set-Dword -Path $pv -Name 'DisableInternetFilesInPV' -Value 0
    $results += Set-Dword -Path $pv -Name 'DisableUnsafeLocationsInPV' -Value 0
    $results += Set-Dword -Path $pv -Name 'DisableAttachmentsInPV' -Value 0
  }
}

$results | Format-Table -AutoSize
if ($AuditOnly) {
  Write-Host "`nAudit complete. Re-run without -AuditOnly to apply desired values." -ForegroundColor Yellow
} else {
  Write-Host "`nHardening values applied under HKCU Policies. Some environments also enforce HKLM/GPO." -ForegroundColor Green
}
