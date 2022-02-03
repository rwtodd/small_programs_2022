[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true,Position=1)]
    [string]$base
)

# set up the list to transfer...
foreach($m in ((iwr $base).Content | sls '"[^"]*\.flac"' -AllMatches).Matches) {
    $fn = ($m.Value.Substring(1, $m.Value.Length - 2)) -replace '&amp;','&'
    $url = ($base + '/' + $fn)
    $dest = (($fn -replace '-.*','') + '.flac')
    if(Test-Path $dest) {
        Write-Output "file exists $dest"
    } else {
       Start-BitsTransfer -Source $url -Destination $dest
    }
}
