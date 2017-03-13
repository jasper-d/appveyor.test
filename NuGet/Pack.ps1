$root = (split-path -parent $MyInvocation.MyCommand.Definition) + '\..'

Write-Host "Root path: $root" -ForegroundColor Magenta
Write-Host "Getting version from assembly..." -ForegroundColor Magenta

$version = [System.Reflection.Assembly]::LoadFile("$root\FooLib\bin\Release\FooLib.dll").GetName().Version

Write-Host "Version:   $version" -ForegroundColor Magenta
Write-Host "Packing NuGet packages..." -ForegroundColor Magenta
& nuget pack $root\nuget\FooLib.nuspec -Version $version -Symbols -OutputDirectory "$root\nuget\artifacts" -NonInteractive