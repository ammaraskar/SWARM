$Debug = $true
$global:Config = [hashtable]::Synchronized(@{})
$global:Config.ADD("Dir",(Split-Path (Split-Path $script:MyInvocation.MyCommand.Path)))
Set-Location $global:config.Dir

$Script = {
Set-Location $global:config.Dir
Import-Module ".\gui\PSAvalonia\1.0\PSAvalonia.psd1"
Import-Module ".\build\powershell\global\hashrates.psm1"
if(test-path (".\build\txt\json_stats.txt")){Remove-Item ".\build\txt\json_stats.txt"}

## LOAD DATA
function Global:Get-Avalonia($Name) { Find-AvaloniaControl -Window $Config.window -Name $Name }
Set-Alias -Name Win -Value Global:Get-Avalonia -Scope Global

## XAML CONVERSION
$Xaml = Get-Content ".\gui\MainWindow.xaml"
$Xaml = $Xaml | Out-String
$global:Config.Add("window",(convertTo-AvaloniaWindow -Xaml $Xaml))
if($IsWindows){$Config.Window.Icon = ".\build\apps\icons\SWARM.ico"}

## Load View Models
. .\gui\build\viewmodelbase.ps1

$config.Window.DataContext = $MainWindowViewModel

## PARAMETERS 
if (test-path ".\config\parameters\newarguments.json") { $Config.Add("Param",(Get-Content ".\config\parameters\newarguments.json" | ConvertFrom-Json)) } 
else { $Config.Add("Param",(Get-Content ".\config\parameters\default.json" | ConvertFrom-Json)) }

## Menu Items
. .\gui\build\menu.ps1

###########################
## Tab1 - Basic Settings ##
###########################
$Tab1 = Win "Tab1_Main"

## Wallets
. .\gui\build\wallets.ps1

## Location
. .\gui\build\location.ps1

## RigName
. .\gui\build\rigname.ps1

## Pools
. .\gui\build\pools.ps1

## Data_Feed
. .\gui\build\datafeed.ps1


## NVIDIA Checkboxes##Type Parameters
## AMD Checkbox

$AMD = Win "AMD";
$AMD1 = Win "AMD1"; 

$NVIDIA = Win "NVIDIA"; 
$NVIDIA1 = Win "NVIDIA1"; 
$NVIDIA2 = Win "NVIDIA2"; 
$NVIDIA3 = Win "NVIDIA3";
$CPU = Win "CPU"; 
$ASIC = Win "ASIC"; 
$Rig_Settings = Win "Grid_1_Rig_Settings"
$UpDown = [Avalonia.Controls.NumericUpDown]::New()
$UpDown.Maximum = 10
$UpDown.Minimum = 0
$UpDown.Margin = "-830,0,0,0"
$UpDown.MaxWidth = 40
$UpDown.MaxHeight = 35
$Rig_Settings.Children.Add($UpDown)
$Grid = [Avalonia.Controls.Grid]::SetRow($UpDown,1)
$Grid = [Avalonia.Controls.Grid]::SetColumn($UpDown,4)
$Thread_Title = win "Thread_Title"

## NVIDIA Checkbox
$Auto_Detect = Win "Auto_Detect"

if([string]$Config.param.Type -eq "") {
    $NVIDIA.Foreground = "Gray"
    $NVIDIA1.Foreground = "Gray"
    $NVIDIA2.Foreground = "Gray"
    $NVIDIA3.Foreground = "Gray"
    $AMD.Foreground = "Gray"
    $AMD1.Foreground = "Gray"
    $CPU.Foreground = "Gray"
    $ASIC.Foreground = "Gray"
    $UpDown.Foreground = "Gray"
    $Thread_Title.Foreground = "Gray"

    $NVIDIA.Background = "Gray"
    $NVIDIA1.Background = "Gray"
    $NVIDIA2.Background = "Gray"
    $NVIDIA3.Background = "Gray"
    $AMD.Background = "Gray"
    $AMD1.Background = "Gray"
    $CPU.Background = "Gray"
    $ASIC.Background = "Gray"
    $UpDown.Foreground = "Gray"

    $NVIDIA.BorderBrush = "Gray"
    $NVIDIA1.BorderBrush = "Gray"
    $NVIDIA2.BorderBrush = "Gray"
    $NVIDIA3.BorderBrush = "Gray"
    $AMD.BorderBrush = "Gray"
    $AMD1.BorderBrush = "Gray"
    $CPU.BorderBrush = "Gray"
    $ASIC.BorderBrush = "Gray"
    $UpDown.Foreground = "Gray"

    $NVIDIA.IsEnabled = $False
    $NVIDIA1.IsEnabled = $false
    $NVIDIA2.IsEnabled = $false
    $NVIDIA3.IsEnabled = $false
    $AMD.IsEnabled = $false
    $AMD1.IsEnabled = $false
    $CPU.IsEnabled = $false
    $ASIC.IsEnabled = $false
    $UpDown.IsEnabled = $False

    $NVIDIA.IsChecked = $false
    $NVIDIA1.IsChecked = $false
    $NVIDIA2.IsChecked = $false
    $NVIDIA3.IsChecked = $False
    $AMD.IsChecked = $false
    $AMD1.IsChecked = $false
    $CPU.IsChecked = $false
    $ASIC.IsChecked = $false
    $Auto_Detect.IsChecked = $true
    $Auto_Detect.IsEnabled = $true
}

$Auto_Detect_Click = {
    if($Auto_Detect.IsChecked){
        $NVIDIA.Foreground = "Gray"
        $NVIDIA1.Foreground = "Gray"
        $NVIDIA2.Foreground = "Gray"
        $NVIDIA3.Foreground = "Gray"
        $AMD.Foreground = "Gray"
        $AMD1.Foreground = "Gray"
        $CPU.Foreground = "Gray"
        $ASIC.Foreground = "Gray"
        $UpDown.Foreground = "Gray"
        $Thread_Title.Foreground = "Gray"
    
        $NVIDIA.Background = "Gray"
        $NVIDIA1.Background = "Gray"
        $NVIDIA2.Background = "Gray"
        $NVIDIA3.Background = "Gray"
        $AMD.Background = "Gray"
        $AMD1.Background = "Gray"
        $CPU.Background = "Gray"
        $ASIC.Background = "Gray"
        $UpDown.Background = "Gray"
    
        $NVIDIA.BorderBrush = "Gray"
        $NVIDIA1.BorderBrush = "Gray"
        $NVIDIA2.BorderBrush = "Gray"
        $NVIDIA3.BorderBrush = "Gray"
        $AMD.BorderBrush = "Gray"
        $AMD1.BorderBrush = "Gray"
        $CPU.BorderBrush = "Gray"
        $ASIC.BorderBrush = "Gray"
    
        $NVIDIA.IsEnabled = $false
        $NVIDIA1.IsEnabled = $false
        $NVIDIA2.IsEnabled = $false
        $NVIDIA3.IsEnabled = $false
        $AMD.IsEnabled = $false
        $AMD1.IsEnabled = $false
        $CPU.IsEnabled = $false
        $ASIC.IsEnabled = $false
        $UpDown.IsEnabled = $False
    
        $NVIDIA.IsChecked = $false
        $NVIDIA1.IsChecked = $false
        $NVIDIA2.IsChecked = $false
        $NVIDIA3.IsChecked = $False
        $AMD.IsChecked = $false
        $AMD1.IsChecked = $false
        $CPU.IsChecked = $false
        $ASIC.IsChecked = $false

        $Config.param.Type = @()
    } else {
        $NVIDIA.Foreground = "black"
        $NVIDIA1.Foreground = "black"
        $NVIDIA2.Foreground = "black"
        $NVIDIA3.Foreground = "black"
        $AMD.Foreground = "black"
        $AMD1.Foreground = "black"
        $CPU.Foreground = "black"
        $ASIC.Foreground = "black"
        $Thread_Title.Foreground = "black"

        $NVIDIA.Background = "White"
        $NVIDIA1.Background = "White"
        $NVIDIA2.Background = "White"
        $NVIDIA3.Background = "White"
        $AMD.Background = "White"
        $AMD1.Background = "White"
        $CPU.Background = "White"
        $ASIC.Background = "White"

        $NVIDIA.BorderBrush = "Black"
        $NVIDIA1.BorderBrush = "Black"
        $NVIDIA2.BorderBrush = "Black"
        $NVIDIA3.BorderBrush = "Black"
        $AMD.BorderBrush = "Black"
        $AMD1.BorderBrush = "Black"
        $CPU.BorderBrush = "Black"
        $ASIC.BorderBrush = "Black"

        $NVIDIA.IsEnabled = $true
        $NVIDIA1.IsEnabled = $true
        $NVIDIA2.IsEnabled = $true
        $NVIDIA3.IsEnabled = $true
        $AMD.IsEnabled = $true
        $AMD1.IsEnabled = $true
        $CPU.IsEnabled = $true
        $ASIC.IsEnabled = $true

        $NVIDIA.IsChecked = $false
        $NVIDIA1.IsChecked = $false
        $NVIDIA2.IsChecked = $false
        $NVIDIA3.IsChecked = $False
        $AMD.IsChecked = $false
        $AMD1.IsChecked = $false
        $CPU.IsChecked = $false
        $ASIC.IsChecked = $false
        $Config.param.Type = @()
    }
}
$Auto_Detect.add_Click($Auto_Detect_Click)

if ($Config.param.Type -like "*NVIDIA*") { $NVIDIA.IsChecked = $true }
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

        if("AMD1" -in $Config.param.Type -and "NVIDIA2" -notin $Config.param.Type) {
            $Config.param.Type += "NVIDIA2"
            $NVIDIA2.IsChecked = $true
            $NVIDIA1.IsEnabled = $false
            $NVIDIA1.Foreground = "Gray"
            $NVIDIA1.Background = "Gray"
            $NVIDIA1.BorderBrush = "Gray"
            $NVIDIA1.IsChecked = $false
        }
        elseif ("NVIDIA1" -notin $Config.param.Type) { 
            $Config.param.Type += "NVIDIA1" 
            $NVIDIA1.IsChecked = $true
        }
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
        $Config.param.Type | % { if ($_ -ne "NVIDIA1" -and $_ -ne "NVIDIA2" -and $_ -ne "NVIDIA3") { $Array += $_ } }; 
        $Config.param.Type = $Array
    }
}
$NVIDIA.add_Click($NVIDIA_Click)

