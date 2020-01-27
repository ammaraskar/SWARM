#! /usr/bin/pwsh
Using namespace System
Using module ".\core\colors.psm1";
Using module ".\core\swarm.psm1";

## Environment
$Dir = [IO.Path]::GetDirectoryName($script:MyInvocation.MyCommand.Path)
if ($IsWindows) { $Scripts = [IO.Path]::Join($Dir, "win"); }
if ($IsLinux) { $Scripts = [IO.Path]::Join($Dir, "linux"); }
$Target1 = [EnvironmentVariableTarget]::Machine
$Target2 = [EnvironmentVariableTarget]::Process

if ($IsLinux) { $Divider = ":" }
elseif ($IsWindows) { $Divider = ";" }

## Add SWARM to PATH
$PATH = ([Environment]::GetEnvironmentVariable('PATH')).Split($Divider) | Where { $_ -ne "" } | Where { $_ -notlike "*SWARM*" }
if ($Scripts -NotIn $PATH) { $PATH += $Scripts; }
$PATH = $PATH -Join $Divider

## Set SWARM_DIR $env for both machine and this process.
## Add SWARM path.
[environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target1);
[environment]::SetEnvironmentVariable('PATH', $PATH, $Target1);

## Reset Explorer If Windows
if ($IsWindows) { Stop-Process -ProcessName explorer };
## Add files to /usr/bin so they can insta-run
if ($IsLinux) {
    $dir | Set-Content ".\linux\swarm_dir"
    $scripts = Get-ChildItem ".\linux"
    foreach($script in $scripts) {
        $destination = "/usr/bin/$($script.basename)"
        Copy-Item -Path $script.fullname -Destination $destination | Out-Null
        $proc = Start-Process -FilePath "chmod" -ArgumentList "+x $destination" -PassThru
        $proc | Wait-Process
    }
}

## Set $env for Process
[environment]::SetEnvironmentVariable('PATH', $PATH, $Target2);
[environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target2);
Set-Location $env:SWARM_DIR

[SWARM]::main($args);
