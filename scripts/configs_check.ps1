#! /usr/bin/pwsh
Using namespace System;
using module "..\core\control\colors.psm1";
using module "..\core\control\helper.psm1";

## Options: list json swarm
## list will print a list
## json will print condensed json
## swarm will return as object (for SWARM use)

$Args += "swarm"

Set-Location $env:SWARM_DIR

$HIVEOS_CONF = Join-Path $env:SWARM_DIR "configs\web\hiveos_rig.conf"
$H_MANIFEST = Join-Path $env:SWARM_DIR "configs\web\h-manifest.conf"
$DEFAULTS = Join-Path $env:SWARM_DIR "configs\paramters\hiveos_rig.conf"

$CONFIGS = @{ }

if(test-path($HIVEOS_CONF)){
    $CONFIGS.Add("hiveos_rig",[FileData]::StringData($HIVEOS_CONF));
}

if(test-path($H_MANIFEST)){
    $CONFIGS.Add("h_manifest",[FileData]::StringData($H_MANIFEST));
}



## handle args
if($args[0] -eq "list") {
    Write-Host "${Global:BYellow}##### HIVEOS RIG.CONF #####${Global:NoColor}"
    Foreach ($key in $CONFIGS.hiveos_rig.keys) {
        $items = $Configs.hiveos_rig
        Write-Host "${Global:BYellow}$($key):${Global:NoColor}"
        foreach($value in $items.$key) {
            Write-Host "  $value"
        }
        Write-Host ""
    }
    Write-Host "${Global:BYellow}##########${Global:NoColor}"
    Write-Host ""

    Write-Host "${Global:YELLOW}##### SWARM H-MANIFEST #####${Global:NoColor}"
    Foreach ($key in $CONFIGS.h_manifest.keys) {
        $items = $Configs.h_manifest
        Write-Host "${Global:YELLOW}$($key):${Global:NoColor}"
        foreach($value in $items.$key) {
            Write-Host "  $value"
        }
        Write-Host ""
    }
    Write-Host "${Global:YELLOW}##########${Global:NoColor}"
    Write-Host ""

}
elseif($args[0] -eq "json") {
   return $CONFIGS | ConvertTo-Json -Depth 5 -Compress
}
elseif($args[0] -eq "swarm") {
    return $CONFIGS
}