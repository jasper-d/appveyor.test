Import-Module $PSScriptRoot\Scripts.psm1

$port = 11119
$iisExpressPath = "c:\program files\iis express\iisexpress.exe"
If ([environment]::Is64BitOperatingSystem) {
    $iisExpressPath = "c:\program files (x86)\iis express\iisexpress.exe"
}
$appPath = (Resolve-path .\WcfSample.Service)
$testAppPath = (Resolve-path .\IntegrationTests\bin\Release\IntegrationTests.dll)

$iisExpressSettings = @"
IIS Express:
iisExpressPath:  $iisExpressPath
port:            $port
appPath:         $appPath
testAppPath:     $testAppPath
"@

Write-BuildInfo $iisExpressSettings
Write-BuildInfo "Starting IIS Express"

Start-Process -FilePath $iisExpressPath -ArgumentList "/port:$port /path:$appPath"  -WindowStyle Hidden