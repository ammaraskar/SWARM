$Mod = Get-Module -ListAvailable -Name PSAvalonia
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
Set-Location $Dir

if(-not $Mod) {
    Write-Host "Installing GUI Module, please wait..."
    Install-Module PSAvalonia -Force
    Write-Host "Installed!"
}

if($IsWindows){
Start-Process pwsh -ArgumentList "-executionpolicy Bypass -WindowStyle Hidden -command `"Set-Location C:\; Set-Location `'$Dir`'; .\gui.ps1`"" -Verb RunAs
}
elseif($IsLinux) {
.\gui.ps1
}