$Mod = Get-Module -ListAvailable -Name PSAvalonia
$Dir = Split-Path (Split-Path $script:MyInvocation.MyCommand.Path)
Set-Location $Dir

if($IsWindows){
Start-Process pwsh -ArgumentList "-executionpolicy Bypass -WindowStyle Hidden -command `"Set-Location C:\; Set-Location `'$Dir`'; .\gui\gui.ps1`"" -Verb RunAs
}
elseif($IsLinux) {
.\gui\gui.ps1
}