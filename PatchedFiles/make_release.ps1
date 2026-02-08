# Scripts to build a onedir PyInstaller versions of the plaso tools.
# The tools are bundled into a single ZIP file.

# Note that Param must be called first.
# Usage: .\make_release.ps1 -Architecture win32
Param (
	[string]$Architecture = "amd64",
	[string]$PythonPath = ""
)

If ( $Architecture -eq "x86" )
{
	$Architecture = "win32"
}
If ( -not $PythonPath )
{
	If ( $Architecture -eq "win32" )
	{
		$PythonPath = "C:\PlasoBuild\plaso-env\Scripts"
	}
	Else
	{
		$PythonPath = "C:\PlasoBuild\plaso-env\Scripts"
	}
}

Try
{
	# -ErrorAction Stop causes Get-Command to raise a non-terminating
	# exception. A non-terminating exception will not be caught by
	# try-catch.
	$PyInstaller = (Get-Command "pyinstaller.exe" -ErrorAction Stop).Path
	$Python = ""
}
Catch
{
	$PyInstaller = "pyinstaller.exe"
}

If (-Not (Test-Path $PyInstaller))
{
	$PyInstaller = "..\pyinstaller\pyinstaller.py"

	If (-Not (Test-Path $PyInstaller))
	{
	    Write-Host "Missing PyInstaller." -foreground Red

	    Exit 1
	}
	$Python = "${PythonPath}\python.exe"

	If (-Not (Test-Path $Python))
	{
	    Write-Host "Missing Python: ${Python}." -foreground Red

	    Exit 1
	}
}

$Version = & Invoke-Expression -Command "git describe --tags --abbrev=0 2>&1"

# Build the binaries for each tool
If (Test-Path "dist")
{
    Remove-Item -Force -Recurse "dist"
}
If ( $Python -ne "" )
{
	# Note that the double quotes in the Python command are escaped by using double quotes
	$PythonVersion = & Invoke-Expression -Command "& '${Python}' -c ""from __future__ import print_function; import sys; print('{0:d}.{1:d}'.format(sys.version_info[0], sys.version_info[1]))"" "
}
Else
{
	$PythonVersion = ""
}
If ( $PythonVersion -ne "" )
{
	$PythonVersion = "-py${PythonVersion}"
}
$Arguments = "--hidden-import artifacts --onedir plaso\scripts\image_export.py"

If ( $Python -ne "" )
{
	$Output = Invoke-Expression -Command "& '${Python}' ${PyInstaller} ${Arguments} 2>&1"
}
Else
{
	$Output = Invoke-Expression -Command "${PyInstaller} ${Arguments} 2>&1"
}
If ( $LastExitCode -ne 0 ) {
    Write-Host "Error running PyInstaller for plaso\scripts\image_export.py." -foreground Red
    Write-Host ${Output} -foreground Red
    Exit 1
}
Else
{
	Write-Host ${Output}
}

$Arguments = "--hidden-import artifacts --hidden-import pysigscan --hidden-import requests --hidden-import yara --hidden-import pycreg --onedir plaso\scripts\log2timeline.py"

If ( $Python -ne "" )
{
	$Output = Invoke-Expression -Command "& '${Python}' ${PyInstaller} ${Arguments} 2>&1"
}
Else
{
	$Output = Invoke-Expression -Command "${PyInstaller} ${Arguments} 2>&1"
}
If ( $LastExitCode -ne 0 ) {
    Write-Host "Error running PyInstaller for plaso\scripts\log2timeline.py." -foreground Red
    Write-Host ${Output} -foreground Red
    Exit 1
}
Else
{
	Write-Host ${Output}
}

$Arguments = "--hidden-import artifacts --onedir plaso\scripts\pinfo.py"

If ( $Python -ne "" )
{
	$Output = Invoke-Expression -Command "& '${Python}' ${PyInstaller} ${Arguments} 2>&1"
}
Else
{
	$Output = Invoke-Expression -Command "${PyInstaller} ${Arguments} 2>&1"
}
If ( $LastExitCode -ne 0 ) {
    Write-Host "Error running PyInstaller for plaso\scripts\pinfo.py." -foreground Red
    Write-Host ${Output} -foreground Red
    Exit 1
}
Else
{
	Write-Host ${Output}
}

$Arguments = "--hidden-import artifacts --hidden-import requests --onedir plaso\scripts\psort.py"

If ( $Python -ne "" )
{
	$Output = Invoke-Expression -Command "& '${Python}' ${PyInstaller} ${Arguments} 2>&1"
}
Else
{
	$Output = Invoke-Expression -Command "${PyInstaller} ${Arguments} 2>&1"
}
If ( $LastExitCode -ne 0 ) {
    Write-Host "Error running PyInstaller for plaso\scripts\psort.py." -foreground Red
    Write-Host ${Output} -foreground Red
    Exit 1
}
Else
{
	Write-Host ${Output}
}

$Arguments = "--hidden-import artifacts --hidden-import pysigscan --hidden-import requests --hidden-import yara --onedir plaso\scripts\psteal.py"

If ( $Python -ne "" )
{
	$Output = Invoke-Expression -Command "& '${Python}' ${PyInstaller} ${Arguments} 2>&1"
}
Else
{
	$Output = Invoke-Expression -Command "${PyInstaller} ${Arguments} 2>&1"
}
If ( $LastExitCode -ne 0 ) {
    Write-Host "Error running PyInstaller for plaso\scripts\psteal.py." -foreground Red
    Write-Host ${Output} -foreground Red
    Exit 1
}
Else
{
	Write-Host ${Output}
}

# Set up distribution package path
$DistPath = "dist\plaso"

