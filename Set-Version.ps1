Import-Module .\Scripts.psm1
Import-Module .\PatchVersion.psm1

Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "false"
Set-Version
Update-AllAssemblyInfoFiles Get-Version ".\"