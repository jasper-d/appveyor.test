function HashToInt32([string] $hash){
    $longHash = [Int64]::Parse($hash.Substring(0,8), [System.Globalization.NumberStyles]::HexNumber)
    if($longHash -le [Int32]::MaxValue) {
        return ($longHash -as [Int32])
    } else {
        return [Int32]::Parse($hash.Substring(0,7), [System.Globalization.NumberStyles]::HexNumber)
    }
}

function UpdateVersionFile([string] $major, [string] $minor, [string] $patch){
    $version = @{
        major = "$major"
        minor = "$minor"
        patch = "$patch"
    }

    ConvertTo-Json -InputObject $version | Out-File -FilePath ".\version.json" -Encoding utf8 
}


function SetVersion(){
    $commitHash = HashToInt32($env:APPVEYOR_REPO_COMMIT)

    if ($env:APPVEYOR_REPO_TAG -and $env:APPVEYOR_REPO_TAG_NAME -and $env:APPVEYOR_REPO_TAG_NAME -cmatch '^\s*(?:(?:v\.)|(?:v))?\s*(?<major>\d{1,9})\.(?<minor>\d{1,9})\.(?<patch>\d{1,9})\s*$') {
        Update-AppveyorBuild -Version "$($matches['major']).$($matches['minor']).$($matches['patch']).$($commitHash)"
        UpdateVersionFile $matches['major'] $matches['minor'] $matches['patch']

        Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "true"
    } else {
        $version = Get-Content -Raw -Path ".\version.json" | ConvertFrom-Json
        Update-AppveyorBuild -Version  -Version "$($version.major).$($version.minor).$($version.patch).$($commitHash)"
    }
}

Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "false"

SetVersion