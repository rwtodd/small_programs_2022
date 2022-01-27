<#
.Synopsis
Convert the provided ZIP files to 7z files.  Put the output in the current
directory.

.Description
It uses 7z.exe for both extracting the ZIP and compressing the 7z file.

.Parameter ZipFile
The input ZIP file.  Can be on the pipeline.

.Example
gci *.zip | zipCvt.ps1
#>
param(
  [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)]
  [string]
  $ZipFile
)

begin {
  $svn = "C:\Program Files\7-Zip\7z.exe"
  $loc = Get-Location
}

process {
  if (Test-Path $ZipFile) {
    $zf = Get-Item $ZipFile
    $tdir = Join-Path $env:TEMP "zipout"
    if (Test-Path $tdir) {
       remove-item -force -recurse $tdir
    }
    mkdir $tdir

    & $svn x -y -o"$tdir" $ZipFile  *
    Push-Location $tdir
    $szname = Join-Path $loc ($zf.BaseName + ".7z")
    & $svn a -y -r -mx=7 -mmt=on -t7z $szname *
    Pop-Location
  } else {
    Write-Error "$ZipFile does not exist!"
  }
}
