#! /usr/bin/pwsh
using namespace System;
Using module "..\core\control\colors.psm1";
using module "..\core\control\helper.psm1";
using module "..\core\devices\rig.psm1";

Set-Location $env:SWARM_DIR

## options list json swarm
## list will show each item
## json will display a json of rig
## swarm will return rig object

## Make folders in case they don't exist
[startup]::make_folders();

$RIG = [SWARM_RIG]::New()

if($args[0] -eq "list") {
    $RIG.list()
}
elseif($args[0] -eq "json") {
    $RIG.hello()
}
else {
$RIG
}