Import-Module ..\Scripts.psm1

$root = (split-path -parent $MyInvocation.MyCommand.Definition) + '\..'

Write-BuildInfo "Root path: $root"
Write-BuildInfo "Getting version from assembly..."

$version = Get-Version

Write-BuildInfo "Version:   $version"
Write-BuildInfo "Packing NuGet packages..."
& nuget pack $root\nuget\FooLib.nuspec -Version $version -Symbols -OutputDirectory "$root\nuget\artifacts" -NonInteractive