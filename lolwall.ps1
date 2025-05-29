# BLOL (Block Living Off the Land)
## By NodeMixaholic
## Original by John Hammond

$lolbasURL = "https://lolbas-project.github.io/api/lolbas.json"
$lolbasData = Invoke-RestMethod $lolbasURL
$blockedPaths = @{}
$jobs = @()
$maxConcurrentJobs = 25


foreach ($entry in $lolbasData.PSObject.Properties.value){
    $name = $entry.Name
    if ($entry.Full_Path){
        foreach ($path in $entry.Full_Path) {
            if (Test-Path $path.Path -ErrorAction SilentlyContinue) {
                if (-not $existingRule) {
                    $blockedPaths[$path] = "$name"
                }
            }
        }
    }
}

foreach ($kvp in $blockedPaths.GetEnumerator()) {
    while ( @(Get-Job -State Running).Count -ge $maxConcurrentJobs) {
        Start-Sleep 1
    }
    $path = $kvp.Key
    $name = $kvp.Value
    $displayName = "BLOL - $name"
    $jobs += Start-Job -ScriptBlock {
        param($displayName, $path)
        $exists = Get-NetFirewallRule -DisplayName $displayName -ErrorAction SilentlyContinue
        if ( (not $exists) -and (not $path.Path -match "chrome.exe") -and (not $path.Path -match "AppInstaller.exe") -and (not $path.Path -match "wsl.exe") -and (not $path.Path -match "cmd.exe") -and (not $path.Path -match "update.exe")-and (not $path.Path -match "winget.exe") -and (not $path.Path -match "msedge.exe")) {
            New-NetFirewallRule -DisplayName $displayName -Direction Outbound -Action Block -Program $path.Path -Profile Any -Enabled True
            Write-Host "[+] Blocked: $path"
        } else {
            Write-Host "[!] Already Exists Or Exception Made: $path"
        }
    }
}

Write-Host "[?] Waiting for all jobs to run..."
$jobs | Wait-Job | Out-Null
$jobs | Receive-Job
$jobs | Remove-Job
