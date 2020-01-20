Using namespace System
Using module ".\core\swarm.psm1";

## Environment
$Dir = [IO.Path]::GetDirectoryName($script:MyInvocation.MyCommand.Path)
if ($IsWindows) { $Scripts = [IO.Path]::Join($Dir, "win"); }
if ($IsLinux) { $Scripts = [IO.Path]::Join($Dir, "linux"); }
$Target1 = [EnvironmentVariableTarget]::Machine
$Target2 = [EnvironmentVariableTarget]::Process

if($IsLinux) { $Divider = ":"}
elseif($IsWindows { $Divider = ";"}

## Add SWARM to PATH
$PATH = ([Environment]::GetEnvironmentVariable('PATH')).Split($Divider) | Where { $_ -ne "" } | Where { $_ -notlike "*SWARM*" }
if ($Scripts -NotIn $PATH) { $PATH += $Scripts; }
$PATH = $PATH -Join $Divider

## Set SWARM_DIR $env for both machine and this process.
## Add SWARM path.
[environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target1);
[environment]::SetEnvironmentVariable('PATH', $PATH, $Target1);

## Reset Explorer If Windows
if($IsWindows) {Stop-Process -name "explorer.exe" };

## Set $env for Process
[environment]::SetEnvironmentVariable('PATH', $PATH, $Target2);
[environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target2);
Set-Location $env:SWARM_DIR

[SWARM]::main($args);
