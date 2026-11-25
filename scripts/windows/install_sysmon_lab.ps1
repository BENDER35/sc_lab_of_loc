<#
.SYNOPSIS
  Installs Sysmon with the lab config (authorized lab VM only).
.NOTES
  Download Sysmon from Microsoft Sysinternals and place Sysmon64.exe next to this script,
  or adjust $SysmonExe. Review the config before installing.
#>
[CmdletBinding()]
param(
  [string]$SysmonExe = ".\Sysmon64.exe",
  [string]$Config = "..\..\detection\sysmon\sysmon-office.xml"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $SysmonExe)) { throw "Sysmon executable not found: $SysmonExe" }
if (-not (Test-Path $Config)) { throw "Config not found: $Config" }

Write-Host "Installing Sysmon with config $Config"
& $SysmonExe -accepteula -i $Config
Write-Host "Sysmon installed. Verify with: Get-Service Sysmon64" -ForegroundColor Green