if ("NVIDIA1" -in $Config.param.Type -or "NVIDIA2" -in $Config.param.Type -or "NVIDIA3" -in $Config.param.Type) {
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

    if ("NVIDIA1" -in $Config.param.Type) { $NVIDIA1.IsChecked = $true }
    if ("NVIDIA2" -in $Config.param.Type) { $NVIDIA2.IsChecked = $true }
    if ("NVIDIA3" -in $Config.param.Type) { $NVIDIA3.IsChecked = $True }
}
$NVIDIA1_Click = {
    if ($NVIDIA1.IsChecked) {
        if ("NVIDIA1" -notin $Config.param.Type) { $Config.param.Type += "NVIDIA1" }
    }
    else {
        $Array = @(); 
        $Config.param.Type | % { if ($_ -ne "NVIDIA1") { $Array += $_ } }; $Config.param.Type = $Array
    }
}
$NVIDIA1.add_Click($NVIDIA1_Click)

$NVIDIA2_Click = {
    if ($NVIDIA2.IsChecked) {
        if ("NVIDIA2" -notin $Config.param.Type) { $Config.param.Type += "NVIDIA2" }
    }
    else {
        $Array = @(); 
        $Config.param.Type | % { if ($_ -ne "NVIDIA2") { $Array += $_ } }; $Config.param.Type = $Array
    }
}
$NVIDIA2.add_Click($NVIDIA2_Click)

