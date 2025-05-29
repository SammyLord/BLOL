# BLOL (Block Living Off the Land)
## By NodeMixaholic
## Original by John Hammond

Write-Host "[*] Starting BLOL - Block Living Off the Land Binaries"
Write-Host "[*] Fetching LOLBAS data..."

try {
    $lolbasURL = "https://lolbas-project.github.io/api/lolbas.json"
    $lolbasData = Invoke-RestMethod $lolbasURL -ErrorAction Stop
    Write-Host "[+] Successfully retrieved LOLBAS data"
} catch {
    Write-Error "[!] Failed to retrieve LOLBAS data: $_"
    exit 1
}

# Exception list - binaries to NOT block
$exceptions = @(
    "chrome.exe",
    "AppInstaller.exe", 
    "wsl.exe",
    "cmd.exe",
    "update.exe",
    "winget.exe",
    "msedge.exe",
    "bash.exe",
    "explorer.exe"
)

# Get existing firewall rules to avoid duplicates
Write-Host "[*] Checking existing firewall rules..."
$existingRules = @{}
try {
    $blolRules = Get-NetFirewallRule -DisplayName "BLOL - *" -ErrorAction SilentlyContinue
    foreach ($rule in $blolRules) {
        $existingRules[$rule.DisplayName] = $true
    }
    Write-Host "[+] Found $($existingRules.Count) existing BLOL rules"
} catch {
    Write-Host "[!] Error checking existing rules: $_"
}

# Process LOLBAS data and find valid paths
Write-Host "[*] Processing LOLBAS entries..."
$validPaths = @{}
$processedCount = 0

foreach ($entry in $lolbasData) {
    if (-not $entry.Name) { continue }
    
    $name = $entry.Name
    $processedCount++
    
    if ($entry.Full_Path -and $entry.Full_Path.Count -gt 0) {
        foreach ($pathObj in $entry.Full_Path) {
            if (-not $pathObj.Path) { continue }
            
            $fullPath = $pathObj.Path
            
            # Check if path exists on system
            if (Test-Path $fullPath -ErrorAction SilentlyContinue) {
                # Check if it's in our exception list
                $isException = $false
                foreach ($exception in $exceptions) {
                    if ($fullPath -match [regex]::Escape($exception)) {
                        $isException = $true
                        break
                    }
                }
                
                if (-not $isException) {
                    $ruleName = "BLOL - $name"
                    # Only add if rule doesn't already exist
                    if (-not $existingRules.ContainsKey($ruleName)) {
                        $validPaths[$fullPath] = $name
                    }
                }
            }
        }
    }
}

Write-Host "[+] Processed $processedCount LOLBAS entries"
Write-Host "[+] Found $($validPaths.Count) new paths to block"

if ($validPaths.Count -eq 0) {
    Write-Host "[!] No new paths to block. Exiting."
    exit 0
}

# Create firewall rules
Write-Host "[*] Creating firewall rules..."
$blocked = 0
$failed = 0

foreach ($pathEntry in $validPaths.GetEnumerator()) {
    $path = $pathEntry.Key
    $name = $pathEntry.Value
    $ruleName = "BLOL - $name"
    
    try {
        # Double-check rule doesn't exist (in case multiple paths use same name)
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        if ($existingRule) {
            Write-Host "[!] Rule already exists: $ruleName"
            continue
        }
        
        New-NetFirewallRule -DisplayName $ruleName -Direction Outbound -Action Block -Program $path -Profile Any -Enabled True -ErrorAction Stop
        Write-Host "[+] Blocked: $path ($name)"
        $blocked++
        
    } catch {
        Write-Host "[!] Failed to block $path ($name): $_"
        $failed++
    }
}

Write-Host ""
Write-Host "[*] BLOL Complete!"
Write-Host "[+] Successfully blocked: $blocked binaries"
if ($failed -gt 0) {
    Write-Host "[!] Failed to block: $failed binaries"
}
Write-Host "[*] Done."
