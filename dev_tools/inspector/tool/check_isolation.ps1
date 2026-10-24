$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$source = [System.IO.Path]::GetFullPath((Join-Path $projectRoot 'dev_tools'))
$projectParent = Split-Path -Parent $projectRoot
$detached = Join-Path $projectParent 'P2E-inspector-v1-detached'
if ($source -ne (Join-Path $projectRoot 'dev_tools') -or
    (Split-Path -Parent $detached) -ne $projectParent -or
    (Split-Path -Leaf $detached) -ne 'P2E-inspector-v1-detached') {
  throw 'Unsafe isolation move target'
}
if (Test-Path -LiteralPath $detached) { throw 'Isolation destination already exists' }
$dart = 'D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe'
$flutter = 'D:\Tools\flutter\bin\cache\flutter_tools.snapshot'
$logs = Join-Path $projectRoot 'build/inspector-v1.1'
$results = [System.Collections.Generic.List[object]]::new()
function Invoke-Check([string]$name, [string]$directory, [string[]]$arguments) {
  Push-Location -LiteralPath $directory
  try {
    & $dart @arguments *> (Join-Path $logs "$name.log")
    $results.Add([pscustomobject]@{ name=$name; exitCode=$LASTEXITCODE })
  } finally { Pop-Location }
}
Set-Location -LiteralPath $projectRoot
try {
  [System.IO.Directory]::Move($source, $detached)
  if (Test-Path -LiteralPath $source) { throw 'dev_tools is still present' }
  foreach ($package in @(
      @{ name='root'; path=$projectRoot },
      @{ name='package'; path=(Join-Path $projectRoot 'packages/design_system') },
      @{ name='viewer'; path=(Join-Path $projectRoot 'apps/design_system_viewer') })) {
    Invoke-Check "isolation-pub-$($package.name)" $package.path @($flutter,'pub','get')
    Invoke-Check "isolation-analyze-$($package.name)" $package.path @('analyze')
    Invoke-Check "isolation-flutter-analyze-$($package.name)" $package.path @($flutter,'analyze','--no-pub')
    Invoke-Check "isolation-tests-$($package.name)" $package.path @($flutter,'test','--reporter','expanded')
  }
  Invoke-Check 'isolation-architecture' $projectRoot @('run','tool/check_architecture.dart')
  Invoke-Check 'isolation-apk' $projectRoot @($flutter,'build','apk','--debug')
} finally {
  Set-Location -LiteralPath $projectRoot
  if (Test-Path -LiteralPath $detached) {
    if (Test-Path -LiteralPath $source) { throw 'Restore destination unexpectedly exists' }
    [System.IO.Directory]::Move($detached, $source)
  }
  $results | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $logs 'isolation-results.json')
}
if (-not (Test-Path -LiteralPath $source)) { throw 'dev_tools restore failed' }
if (@($results | Where-Object { $_.exitCode -ne 0 }).Count -gt 0) { exit 1 }
Write-Output 'All 14 deletion checks passed; dev_tools restored.'
