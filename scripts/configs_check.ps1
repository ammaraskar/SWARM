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
$DEFAULTS = Join-Path $env:SWARM_DIR "configs\paramters\hiveos_rig.conf"

$CONFIGS = @{ }

if(test-path($HIVEOS_CONF)){
    $CONFIGS.Add("hiveos_rig",[FileData]::StringData($HIVEOS_CONF));
}



## handle args
if($args[0] -eq "list") {
    Foreach ($key in $CONFIGS.hiveos_rig.keys) {
        $items = $Configs.hiveos_rig
        Write-Host "${Global:Yellow}$($key):${Global:NoColor}"
        foreach($value in $items.$key) {
            Write-Host "  $value"
        }
        Write-Host ""
    }
}
elseif($args[0] -eq "json") {
   return $CONFIGS | ConvertTo-Json -Depth 5 -Compress
}
elseif($args[0] -eq "swarm") {
    return $CONFIGS
}