# BLOL (Block Living Off the Land)

A PowerShell script that automatically blocks "Living Off the Land" binaries using Windows Firewall to prevent malicious abuse of legitimate system tools.

## Overview

Living Off the Land Binaries (LOLBins) are legitimate system binaries that can be abused by attackers to perform malicious activities while avoiding detection. This script fetches the latest list from the [LOLBAS Project](https://lolbas-project.github.io/) and creates Windows Firewall rules to block outbound network connections for these binaries.

## Features

- Fetches the latest LOLBAS data automatically
- Creates Windows Firewall rules to block outbound connections
- Includes exception list for commonly used legitimate binaries
- Prevents duplicate rule creation
- Provides detailed progress and completion statistics
- Comprehensive error handling and logging

## Prerequisites

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or later
- Administrator privileges (required for firewall rule creation)
- Internet connection (to fetch LOLBAS data)

## Usage

1. **Run as Administrator** - This is required for creating firewall rules
2. Execute the script:
   ```powershell
   .\blol.ps1
   ```

The script will:
1. Download the latest LOLBAS data
2. Check for existing BLOL firewall rules
3. Identify valid binary paths on your system
4. Create firewall rules to block outbound connections
5. Provide a summary of actions taken

## Exception List

The following binaries are excluded from blocking by default (commonly used legitimate tools):
- `chrome.exe` - Google Chrome browser
- `AppInstaller.exe` - Windows App Installer
- `wsl.exe` - Windows Subsystem for Linux
- `cmd.exe` - Command Prompt
- `update.exe` - Various update utilities
- `winget.exe` - Windows Package Manager
- `msedge.exe` - Microsoft Edge browser

## Security Considerations

⚠️ **Windows Defender Alert**: This script creates multiple firewall rules in bulk, which may trigger Windows Defender or other security software alerts. This is normal behavior and not indicative of malicious activity.

⚠️ **System Impact**: Blocking these binaries may affect some legitimate software functionality. Test in a non-production environment first.

⚠️ **Administrator Access**: The script requires administrator privileges to create firewall rules. Only run from trusted sources.

## Firewall Rules

- **Rule Name Format**: `BLOL - [Binary Name]`
- **Direction**: Outbound
- **Action**: Block
- **Profile**: All (Domain, Private, Public)
- **Status**: Enabled

## Troubleshooting

### Script fails to run
- Ensure you're running as Administrator
- Check PowerShell execution policy: `Get-ExecutionPolicy`
- If needed, temporarily allow script execution: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Network connectivity issues
- Verify internet connection
- Check if corporate firewall is blocking access to `lolbas-project.github.io`
- Consider using a proxy if required

### Firewall rule conflicts
- Check for existing rules with similar names
- Use `Get-NetFirewallRule -DisplayName "BLOL - *"` to view created rules
- Remove rules if needed: `Remove-NetFirewallRule -DisplayName "BLOL - *"`

## Removing BLOL Rules

To remove all BLOL firewall rules:
```powershell
Get-NetFirewallRule -DisplayName "BLOL - *" | Remove-NetFirewallRule
```

## Contributing

This script is based on original work by John Hammond and modified by NodeMixaholic. 

- Original LOLBAS Project: https://lolbas-project.github.io/
- Report issues or suggest improvements through the appropriate channels

## Disclaimer

This tool is provided for educational and defensive security purposes. Users are responsible for testing in their environment and understanding the impact on their systems. The authors are not responsible for any system disruption or functionality loss.

## License

SPL-R5