$NVIDIA3_Click = {
    if ($NVIDIA3.IsChecked) {
        if ("NVIDIA3" -notin $Config.param.Type) { $Config.param.Type += "NVIDIA3" }
    }
    else {
        $Array = @(); 
        $Config.param.Type | % { if ($_ -ne "NVIDIA3") { $Array += $_ } }; $Config.param.Type = $Array
    }
}
$NVIDIA3.add_Click($NVIDIA3_Click)

if ($Config.param.Type -like "*AMD*") { 
    $AMD.IsChecked = $true 
    $NVIDIA1.Foreground = "Gray"
    $NVIDIA1.Background = "Gray"
    $NVIDIA1.BorderBrush = "Gray"
    $NVIDIA1.IsEnabled = $false
    $NVIDIA1.IsChecked = $false
}
$AMD_Click = {
    if ($AMD.IsChecked) {
        $AMD1.Foreground = "black"
        $AMD1.Background = "White"
        $AMD1.BorderBrush = "Black"
        $AMD1.IsEnabled = $true
        $AMD1.IsChecked = $true
        if ("AMD1" -notin $Config.param.Type) { $Config.param.Type += "AMD1" }
        if ("NVIDIA1" -in $Config.param.Type) { 
            $Array = @();
            $Config.param.Type | % { if ($_ -ne "NVIDIA1") { $Array += $_ } }; 
            $Config.param.Type = $Array
        }
        $NVIDIA1.Foreground = "Gray"
        $NVIDIA1.Background = "Gray"
        $NVIDIA1.BorderBrush = "Gray"
        $NVIDIA1.IsEnabled = $false
        $NVIDIA1.IsChecked = $false        
    }
    else {
        if($NVIDIA.IsChecked){
            $NVIDIA1.Foreground = "Black"
            $NVIDIA1.Background = "White"
            $NVIDIA1.BorderBrush = "Black"
            $NVIDIA1.IsEnabled = $true
        }
        $AMD1.Foreground = "Gray"
        $AMD1.Background = "Gray"
        $AMD1.BorderBrush = "Gray"
        $AMD1.IsEnabled = $false
        $AMD1.IsChecked = $false
        $Array = @();
        $Config.param.Type | % { if ($_ -ne "AMD1") { $Array += $_ } }; 
        $Config.param.Type = $Array
    }
}
$AMD.add_Click($AMD_Click)

