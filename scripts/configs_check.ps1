#! /usr/bin/pwsh
Using namespace System;
using module "..\core\control\colors.psm1";
using module "..\core\control\helper.psm1";

## Options: list json swarm
## list will print a list
## json will print condensed json
## swarm will return as object (for SWARM use)

Set-Location $env:SWARM_DIR

$HIVEOS_CONF = Join-Path $env:SWARM_DIR "configs\web\hiveos_rig.conf"
$H_MANIFEST = Join-Path $env:SWARM_DIR "configs\web\h-manifest.conf"
$PARAMS = Join-Path $env:SWARM_DIR "configs\parameters\parameters.json"

$CONFIGS = @{ }

if (test-path($HIVEOS_CONF)) {
    $CONFIGS.Add("hiveos_rig", [FileData]::StringData($HIVEOS_CONF));
}

if (test-path($H_MANIFEST)) {
    $CONFIGS.Add("h_manifest", [FileData]::StringData($H_MANIFEST));
}

if (test-Path($PARAMS)) {
    $CONFIGS.Add("parameters", @{ })
    $Get_Params = [IO.File]::ReadLines($PARAMS) | ConvertFrom-Json
    $Get_Params.PSObject.Properties.Name | Where { $_ -ne "example" } | ForEach-Object {
        $CONFIGS.parameters.Add($_, $Get_Params.$_)
    }
}

## handle args
if ($args[0] -eq "list") {
    Write-Host "${Global:BYellow}##### HIVEOS RIG.CONF #####${Global:NoColor}"
    Foreach ($key in $CONFIGS.hiveos_rig.keys) {
        $items = $Configs.hiveos_rig
        Write-Host "${Global:BYellow}$($key):${Global:NoColor}"
        foreach ($value in $items.$key) {
            Write-Host "  $value"
        }
        Write-Host ""
    }
    Write-Host "${Global:BYellow}##########${Global:NoColor}"
    Write-Host ""

    Write-Host "${Global:Green}##### PARAMETERS #####${Global:NoColor}"
    Foreach ($key in $CONFIGS.parameters.keys) {
        $items = $Configs.parameters
        Write-Host "${Global:Green}$($key):${Global:NoColor}"
        foreach ($value in $items.$key) {
            foreach ($parameter in $value.value) {
                Write-Host "  $parameter"
            }
        }
        Write-Host ""
    }
    Write-Host "${Global:Green}##########${Global:NoColor}"
    Write-Host ""
}
elseif ($args[0] -eq "json") {
    return $CONFIGS | ConvertTo-Json -Depth 5 -Compress
}
elseif ($args[0] -eq "swarm") {
    return $CONFIGS
}