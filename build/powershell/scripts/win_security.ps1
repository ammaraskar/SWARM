$Host.UI.RawUI.BackgroundColor = 'Black'
$Host.UI.RawUI.ForegroundColor = 'White'

Start-Process "powershell" -ArgumentList "Set-Location `'$Dir`'; .\build\powershell\scripts\icon.ps1 `'$Dir\build\apps\icons\SWARM.ico`'" -NoNewWindow

try { Get-ChildItem $Dir -Recurse | Unblock-File } catch { }
## Exclusion Windows Defender
try { 
    if ((Get-MpPreference).ExclusionPath -notcontains (Convert-Path .)) { 
        ## Has to be 5.0 powershell
        Start-Process "powershell" -Verb runAs -ArgumentList "Add-MpPreference -ExclusionPath `'$Dir`'" -WindowStyle Minimized 
    } 
}
catch { }
## Set Firewall Rule
try { 
    $Net = Get-NetFireWallRule 
    if ($Net) {
        try { 
            if ( -not ( $Net | Where { $_.DisplayName -like "*swarm.ps1*" } ) ) { 
                New-NetFirewallRule -DisplayName 'swarm.ps1' -Direction Inbound -Program "$Dir\swarm.ps1" -Action Allow | Out-Null
            } 
        }
        catch { }
    }
}
catch { }
Remove-Variable -name Net -ErrorAction Ignore
