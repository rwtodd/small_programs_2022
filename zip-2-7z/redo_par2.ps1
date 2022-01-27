<#
.Synopsis
Redo `par2 create` in the directory if needed.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param()

$newest = Get-ChildItem -Recurse | sort-object LastWriteTime | select-object -Last 1
if ($newest.Extension -eq ".par2") {
    Write-Output "$newest is the newest file already."
} else {
    if($PSCmdlet.ShouldProcess("par2 files", "Recreate par2"))
    {
        Write-Information "Redoing par"
        Remove-Item *.par2
        & par2 create -r1 -R __p2 *.*
    }   
}
