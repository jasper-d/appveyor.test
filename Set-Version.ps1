Import-Module .\Scripts.psm1

Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "false"
Set-Version