################### LOAD DATA ###################
using module PSAvalonia

$global:Dir = Split-Path $script:MyInvocation.MyCommand.Path
Set-Location $global:Dir

function Global:Get-Avalonia($Name) { Find-AvaloniaControl -Window $global:window -Name $Name }
Set-Alias -Name Win -Value Global:Get-Avalonia -Scope Global
################### END LOAD DATA ###################

################### XAML CONVERSION ###################
$Xaml = Get-Content ".\gui\SWARM_GUI\MainWindow.xaml"
$Xaml = $Xaml | Out-String
$global:window = ConvertTo-AvaloniaWindow -Xaml $Xaml
$global:Window.Icon = ".\build\apps\icons\SWARM.ico"
################### END XAML CONVERSION ##############


################### MENU ITEMS ###################
## Handle Exit Click
$Exit = Win "Exit"
$Exit.add_Click( { $global:window.Close() })
## Start SWARM
$Start = Win "Start_Swarm"
$Stop = Win "Stop_Swarm"
$Start.add_Click( { .\startup.ps1 })
$Stop.add_Click( {
        $Miner_PID = if (test-Path ".\build\pid\miner_pid.txt") { cat ".\build\pid\miner_pid.txt" }
        $Background_PID = if (test-Path ".\build\pid\background_pid.txt") { cat ".\build\pid\background_pid.txt" }
        if ($Miner_PID) {
            $Proc = Get-Process -Id $Miner_PID -ErrorAction Ignore
            if ($Proc) { Stop-Process -Id $Proc.Id }
        }
        if ($Background_PID) {
            $Proc = Get-Process -Id $Background_PID -ErrorAction Ignore
            if ($Proc) { Stop-Process -Id $Proc.Id }
        }
    })
################### End MENU ITEMS ###################

################### PARAMETERS ###################
if (test-path ".\config\parameters\newarguments.json") { $Param = Get-Content ".\config\parameters\newarguments.json" | ConvertFrom-Json } 
else { $Param = Get-Content ".\config\parameters\default.json" | ConvertFrom-JSon }

##Type Parameters
## AMD Checkbox
$AMD = Win "AMD"; if ($Param.Type -like "*AMD*") { $AMD.IsChecked = $true }
$AMD_Click = {
    if ($AMD.IsChecked) {
        $AMD1.Foreground = "black"
        $AMD1.Background = "White"
        $AMD1.BorderBrush = "Black"
        $AMD1.IsEnabled= $true
        $AMD1.IsChecked = $true
        if ("AMD1" -notin $Param.Type) { $Param.Type += "AMD1" }
    }
    else {
      $AMD1.Foreground = "Gray"
      $AMD1.Background = "Gray"
      $AMD1.BorderBrush = "Gray"
      $AMD1.IsEnabled= $false
      $AMD1.IsChecked = $false
      $Array = @();
        $Param.Type | % { if ($_ -ne "AMD1") { $Array += $_ } }; 
        $Param.Type = $Array
    }
}
$AMD.add_Click($AMD_Click)

## AMD1 Checkbox
$AMD1 = Win "AMD1"; if ("AMD1" -in $Param.Type) { 
  $AMD1.Foreground = "black"
  $AMD1.Background = "White"
  $AMD1.BorderBrush = "Black"
  $AMD1.IsEnabled= $true
  $AMD1.IsChecked = $true
}
$AMD1_Click = {
    if ($AMD1.IsChecked) {
        if ("AMD1" -notin $Param.Type) { $Param.Type += "AMD1" }
    }
    else {
        $Array = @(); 
        $Param.Type | % { if ($_ -ne "AMD1") { $Array += $_ } }; $Param.Type = $Array
    }
}
$AMD1.add_Click($AMD1_Click)

