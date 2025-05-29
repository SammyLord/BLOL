# BLOL (Block Living Off the Land)
## By NodeMixaholic
## Original by John Hammond

$lolbasURL = "https://lolbas-project.github.io/api/lolbas.json"
$lolbasData = Invoke-RestMethod $lolbasURL
$blockedPaths = @{}
$jobs = @()
$maxConcurrentJobs = 25

foreach ($entry in $lolbasData) {
    $name = $entry.Name
    if ($entry.Full_Path) {
        foreach ($path in $entry.Full_Path) {
            if (Test-Path $path.Path -ErrorAction SilentlyContinue) {
                # Check if firewall rule already exists
                $existingRule = Get-NetFirewallRule -DisplayName "BLOL - $name" -ErrorAction SilentlyContinue
                if (-not $existingRule) {
                    $blockedPaths[$path.Path] = $name
                }
            }
        }
    }
}

foreach ($kvp in $blockedPaths.GetEnumerator()) {
    while (@(Get-Job -State Running).Count -ge $maxConcurrentJobs) {
        Start-Sleep 1
    }
    $path = $kvp.Key
    $name = $kvp.Value
    $jobs += Start-Job -ScriptBlock {
        param($displayName, $pathToBlock)
        $exists = Get-NetFirewallRule -DisplayName "BLOL - $displayName" -ErrorAction SilentlyContinue
        if ((-not $exists) -and 
            (-not $pathToBlock -match "chrome.exe") -and 
            (-not $pathToBlock -match "AppInstaller.exe") -and 
            (-not $pathToBlock -match "wsl.exe") -and 
            (-not $pathToBlock -match "cmd.exe") -and 
            (-not $pathToBlock -match "update.exe") -and 
            (-not $pathToBlock -match "winget.exe") -and 
            (-not $pathToBlock -match "msedge.exe")) {
            New-NetFirewallRule -DisplayName "BLOL - $displayName" -Direction Outbound -Action Block -Program $pathToBlock -Profile Any -Enabled True
            Write-Host "[+] Blocked: $pathToBlock"
        } else {
            Write-Host "[!] Already Exists Or Exception Made: $pathToBlock"
        }
    } -ArgumentList $name, $path
}

Write-Host "[?] Waiting for all jobs to run..."
$jobs | Wait-Job | Out-Null
$jobs | Receive-Job
$jobs | Remove-Job
