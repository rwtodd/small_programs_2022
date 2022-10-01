[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true,Position=1)]
    [string]$base
)

# set up the list to transfer...
$urls = @()
$dests = @()
foreach($m in ((iwr $base).Content | sls '"[^"]*\.flac"' -AllMatches).Matches) {
    $fn = ($m.Value.Substring(1, $m.Value.Length - 2)) -replace '&amp;','&'
    $urls += ($base + '/' + $fn)
    $dests += (($fn -replace '-.*','') + '.flac')
}
$urls += ($base + '/folder.jpg')
$dests += 'cover.jpg'

# perform the transfer and wait for it
$Job = Start-BitsTransfer -Source $urls -Destination $dests -Asynchronous -DisplayName ($base -replace '.*/','')
while (($Job.JobState -eq "Transferring") -or ($Job.JobState -eq "Connecting") -or ($Job.JobState -eq "Suspended")) { 
    # Write-Output "$($Job.BytesTransferred/1MB) of $($Job.BytesTotal/1MB)"
    Start-Sleep 10
}

Switch($Job.JobState) {
    "Transferred" {}
    default { write-error "$base failure!" ; $Job | Format-List } # List the errors.
}

Complete-BitsTransfer -BitsJob $Job
