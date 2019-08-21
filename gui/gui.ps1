using module PSAvalonia;

## LOAD DATA
$global:Config = [hashtable]::Synchronized(@{})
$global:Config.ADD("Dir",(Split-Path (Split-Path $script:MyInvocation.MyCommand.Path)))
Set-Location $global:config.Dir

function Global:Get-Avalonia($Name) { Find-AvaloniaControl -Window $global:config.window -Name $Name }
Set-Alias -Name Win -Value Global:Get-Avalonia -Scope Global

## XAML CONVERSION
$Xaml = Get-Content ".\gui\MainWindow.xaml"
$Xaml = $Xaml | Out-String
$Config.Add("window",(convertTo-AvaloniaWindow -Xaml $Xaml))
if($IsWindows){$global:Config.Window.Icon = ".\build\apps\icons\SWARM.ico"}

## PARAMETERS 
if (test-path ".\config\parameters\newarguments.json") { $global:Config.Add("Param",(Get-Content ".\config\parameters\newarguments.json" | ConvertFrom-Json)) } 
else { $global:Config.Add("Param",(Get-Content ".\config\parameters\default.json" | ConvertFrom-Json)) }

## Menu Items
. .\gui\build\menu.ps1

## Tab1 - Basic Settings ##
## Wallets
. .\gui\build\wallets.ps1

## Location
. .\gui\build\location.ps1

##Type Parameters
## AMD Checkbox
$AMD = Win "AMD";
$AMD1 = Win "AMD1"; 

## NVIDIA Checkboxes
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
$Grid = $Grid = [Avalonia.Controls.Grid]::SetColumn($UpDown,4)
$Thread_Title = win "Thread_Title"

## NVIDIA Checkbox
$Auto_Detect = Win "Auto_Detect"

if([string]$global:config.param.Type -eq "") {
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

        $global:config.param.Type = @()
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
        $global:config.param.Type = @()
    }
}
$Auto_Detect.add_Click($Auto_Detect_Click)

if ($global:config.param.Type -like "*NVIDIA*") { $NVIDIA.IsChecked = $true }
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

        if("AMD1" -in $global:config.param.Type -and "NVIDIA2" -notin $global:config.param.Type) {
            $global:config.param.Type += "NVIDIA2"
            $NVIDIA2.IsChecked = $true
            $NVIDIA1.IsEnabled = $false
            $NVIDIA1.Foreground = "Gray"
            $NVIDIA1.Background = "Gray"
            $NVIDIA1.BorderBrush = "Gray"
            $NVIDIA1.IsChecked = $false
        }
        elseif ("NVIDIA1" -notin $global:config.param.Type) { 
            $global:config.param.Type += "NVIDIA1" 
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
        $global:config.param.Type | % { if ($_ -ne "NVIDIA1" -and $_ -ne "NVIDIA2" -and $_ -ne "NVIDIA3") { $Array += $_ } }; 
        $global:config.param.Type = $Array
    }
}
$NVIDIA.add_Click($NVIDIA_Click)

if ("NVIDIA1" -in $global:config.param.Type -or "NVIDIA2" -in $global:config.param.Type -or "NVIDIA3" -in $global:config.param.Type) {
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

    if ("NVIDIA1" -in $global:config.param.Type) { $NVIDIA1.IsChecked = $true }
    if ("NVIDIA2" -in $global:config.param.Type) { $NVIDIA2.IsChecked = $true }
    if ("NVIDIA3" -in $global:config.param.Type) { $NVIDIA3.IsChecked = $True }
}
$NVIDIA1_Click = {
    if ($NVIDIA1.IsChecked) {
        if ("NVIDIA1" -notin $global:config.param.Type) { $global:config.param.Type += "NVIDIA1" }
    }
    else {
        $Array = @(); 
        $global:config.param.Type | % { if ($_ -ne "NVIDIA1") { $Array += $_ } }; $global:config.param.Type = $Array
    }
}
$NVIDIA1.add_Click($NVIDIA1_Click)