if ("AMD1" -in $Config.param.Type) { 
    $AMD1.Foreground = "black"
    $AMD1.Background = "White"
    $AMD1.BorderBrush = "Black"
    $AMD1.IsEnabled = $true
    $AMD1.IsChecked = $true
}
$AMD1_Click = {
    if ($AMD1.IsChecked) {
        if ("AMD1" -notin $Config.param.Type) { $Config.param.Type += "AMD1" }
    }
    else {
        $Array = @(); 
        $Config.param.Type | % { if ($_ -ne "AMD1") { $Array += $_ } }; $Config.param.Type = $Array
    }
}
$AMD1.add_Click($AMD1_Click)

## CPU Checkbox
if ("CPU" -in $Config.param.Type) { 
    $CPU.IsChecked = $true
    $UpDown.Foreground = "Black"
    $UpDown.Background = "White"
    $UpDown.IsEnabled = $true
    $Thread_Title.Foreground = "Black"    
}else{   
$UpDown.Foreground = "Gray"
$UpDown.Background = "Gray"
$UpDown.IsEnabled = $false
$Thread_Title.Foreground = "Gray"
}
if ($Config.param.CPUThreads -gt 0) {$UpDown.Value = $Config.param.CPUThreads}
if("CPU" -notin $Config.param.Type) {
}
$CPU_Click = {
    if ($CPU.IsChecked) {
        if ("CPU" -notin $Config.param.Type) { $Config.param.Type += "CPU" }
        $UpDown.Foreground = "Black"
        $UpDown.Background = "White"
        $UpDown.IsEnabled = $true
        $Thread_Title.Foreground = "black"
    }
    else {
        $Array = @(); 
        $Config.param.Type | % { if ($_ -ne "CPU") { $Array += $_ } }; $Config.param.Type = $Array
        $UpDown.Foreground = "Gray"
        $UpDown.Background = "Gray"
        $UpDown.IsEnabled = $false
        $Thread_Title.Foreground = "Gray"    
    }
}
$CPU.add_Click($CPU_Click)

if ("ASIC" -in $Config.param.Type) { $ASIC.IsChecked = $true }
$ASIC_Click = {
    if ($ASIC.IsChecked) {
        if ("ASIC" -notin $Config.param.Type) { $Config.param.Type += "ASIC" }
    }
    else {
        $Array = @(); 
        $Config.param.Type | % { if ($_ -ne "ASIC") { $Array += $_ } }; $Config.param.Type = $Array
    }
}
$ASIC.add_Click($ASIC_Click)

Register-ObjectEvent -InputObject $UpDown -EventName "ValueChanged" -Action {$Config.param.CPUThreads = $Updown.Value} | Out-Null

################### Begin GUI ###################

Show-AvaloniaWindow -Window $Config.window
## # out this line to debug
}


## out these lines to debug
if(-not $Debug) {
$run = [runspacefactory]::CreateRunspace()
$run.Open()
$run.SessionStateProxy.SetVariable('Config', $global:Config)
$psCmd = [PowerShell]::Create().AddScript($script)
$psCmd.runspace = $run
$Global:Config.Add("handle",($pscmd.beginInvoke()))
} else {& $Script}

While($Global:Config.handle.IsCompleted -eq $false){
    Start-Sleep -S 1
}