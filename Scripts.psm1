[string]$_version = $null

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

    Write-BuildInfo "Writing version file"
    Write-BuildInfo "New version is  $($major).$($minor).$($patch)"

    ConvertTo-Json -InputObject $version | Out-File -FilePath ".\version.json" -Encoding utf8 
}

function Get-Version(){
    if($Script:_version -ne $null) {
        return $Script:_version
    }

    $version = Get-Content -Raw -Path ".\version.json" | ConvertFrom-Json
    $Script:_version = "$($version.major).$($version.minor).$($version.patch).$($commitHash)"
    return $Script:_version
}

function Set-Version(){
    $commitHash = HashToInt32($env:APPVEYOR_REPO_COMMIT)
    Write-BuildInfo "Commit hash is $($env:APPVEYOR_REPO_COMMIT), truncated to Int32 as $($commitHash)"

    if ($env:APPVEYOR_REPO_TAG -and $env:APPVEYOR_REPO_TAG_NAME -and $env:APPVEYOR_REPO_TAG_NAME -cmatch '^\s*(?:(?:v\.)|(?:v))?\s*(?<major>\d{1,9})\.(?<minor>\d{1,9})\.(?<patch>\d{1,9})\s*$') {
        Write-BuildInfo "Matching repo tag found"
        Write-BuildInfo "Repo tag is $($env:APPVEYOR_REPO_TAG)"

        Update-AppveyorBuild -Version "$($matches['major']).$($matches['minor']).$($matches['patch']).$($commitHash)"
        UpdateVersionFile $matches['major'] $matches['minor'] $matches['patch']

        Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "true"
    } else {
        $version = Get-Version

        Write-BuildInfo "Read version file"
        Write-BuildInfo "Current version is $($version)"

        Update-AppveyorBuild -Version $version
    }
}

function Write-BuildError ([string] $message){
    Write-Host $message -ForegroundColor Red -BackgroundColor Black
}

function Write-BuildWarning ([string] $message){
    Write-Host $message -ForegroundColor Yellow -BackgroundColor Black
}

function Write-BuildInfo ([string] $message){
    Write-Host $message -ForegroundColor Magenta
}

Export-ModuleMember -Function Write-*
Export-ModuleMember -Function Get-Version
Export-ModuleMember -Function Set-Version