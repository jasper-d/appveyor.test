Import-Module $PSScriptRoot\..\CI\Scripts.psm1

$root = $PSScriptRoot + '\..'

Write-BuildInfo "Root path: $root"
Write-BuildInfo "Getting version from assembly..."

$version = Get-Version

Write-BuildInfo "Version:   $version"
Write-BuildInfo "Packing NuGet packages..."
& nuget pack $PSScriptRoot\FooLib.nuspec -Version $version -Symbols -OutputDirectory "$($PSScriptRoot)\artifacts" -NonInteractive