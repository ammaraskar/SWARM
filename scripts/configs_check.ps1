#! /usr/bin/pwsh
Using namespace System;
using module "..\core\control\colors.psm1";
using module "..\core\control\helper.psm1";

## Options: list json swarm
## list will print a list
## json will print condensed json
## swarm will return as object (for SWARM use)

## Brief explanation of each config:

## h-manifest- used by HiveOS and SWARM to gather details
## about SWARM as a custom miner. Also contains version

## hiveos_rig.conf - The standard rig.conf used by hiveOS

## defaults.json - This is the defaults used in SWARM.
## This file never changes, is just pulled to get parameters
## That user did not specify. It is also pulled by GUI
## to get data.

## config.json - This is the current running parameters SWARM
## is using.

Set-Location $env:SWARM_DIR

$HIVEOS_CONF = Join-Path $env:SWARM_DIR "configs\web\hiveos_rig.conf"
$H_MANIFEST = Join-Path $env:SWARM_DIR "configs\web\h-manifest.conf"
$DEFAULTS = Join-Path $env:SWARM_DIR "configs\parameters\defaults.json"
$PARAMETERS = Join-Path $env:SWARM_DIR "configs\parameters\config.json"

$CONFIGS = @{ }

if (test-path($HIVEOS_CONF)) {
    $CONFIGS.Add("hiveos_rig", [FileData]::StringData($HIVEOS_CONF));
}

if (test-path($H_MANIFEST)) {
    $CONFIGS.Add("h_manifest", [FileData]::StringData($H_MANIFEST));
}

if (test-Path($DEFAULTS)) {
    $CONFIGS.Add("defaults", @{ })
    $Get_Defaults = [IO.File]::ReadLines($DEFAULTS) | ConvertFrom-Json
    $Get_Defaults.PSObject.Properties.Name | Where { $_ -ne "example" } | ForEach-Object {
        $CONFIGS.defaults.Add($_, $Get_Defaults.$_)
    }
}

if (test-Path($PARAMETERS)) {
    $CONFIGS.Add("parameters", @{ })
    $Get_Parameters = [IO.File]::ReadLines($PARAMETERS) | ConvertFrom-Json
    $Get_Parameters.PSObject.Properties.Name | Where { $_ -ne "example" } | ForEach-Object {
        $CONFIGS.parameters.Add($_, $Get_Defaults.$_)
    }
}

## handle args
if ($args[0] -eq "list") {
    Write-Host "${Global:BYellow}#######################################${Global:NoColor}"
    Write-Host "${Global:BYellow}########### HIVEOS RIG.CONF ###########${Global:NoColor}"
    Foreach ($key in $CONFIGS.hiveos_rig.keys) {
        $items = $Configs.hiveos_rig
        Write-Host "${Global:BYellow}$($key):${Global:NoColor}"
        foreach ($value in $items.$key) {
            Write-Host "  $value"
        }
        Write-Host ""
    }
    Write-Host "${Global:BYellow}#######################################${Global:NoColor}"
    Write-Host "${Global:BYellow}#######################################${Global:NoColor}"
    Write-Host ""

    Write-Host "${Global:Green}#######################################${Global:NoColor}"
    Write-Host "${Global:Green}###########    PARAMETERS   ###########${Global:NoColor}"
    Foreach ($key in $CONFIGS.defaults.keys) {
        Write-Host "${Global:Green}$($key):${Global:NoColor}"
        foreach ($value in $Configs.defaults.$key.PSObject.Properties.Name) {
            Write-Host "  $value`:" -ForegroundColor Cyan
            foreach ($parameter in $Configs.Defaults.$key.$value) {
                Write-Host "    $parameter"
            }
        }
        Write-Host ""
    }
    Write-Host "${Global:Green}#######################################${Global:NoColor}"
    Write-Host "${Global:Green}#######################################${Global:NoColor}"
    Write-Host ""
}
elseif ($args[0] -eq "json") {
    return $CONFIGS | ConvertTo-Json -Depth 5 -Compress
}
elseif ($args[0] -eq "swarm") {
    return $CONFIGS
}