$NVIDIA2_Click = {
    if ($NVIDIA2.IsChecked) {
        if ("NVIDIA2" -notin $global:config.param.Type) { $global:config.param.Type += "NVIDIA2" }
    }
    else {
        $Array = @(); 
        $global:config.param.Type | % { if ($_ -ne "NVIDIA2") { $Array += $_ } }; $global:config.param.Type = $Array
    }
}
$NVIDIA2.add_Click($NVIDIA2_Click)

$NVIDIA3_Click = {
    if ($NVIDIA3.IsChecked) {
        if ("NVIDIA3" -notin $global:config.param.Type) { $global:config.param.Type += "NVIDIA3" }
    }
    else {
        $Array = @(); 
        $global:config.param.Type | % { if ($_ -ne "NVIDIA3") { $Array += $_ } }; $global:config.param.Type = $Array
    }
}
$NVIDIA3.add_Click($NVIDIA3_Click)

if ($global:config.param.Type -like "*AMD*") { 
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
        if ("AMD1" -notin $global:config.param.Type) { $global:config.param.Type += "AMD1" }
        if ("NVIDIA1" -in $global:config.param.Type) { 
            $Array = @();
            $global:config.param.Type | % { if ($_ -ne "NVIDIA1") { $Array += $_ } }; 
            $global:config.param.Type = $Array
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
        $global:config.param.Type | % { if ($_ -ne "AMD1") { $Array += $_ } }; 
        $global:config.param.Type = $Array
    }
}
$AMD.add_Click($AMD_Click)

if ("AMD1" -in $global:config.param.Type) { 
    $AMD1.Foreground = "black"
    $AMD1.Background = "White"
    $AMD1.BorderBrush = "Black"
    $AMD1.IsEnabled = $true
    $AMD1.IsChecked = $true
}
$AMD1_Click = {
    if ($AMD1.IsChecked) {
        if ("AMD1" -notin $global:config.param.Type) { $global:config.param.Type += "AMD1" }
    }
    else {
        $Array = @(); 
        $global:config.param.Type | % { if ($_ -ne "AMD1") { $Array += $_ } }; $global:config.param.Type = $Array
    }
}
$AMD1.add_Click($AMD1_Click)