If (Test-Path "${DistPath}")
{
    Remove-Item -Force -Recurse "${DistPath}"
}
New-Item -ItemType "directory" -Path "${DistPath}"
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\data"
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\data\formatters"
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\preprocessors"
New-Item -ItemType "directory" -Path "${DistPath}\licenses"

Copy-Item -Force ACKNOWLEDGEMENTS "${DistPath}"
Copy-Item -Force AUTHORS "${DistPath}"
Copy-Item -Force LICENSE "${DistPath}"
Copy-Item -Force README.md "${DistPath}"

Copy-Item -Force -Recurse "dist\image_export\*" "${DistPath}"
Copy-Item -Force -Recurse "dist\log2timeline\*" "${DistPath}"
Copy-Item -Force -Recurse "dist\pinfo\*" "${DistPath}"
Copy-Item -Force -Recurse "dist\psort\*" "${DistPath}"
Copy-Item -Force -Recurse "dist\psteal\*" "${DistPath}"

Copy-Item -Force "plaso\data\*" "${DistPath}\_internal\plaso\data"
Copy-Item -Force "plaso\data\formatters\*" "${DistPath}\_internal\plaso\data\formatters"

Copy-Item -Force "plaso\preprocessors\*" "${DistPath}\_internal\plaso\preprocessors"

# Copy the license files of the dependencies
$Output = Invoke-Expression -Command "git.exe clone https://github.com/log2timeline/l2tdevtools dist\l2tdevtools 2>&1"

$dep = Select-String -Path dist\l2tdevtools\data\presets.ini -Pattern '^\[plaso\]$' -Context 0,5 | Select-Object -First 1
$projects = (($dep.Context.PostContext | ? { $_ -like 'projects:*' }) -replace '^projects:\s*','') -split '\s*,\s*'
$projects | ? { $_ } | % { Copy-Item -Force "dist\l2tdevtools\data\licenses\LICENSE.$_" "${DistPath}\licenses" }

# Remove debug, test and yet unused dependencies.
Remove-Item -Force ${DistPath}\licenses\LICENSE.libexe
Remove-Item -Force ${DistPath}\licenses\LICENSE.libwrc
Remove-Item -Force ${DistPath}\licenses\LICENSE.mock
Remove-Item -Force ${DistPath}\licenses\LICENSE.pbr

# Copy the artifacts yaml files
$Output = Invoke-Expression -Command "git.exe clone https://github.com/ForensicArtifacts/artifacts.git dist\artifacts 2>&1"

Push-Location "dist\artifacts"

Try
{
	$LatestTag = Invoke-Expression -Command "git.exe describe --tags $(git.exe rev-list --tags --max-count=1) 2>&1"

	$Output = Invoke-Expression -Command "git.exe checkout ${LatestTag} 2>&1"
}
Finally
{
	Pop-Location
}
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\artifacts"

Copy-Item -Force "dist\artifacts\artifacts\data\*.yaml" "${DistPath}\_internal\plaso\artifacts"

# Copy the dfVFS yaml (dtFabric definition) files
$Output = Invoke-Expression -Command "git.exe clone https://github.com/log2timeline/dfvfs.git dist\dfvfs 2>&1"

Push-Location "dist\dfvfs"

Try
{
	$LatestTag = Invoke-Expression -Command "git.exe describe --tags $(git.exe rev-list --tags --max-count=1) 2>&1"

	$Output = Invoke-Expression -Command "git.exe checkout ${LatestTag} 2>&1"
}
Finally
{
	Pop-Location
}
New-Item -ItemType "directory" -Path "${DistPath}\_internal\dfvfs\lib"

Copy-Item -Force "dist\dfvfs\dfvfs\lib\*.yaml" "${DistPath}\_internal\dfvfs\lib"

# Copy the dfWinReg yaml (dtFabric definition) files
$Output = Invoke-Expression -Command "git.exe clone https://github.com/log2timeline/dfwinreg.git dist\dfwinreg 2>&1"

Push-Location "dist\dfwinreg"

Try
{
	$LatestTag = Invoke-Expression -Command "git.exe describe --tags $(git.exe rev-list --tags --max-count=1) 2>&1"

	$Output = Invoke-Expression -Command "git.exe checkout ${LatestTag} 2>&1"
}
Finally
{
	Pop-Location
}
New-Item -ItemType "directory" -Path "${DistPath}\_internal\dfwinreg"

Copy-Item -Force "dist\dfwinreg\dfwinreg\*.yaml" "${DistPath}\_internal\dfwinreg"

# Copy the plaso yaml (dtFabric definition) files
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\parsers"
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\parsers\esedb_plugins"
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\parsers\olecf_plugins"
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\parsers\plist_plugins"
New-Item -ItemType "directory" -Path "${DistPath}\_internal\plaso\parsers\winreg_plugins"

Copy-Item -Force "plaso\parsers\*.yaml" "${DistPath}\_internal\plaso\parsers"
Copy-Item -Force "plaso\parsers\esedb_plugins\*.yaml" "${DistPath}\_internal\plaso\parsers\esedb_plugins"
Copy-Item -Force "plaso\parsers\olecf_plugins\*.yaml" "${DistPath}\_internal\plaso\parsers\olecf_plugins"
Copy-Item -Force "plaso\parsers\plist_plugins\*.yaml" "${DistPath}\_internal\plaso\parsers\plist_plugins"
Copy-Item -Force "plaso\parsers\winreg_plugins\*.yaml" "${DistPath}\_internal\plaso\parsers\winreg_plugins"

# Makes plaso-<version><python_version>-<architecture>.zip
Add-Type -assembly "system.io.compression.filesystem"
$PlasoPath = $(pwd | % Path)
[io.compression.zipfile]::CreateFromDirectory("${PlasoPath}\dist\plaso", "${PlasoPath}\plaso-${Version}${PythonVersion}-${Architecture}.zip")
