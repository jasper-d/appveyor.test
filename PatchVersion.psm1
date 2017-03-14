# SetVersion.ps1
#
# Set the version in all the AssemblyInfo.cs or AssemblyInfo.vb files in any subdirectory.
#
# usage:  
#  from cmd.exe: 
#     powershell.exe SetVersion.ps1  2.8.3.0
# 
#  from powershell.exe prompt: 
#     .\SetVersion.ps1  2.8.3.0
#
# last saved Time-stamp: <Wednesday, April 23, 2008  11:52:15  (by dinoch)>
#
# Adapted from https://blogs.msdn.microsoft.com/dotnetinterop/2008/04/21/powershell-script-to-batch-update-assemblyinfo-cs-with-new-version/


function Update-SourceVersion {
	Param ([string] $version, [string] $commitHash)
	$NewVersion = 'AssemblyVersion("' + $version + '")';
	$NewFileVersion = 'AssemblyFileVersion("' + $version + '")';
	$NewInformalVersion = 'AssemblyInformationalVersion("' + $commitHash + '")'

	foreach ($o in $input) {
	Write-output $o.FullName
	$tmpFile = $o.FullName + ".tmp"

	get-content $o.FullName | 
		%{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewVersion } |
		%{$_ -replace 'AssemblyInformationalVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewInformalVersion } |
		%{$_ -replace 'AssemblyFileVersion\("\w{32}"\)', $NewFileVersion } | Out-File $tmpFile -Encoding utf8

	 move-item $tmpFile $o.FullName -Force
  }
}


function Update-AllAssemblyInfoFiles ($version, $commitHash, $path)
{
	foreach ($file in "AssemblyInfo.cs", "AssemblyInfo.vb" ) {
		get-childitem -Recurse -Path $path |? {$_.Name -eq $file} | Update-SourceVersion $version $commitHash ;
	}
}

Export-ModuleMember -Function Update-AllAssemblyInfoFiles