## NVIDIA Checkbox
$NVIDIA = Win "NVIDIA"; if ($Param.Type -like "*NVIDIA*") { $NVIDIA.IsChecked = $true }
$NVIDIA_Click = {
    if ($NVIDIA.IsChecked) {

        $NVIDIA1.Foreground = "black"
        $NVIDIA2.Foreground = "black"
        $NVIDIA3.Foreground = "black"

        $NVIDIA1.Background = "White"
        $NVIDIA2.Background = "White"
        $NVIDIA3.Background = "White"

        $NVIDIA1.BorderBrush = "Black"
        $NVIDIA2.BorderBrush = "Black"
        $NVIDIA3.BorderBrush = "Black"

        $NVIDIA1.IsEnabled = $true
        $NVIDIA2.IsEnabled = $true
        $NVIDIA3.IsEnabled = $true

        $NVIDIA1.IsChecked = $true
        if ("NVIDIA1" -notin $Param.Type) { $Param.Type += "NVIDIA1" }
    }
    else {
        $NVIDIA1.Foreground = "Gray"
        $NVIDIA2.Foreground = "Gray"
        $NVIDIA3.Foreground = "Gray"

        $NVIDIA1.Background = "Gray"
        $NVIDIA2.Background = "Gray"
        $NVIDIA3.Background = "Gray"

        $NVIDIA1.BorderBrush = "Gray"
        $NVIDIA2.BorderBrush = "Gray"
        $NVIDIA3.BorderBrush = "Gray"

        $NVIDIA1.IsEnabled = $false
        $NVIDIA2.IsEnabled = $false
        $NVIDIA3.IsEnabled = $false

        $NVIDIA1.IsChecked = $false
        $NVIDIA2.IsChecked = $false
        $NVIDIA3.IsChecked = $False

        $Array = @();
        $Param.Type | % { if ($_ -ne "NVIDIA1" -and $_ -ne "NVIDIA2" -and $_ -ne "NVIDIA3") { $Array += $_ } }; 
        $Param.Type = $Array
    }
}
$NVIDIA.add_Click($NVIDIA_Click)

## NVIDIA Checkboxes
$NVIDIA1 = Win "NVIDIA1"; 
$NVIDIA2 = Win "NVIDIA2"; 
$NVIDIA3 = Win "NVIDIA3";

if ("NVIDIA1" -in $Param.Type -or "NVIDIA2" -in $Param.Type -or "NVIDIA3" -in $Param.Type) {
    $NVIDIA1.Foreground = "black"
    $NVIDIA2.Foreground = "black"
    $NVIDIA3.Foreground = "black"

    $NVIDIA1.Background = "White"
    $NVIDIA2.Background = "White"
    $NVIDIA3.Background = "White"

    $NVIDIA1.BorderBrush = "Black"
    $NVIDIA2.BorderBrush = "Black"
    $NVIDIA3.BorderBrush = "Black"

    $NVIDIA1.IsEnabled = $true
    $NVIDIA2.IsEnabled = $true
    $NVIDIA3.IsEnabled = $true

    if("NVIDIA1" -in $Param.Type){$NVIDIA1.IsChecked = $true}
    if("NVIDIA2" -in $Param.Type){$NVIDIA2.IsChecked = $true}
    if("NVIDIA3" -in $Param.Type){$NVIDIA3.IsChecked = $True}
}
$NVIDIA1_Click = {
    if ($NVIDIA1.IsChecked) {
        if ("NVIDIA1" -notin $Param.Type) { $Param.Type += "NVIDIA1" }
    }
    else {
        $Array = @(); 
        $Param.Type | % { if ($_ -ne "NVIDIA1") { $Array += $_ } }; $Param.Type = $Array
    }
}
$NVIDIA1.add_Click($NVIDIA1_Click)

$NVIDIA2_Click = {
    if ($NVIDIA2.IsChecked) {
        if ("NVIDIA2" -notin $Param.Type) { $Param.Type += "NVIDIA2" }
    }
    else {
        $Array = @(); 
        $Param.Type | % { if ($_ -ne "NVIDIA2") { $Array += $_ } }; $Param.Type = $Array
    }
}
$NVIDIA2.add_Click($NVIDIA2_Click)

$NVIDIA3_Click = {
    if ($NVIDIA3.IsChecked) {
        if ("NVIDIA3" -notin $Param.Type) { $Param.Type += "NVIDIA3" }
    }
    else {
        $Array = @(); 
        $Param.Type | % { if ($_ -ne "NVIDIA3") { $Array += $_ } }; $Param.Type = $Array
    }
}
$NVIDIA3.add_Click($NVIDIA3_Click)

## CPU Checkbox
$CPU = Win "CPU"; if ("CPU" -in $Param.Type) { $CPU.IsChecked = $true }
$CPU_Click = {
    if ($CPU.IsChecked) {
        if ("CPU" -notin $Param.Type) { $Param.Type += "CPU" }
    }
    else {
        $Array = @(); 
        $Param.Type | % { if ($_ -ne "CPU") { $Array += $_ } }; $Param.Type = $Array
    }
}
$CPU.add_Click($CPU_Click)

$ASIC = Win "ASIC"; if ("ASIC" -in $Param.Type) { $ASIC.IsChecked = $true }
$ASIC_Click = {
    if ($ASIC.IsChecked) {
        if ("ASIC" -notin $Param.Type) { $Param.Type += "ASIC" }
    }
    else {
        $Array = @(); 
        $Param.Type | % { if ($_ -ne "ASIC") { $Array += $_ } }; $Param.Type = $Array
    }
}
$ASIC.add_Click($ASIC_Click)

################### Begin GUI ###################
Show-AvaloniaWindow -Window $Window
