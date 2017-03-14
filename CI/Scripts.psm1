$revision = -1
$versionObj = $null

function HashToRevision([string] $hash){
    $longHash = [Int32]::Parse($hash.Substring(0,4), [System.Globalization.NumberStyles]::HexNumber)
    #AssemblyVersionAttribute does only support revisions up to 16**2 - 2
    if($longHash -le 65534) {
        return $longHash
    } else {
        return [Int32]::Parse($hash.Substring(0,3), [System.Globalization.NumberStyles]::HexNumber)
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

function Update-Version() {
    $version = Get-Version
    UpdateVersionFile $script:versionObj.major $script:versionObj.minor ([Int32]::Parse($script:versionObj.patch) + 1).ToString()
}

function VersionToString($version){
	return "$($script:versionObj.major).$($script:versionObj.minor).$($script:versionObj.patch).$($script:revision)"
}

function Get-Version() {
	if($sciprt:versionObj -ne $null){
		return VersionToString
	}
    $script:version = Get-Content -Raw -Path ".\version.json" | ConvertFrom-Json
    return "$($script:version.major).$($script:version.minor).$($script:version.patch).$($script:revision)"
}

function Set-Version(){
    $script:revision = HashToRevision($env:APPVEYOR_REPO_COMMIT)
    Write-BuildInfo "Commit hash is $($env:APPVEYOR_REPO_COMMIT), truncated to Int32 as $($script:patch)"

    if ($env:APPVEYOR_REPO_TAG -and $env:APPVEYOR_REPO_TAG_NAME -and $env:APPVEYOR_REPO_TAG_NAME -cmatch '^\s*(?:(?:v\.)|(?:v))?\s*(?<major>\d{1,9})\.(?<minor>\d{1,9})\.(?<patch>\d{1,9})\s*$') {
        Write-BuildInfo "Matching repo tag found"
        Write-BuildInfo "Repo tag is $($env:APPVEYOR_REPO_TAG)"

        Update-AppveyorBuild -Version "$($matches['major']).$($matches['minor']).$($matches['patch']).$($script:revision)"
        UpdateVersionFile $matches['major'] $matches['minor'] $matches['patch']

        Set-AppveyorBuildVariable -Name "DeployArtifacts" -Value "true"
    } else {
        $version = Get-Version
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
Export-ModuleMember -Function Update-Version