## CPU Checkbox
if ("CPU" -in $global:config.param.Type) { 
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
if ($global:config.param.CPUThreads -gt 0) {$UpDown.Value = $global:config.param.CPUThreads}
if("CPU" -notin $global:config.param.Type) {
}
$CPU_Click = {
    if ($CPU.IsChecked) {
        if ("CPU" -notin $global:config.param.Type) { $global:config.param.Type += "CPU" }
        $UpDown.Foreground = "Black"
        $UpDown.Background = "White"
        $UpDown.IsEnabled = $true
        $Thread_Title.Foreground = "black"
    }
    else {
        $Array = @(); 
        $global:config.param.Type | % { if ($_ -ne "CPU") { $Array += $_ } }; $global:config.param.Type = $Array
        $UpDown.Foreground = "Gray"
        $UpDown.Background = "Gray"
        $UpDown.IsEnabled = $false
        $Thread_Title.Foreground = "Gray"    
    }
}
$CPU.add_Click($CPU_Click)

if ("ASIC" -in $global:config.param.Type) { $ASIC.IsChecked = $true }
$ASIC_Click = {
    if ($ASIC.IsChecked) {
        if ("ASIC" -notin $global:config.param.Type) { $global:config.param.Type += "ASIC" }
    }
    else {
        $Array = @(); 
        $global:config.param.Type | % { if ($_ -ne "ASIC") { $Array += $_ } }; $global:config.param.Type = $Array
    }
}
$ASIC.add_Click($ASIC_Click)

Register-ObjectEvent -InputObject $UpDown -EventName "ValueChanged" -Action {$global:config.param.CPUThreads = $Updown.Value} | Out-Null

## Add Wallet1 To Params:
$Wallet1 = Win "Wallet1"
if ($global:config.param.Wallet1) {
    $Wallet1.Text = $global:config.param.Wallet1
}
$Rigname1 = Win "Rigname1"
if ($global:config.param.Rigname1) {
    $Rigname1.Text = $global:config.param.Rigname1
}
$Donate = Win "Donate"
if ($global:config.param.Donate) {
    $Donate.Text = $global:config.param.Donate
}
$Auto_Coin = Win "Auto_Coin"
if ($global:config.param.Auto_Coin -eq "Yes") {
    $Auto_Coin.IsChecked = $true
}
$Auto_Coin_Check = {
    if ($Auto_Coin.IsChecked -eq $true) {
        $global:config.param.Auto_Coin = "Yes"
    }
    else { $global:config.param.Auto_Coin = "No" }
}
$Auto_Coin.add_Click($Auto_Coin_Check)

## Pools
$Pool_List = Win "Pool_List"
$global:config.param.PoolName | % {
    $Item = [Avalonia.Controls.ListBoxItem]::new()
    $Item.Content = "$($_)"
    $Pool_List.ITEMS.Add($Item)
}
$Add_Pool_List = Win "Add_Pool_List"
$AllPools = @()
$Pool = Get-ChildItem ".\algopools"
$Pool | % { $AllPools += $_.BaseName }
$Pool = Get-ChildItem ".\custompools"
$Pool | % { $AllPools += $_.BaseName }

$AllPools | % {
    if ($_ -notin $Pool_List.ITEMS.Content) {
        $Item = [Avalonia.Controls.ListBoxItem]::new()
        $Item.Content = "$($_)"
        $Add_Pool_List.ITEMS.Add($Item)
    }
}

$Add_Pool = Win "Add_Pool_Button"
$Add_Pool_Check = {
    if ($Add_Pool_List.SelectedItem) {
        if ($Add_Pool_List.SelectedItem.Content -notin $Pool_List.ITEMS.Content) {
            $Item = [Avalonia.Controls.ListBoxItem]::new()
            $Item.Content = "$($Add_Pool_List.SelectedItem.Content)"
            $Pool_List.ITEMS.Add($Item)
            $global:config.param.PoolName += "$($Add_Pool_List.SelectedItem.Content)"
            $Add_Pool_List.ITEMS.Clear()
            $AllPools | % {
                if ($_ -notin $Pool_List.ITEMS.Content) {
                    $Item = [Avalonia.Controls.ListBoxItem]::new()
                    $Item.Content = "$($_)"
                    $Add_Pool_List.ITEMS.Add($Item)
                }
            }        
        }
    }
}
$Add_Pool.add_Click($Add_Pool_Check)

$Remove_Pool = Win "Remove_Pool_Button"
$Remove_Pool_Check = {
    if ($Pool_List.SelectedItem) {
        if ($Pool_List.SelectedItem.Content -notin $Add_Pool_List.ITEMS.Content) {
            $Item = [Avalonia.Controls.ListBoxItem]::new()
            $Item.Content = "$($Pool_List.SelectedItem.Content)"
            $Add_Pool_List.ITEMS.Add($Item)
            $Array = @()
            $global:config.param.Poolname | % { if ($_ -ne "$($Pool_List.SelectedItem.Content)") { $Array += "$($_)" } }
            $global:config.param.Poolname = $Array
            $Pool_List.ITEMS.Clear()
            $global:config.param.Poolname | % {
                if ($_ -notin $Add_Pool_List.ITEMS.Content) {
                    $Item = [Avalonia.Controls.ListBoxItem]::new()
                    $Item.Content = "$($_)"
                    $Pool_List.ITEMS.Add($Item)
                }
            }        
        }
    }
}
$Remove_Pool.add_Click($Remove_Pool_Check)

################### Begin GUI ###################
Show-AvaloniaWindow -Window $global:config.window