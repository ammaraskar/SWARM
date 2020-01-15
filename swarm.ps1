Using namespace System
Using module ".\core\swarm.psm1";

## Environment
$Dir = [IO.Path]::GetDirectoryName($script:MyInvocation.MyCommand.Path)
if ($IsWindows) { $Scripts = [IO.Path]::Join($Dir, "win"); }
if ($IsLinux) { $Scripts = [IO.Path]::Join($Dir, "linux"); }
$Target1 = [EnvironmentVariableTarget]::Machine
$Target2 = [EnvironmentVariableTarget]::Process

if ($IsLinux) {
    $PATH = ([Environment]::GetEnvironmentVariable('PATH')).Split(":") | Where { $_ -ne "" } | Where { $_ -notlike "*SWARM*" }
    if ($Scripts -NotIn $PATH) { $PATH += $Scripts; }
    $PATH = $PATH -Join ":"
}
elseif ($IsWindows) {
    $PATH = ([Environment]::GetEnvironmentVariable('PATH', $Target1)).Split(";") | Where { $_ -ne "" } | Where { $_ -notlike "*SWARM*" }
    if ($Scripts -NotIn $PATH) { $PATH += $Scripts; }
    $PATH = $PATH -Join ";";

}

## Set for both machine and this process.
[environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target1);
[environment]::SetEnvironmentVariable('SWARM_DIR', $Dir, $Target2);
[environment]::SetEnvironmentVariable('PATH', $PATH, $Target1);
[environment]::SetEnvironmentVariable('PATH', $PATH, $Target2);
Set-Location $env:SWARM_DIR

[SWARM]::main($args);