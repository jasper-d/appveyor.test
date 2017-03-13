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

    Write-Host "Writing version file" -ForegroundColor Magenta
    Write-Host "New version is  $($major).$($minor).$($patch)" -ForegroundColor Magenta

    ConvertTo-Json -InputObject $version | Out-File -FilePath ".\version.json" -Encoding utf8 
}


function SetVersion(){
    $commitHash = HashToInt32($env:APPVEYOR_REPO_COMMIT)
    Write-Host "Commit hash is $($env:APPVEYOR_REPO_COMMIT), truncated to Int32 as $($commitHash)"  -ForegroundColor Magenta

    if ($env:APPVEYOR_REPO_TAG -and $env:APPVEYOR_REPO_TAG_NAME -and $env:APPVEYOR_REPO_TAG_NAME -cmatch '^\s*(?:(?:v\.)|(?:v))?\s*(?<major>\d{1,9})\.(?<minor>\d{1,9})\.(?<patch>\d{1,9})\s*$') {
        Write-Host "Matching repo tag found"  -ForegroundColor Magenta
        Write-Host "Repo tag is $($env:APPVEYOR_REPO_TAG)"  -ForegroundColor Magenta

        Update-AppveyorBuild -Version "$($matches['major']).$($matches['minor']).$($matches['patch']).$($commitHash)"
        UpdateVersionFile $matches['major'] $matches['minor'] $matches['patch']

        Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "true"
    } else {
        $version = Get-Content -Raw -Path ".\version.json" | ConvertFrom-Json

        Write-Host "Read version file"  -ForegroundColor Magenta 
        Write-Host "Current version is $($version.major).$($version.minor).$($version.patch).$($commitHash)"  -ForegroundColor Magenta

        Update-AppveyorBuild -Version "$($version.major).$($version.minor).$($version.patch).$($commitHash)"
    }
}

Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "false"

SetVersion