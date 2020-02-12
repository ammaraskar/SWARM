#! /usr/bin/pwsh
#Requires -RunAsAdministrator
Using namespace System
Using module "..\core\control\colors.psm1";
Using module "..\core\control\swarm.psm1";

## Environment
$Dir = Split-Path ([IO.Path]::GetDirectoryName($script:MyInvocation.MyCommand.Path))
if ($IsWindows) { $Scripts = [IO.Path]::Join($Dir, "win"); }
if ($IsLinux) { $Scripts = [IO.Path]::Join($Dir, "linux"); }
$Target1 = [EnvironmentVariableTarget]::Machine
$Target2 = [EnvironmentVariableTarget]::Process
$Reset = $false;

if ($IsLinux) { $Divider = ":" }
elseif ($IsWindows) { $Divider = ";" }

## Add SWARM to PATH
$PATH = ([Environment]::GetEnvironmentVariable('PATH')).Split($Divider)
if ($Scripts -notin $PATH) {
    Write-Host "Adding SWARM_DIR to environment variables..."
    $PATH = ([Environment]::GetEnvironmentVariable('PATH')).Split($Divider) | Where { $_ -ne "" } | Where { $_ -notlike "*SWARM*" }
    $PATH += $Scripts; 
    $PATH = $PATH -Join $Divider;
    [environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target1);
    [environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target2);
    [environment]::SetEnvironmentVariable('PATH', $PATH, $Target1);
    [environment]::SetEnvironmentVariable('PATH', $PATH, $Target2);
    $Reset = $true;
}

if ($env:CUDA_DEVICE_ORDER -ne "PCI_BUS_ID") {
    Write-Host "Setting Cuda Device Order To Match PCI bus..."
    [Environment]::SetEnvironmentVariable("CUDA_DEVICE_ORDER", "PCI_BUS_ID", $Target1)
    [Environment]::SetEnvironmentVariable("CUDA_DEVICE_ORDER", "PCI_BUS_ID", $Target2)
    $Reset = $true
}

## Reset Explorer If Windows- You can do this to reset
## Global environment variables, and re-load registry
## entries.
if ($IsWindows -and $Reset -eq $true) { Stop-Process -ProcessName explorer };

## Add files to /usr/bin so they can insta-run
if ($IsLinux) {
    $dir | Set-Content ".\linux\swarm_dir"
    $scripts = Get-ChildItem ".\linux"
    foreach ($script in $scripts) {
        $destination = "/usr/bin/$($script.basename)"
        Copy-Item -Path $script.fullname -Destination $destination | Out-Null
        $proc = Start-Process -FilePath "chmod" -ArgumentList "+x $destination" -PassThru
        $proc | Wait-Process
    }
}

## If location isn't already main dir, script won't launch.
## This is just to flag an error if there was an issue with
## Setting Path environment. I've learned .NET and linux global
## environments can have issues.
Set-Location $env:SWARM_DIR

[SWARM]::main($args);
