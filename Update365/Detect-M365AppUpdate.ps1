# Intune / Configuration Manager Proactive Remediation to trigger Office Click to Run Updater (intended to run for the logged on user to show built-in update pop-up)
# Set "Run script in 64-bit PowerShell" to YES, or it will not find the correct registry key
# See Microsoft 365 Apps Version history https://learn.microsoft.com/en-us/officeupdates/update-history-microsoft365-apps-by-date#version-history

$targetVersions = @{
    'CurrentChannel'                        = [System.Version]::Parse('16.0.16227.20280')
    'MonthlyEnterpriseChannel1'             = [System.Version]::Parse('16.0.16130.20394')
    'MonthlyEnterpriseChannel2'             = [System.Version]::Parse('16.0.16026.20274')
    'Semi-AnnualEnterpriseChannel(Preview)' = [System.Version]::Parse('16.0.16130.20394')
    'Semi-AnnualEnterpriseChannel1'         = [System.Version]::Parse('16.0.15601.20626')
    'Semi-AnnualEnterpriseChannel2'         = [System.Version]::Parse('16.0.14931.20964')
}

$configuration = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration' 
$displayVersion = $null

if ( [System.Version]::TryParse($configuration.VersionToReport, $([ref]$displayVersion))) {

    Write-Output ("Discovered VersionToReport {0}" -f $displayVersion.ToString())

    $targetVersion = $targetVersions.Values | Where-Object { $_.Build -eq $displayVersion.Build } | Select-Object -Unique -First 1
    
    Write-Output ("Mapped minimum target version to {0}" -f $targetVersion.ToString())

    if ($displayVersion -lt $targetVersion) {
        Write-Output ("Current Office365 Version {0} is lower than specified target version {1}" -f $displayVersion.ToString(), $targetVersion.ToString())
        Write-Output "Triggering remediation..."
        Exit 1
    } else {
        Write-Output ("Current Office365 Version {0} matches specified target version {1}" -f $displayVersion.ToString(), $targetVersion.ToString())
        Exit 0
    }
} else {
    throw "Unable to parse VersionToReport for Office"
}