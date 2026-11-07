#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('tomcat', 'embedded')]
    [string]$Mode = 'tomcat',
    [switch]$Rebuild,
    [switch]$NoBrowser
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

$JavaHome   = 'C:\Users\31529\Java\jdk-17.0.12'
$WorkspaceRoot = Split-Path (Split-Path $ProjectRoot -Parent) -Parent
$TomcatHome = Join-Path $WorkspaceRoot 'JavaWeb\apache-tomcat-11.0.27'
$Jar        = Join-Path $ProjectRoot 'target\smart-warehouse-0.0.1-SNAPSHOT.jar'
$War        = Join-Path $ProjectRoot 'target\smart-warehouse-0.0.1-SNAPSHOT.war'
$LogDir     = Join-Path $ProjectRoot 'logs'
$Port       = if ($Mode -eq 'tomcat') { 8081 } else { 8080 }
$Url        = "http://127.0.0.1:$Port/"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "==> $Text" -ForegroundColor Cyan
}

function Test-Port([string]$HostName, [int]$PortNumber) {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($HostName, $PortNumber, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(1000)) { return $false }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Wait-Http([string]$Target, [int]$TimeoutSeconds = 90) {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $resp = Invoke-WebRequest -Uri $Target -UseBasicParsing -TimeoutSec 3
            if ($resp.StatusCode -eq 200) { return $true }
        } catch {
            # 服务还没起来，继续等
        }
        Start-Sleep -Milliseconds 800
    }
    return $false
}

function Stop-Tomcat {
    Get-CimInstance Win32_Process -Filter "Name='java.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match 'catalina' -and $_.CommandLine -match 'apache-tomcat-11\.0\.27' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

function Stop-JavaOnPort([int]$PortNumber) {
    Get-NetTCPConnection -LocalPort $PortNumber -State Listen -ErrorAction SilentlyContinue |
        ForEach-Object {
            $cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($_.OwningProcess)" -ErrorAction SilentlyContinue
            if ($cim -and $cim.Name -eq 'java.exe' -and $cim.CommandLine -match 'smart-warehouse') {
                Stop-Process -Id $cim.ProcessId -Force -ErrorAction SilentlyContinue
            }
        }
}

# ---------- 1. Java ----------
$java = Join-Path $JavaHome 'bin\java.exe'
if (-not (Test-Path $java)) {
    throw "找不到 Java 17：$java"
}

# ---------- 2. MySQL ----------
Write-Step "检查 MySQL"
if (-not (Test-Port '127.0.0.1' 3306)) {
    $svc = Get-Service -Name 'MySQL80' -ErrorAction SilentlyContinue
    if (-not $svc) {
        $svc = Get-Service | Where-Object { $_.Name -match 'mysql' } | Select-Object -First 1
    }
    if ($svc -and $svc.Status -ne 'Running') {
        Write-Host "启动服务 $($svc.Name) ..."
        Start-Service $svc.Name
        $deadline = (Get-Date).AddSeconds(30)
        while ((Get-Date) -lt $deadline -and -not (Test-Port '127.0.0.1' 3306)) {
            Start-Sleep -Milliseconds 500
        }
    }
}
if (-not (Test-Port '127.0.0.1' 3306)) {
    throw "MySQL 3306 未启动，请先启动 MySQL 服务。"
}
Write-Host "MySQL 3306 OK"

# ---------- 3. 构建（源码比产物新时才构建） ----------
$needBuild = $Rebuild -or -not (Test-Path $Jar) -or -not (Test-Path $War)
if (-not $needBuild) {
    $builtAt = (Get-Item $Jar).LastWriteTime
    $changed = Get-ChildItem -Path (Join-Path $ProjectRoot 'src\main'), (Join-Path $ProjectRoot 'pom.xml') `
        -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $builtAt } |
        Select-Object -First 1
    $needBuild = $null -ne $changed
}

if ($needBuild) {
    Write-Step "构建项目（mvn -DskipTests package）"
    & mvn -B -DskipTests package
    if ($LASTEXITCODE -ne 0) {
        throw "Maven 构建失败。"
    }
} else {
    Write-Step "使用已有构建产物（加 -Rebuild 可强制重新构建）"
}

# ---------- 4. 启动 ----------
$stdout = Join-Path $LogDir 'app.log'
$stderr = Join-Path $LogDir 'app.err.log'

if ($Mode -eq 'tomcat') {
    Write-Step "部署到 Tomcat 并启动（端口 $Port）"
    Stop-Tomcat
    Start-Sleep -Milliseconds 800

    $root = Join-Path $TomcatHome 'webapps\ROOT'
    if (Test-Path $root) {
        Remove-Item $root -Recurse -Force
    }
    Copy-Item $War (Join-Path $TomcatHome 'webapps\ROOT.war') -Force

    $env:CATALINA_HOME = $TomcatHome
    $env:CATALINA_BASE = $TomcatHome
    $env:JAVA_HOME = $JavaHome
    $env:JRE_HOME = ''

    $tomcatBin = Join-Path $TomcatHome 'bin'
    Start-Process -FilePath 'cmd.exe' `
        -ArgumentList '/c', 'catalina.bat run' `
        -WorkingDirectory $tomcatBin `
        -WindowStyle Hidden `
        -RedirectStandardOutput $stdout `
        -RedirectStandardError $stderr | Out-Null
} else {
    Write-Step "启动内嵌 Tomcat（端口 $Port）"
    Stop-JavaOnPort $Port
    Start-Sleep -Milliseconds 500

    Start-Process -FilePath $java `
        -ArgumentList @('-jar', "`"$Jar`"", "--server.port=$Port") `
        -WorkingDirectory $ProjectRoot `
        -WindowStyle Hidden `
        -RedirectStandardOutput $stdout `
        -RedirectStandardError $stderr | Out-Null
}

# ---------- 5. 等健康检查 ----------
Write-Step "等待 $Url"
if (-not (Wait-Http $Url 90)) {
    Write-Host ""
    Write-Host "启动失败，日志最后 40 行：" -ForegroundColor Red
    Get-Content $stdout -Tail 40 -ErrorAction SilentlyContinue
    Get-Content $stderr -Tail 20 -ErrorAction SilentlyContinue
    exit 1
}

Write-Host ""
Write-Host "启动成功：$Url" -ForegroundColor Green
Write-Host "日志：$stdout"
Write-Host "账号：admin / 123456（管理员）、lina / 123456（中心仓库）、guest / 123456（只读）"
Write-Host "前端页面由 Spring Boot 直接托管，无需单独启动 npm。"
Write-Host "停止：.\stop.ps1"

if (-not $NoBrowser) {
    Start-Process $Url
}
