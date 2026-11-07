# 打包并部署到外部 Tomcat 11（ROOT 上下文，端口 8081）
# 用法：在项目根目录执行  .\deploy-tomcat.ps1
$ErrorActionPreference = "Stop"

$project = $PSScriptRoot
$tomcat  = Join-Path $project "..\..\JavaWeb\apache-tomcat-11.0.27"
if (-not (Test-Path $tomcat)) {
    throw "找不到 Tomcat：$tomcat（需要 11.x，Servlet 6.1）"
}

Push-Location $project
try {
    & mvn -B -DskipTests package
    if ($LASTEXITCODE -ne 0) { throw "Maven 打包失败" }

    $war = Get-ChildItem "target\*.war" | Select-Object -First 1
    if (-not $war) { throw "未找到 target 下的 WAR" }

    $target = Join-Path $tomcat "webapps\ROOT.war"
    Copy-Item $war.FullName $target -Force
    Write-Host "已部署: $($war.Name) -> $target"
    Write-Host "启动: `$env:CATALINA_HOME='$tomcat'; `$env:JAVA_HOME='C:\Users\31529\Java\jdk-17.0.12'; & '$tomcat\bin\startup.bat'"
    Write-Host "访问: http://127.0.0.1:8081/"
}
finally {
    Pop-Location
}
