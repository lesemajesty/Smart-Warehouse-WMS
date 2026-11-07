#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('tomcat', 'embedded', 'all')]
    [string]$Mode = 'all'
)

$ErrorActionPreference = 'Stop'

function Stop-Tomcat {
    $stopped = 0
    Get-CimInstance Win32_Process -Filter "Name='java.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match 'catalina' -and $_.CommandLine -match 'apache-tomcat-11\.0\.27' } |
        ForEach-Object {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
            $stopped++
        }
    return $stopped
}

function Stop-Embedded {
    $stopped = 0
    foreach ($port in @(8080, 8081)) {
        Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue |
            ForEach-Object {
                $cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($_.OwningProcess)" -ErrorAction SilentlyContinue
                if ($cim -and $cim.Name -eq 'java.exe' -and $cim.CommandLine -match 'smart-warehouse') {
                    Stop-Process -Id $cim.ProcessId -Force -ErrorAction SilentlyContinue
                    $stopped++
                }
            }
    }
    return $stopped
}

if ($Mode -in @('tomcat', 'all')) {
    $n = Stop-Tomcat
    Write-Host "已停止 Tomcat 进程：$n"
}

if ($Mode -in @('embedded', 'all')) {
    $n = Stop-Embedded
    Write-Host "已停止内嵌应用进程：$n"
}
