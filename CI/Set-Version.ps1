Import-Module $PSScriptRoot\Scripts.psm1
Import-Module $PSScriptRoot\PatchVersion.psm1

Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "false"
Set-Version

$v = Get-Version

Update-AllAssemblyInfoFiles $v ".\"