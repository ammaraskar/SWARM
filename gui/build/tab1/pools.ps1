## Pools
$Pool_List = Win "Pool_List"
$Config.param.PoolName | % {
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
            $Config.param.PoolName += "$($Add_Pool_List.SelectedItem.Content)"
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
            $Config.param.Poolname | % { if ($_ -ne "$($Pool_List.SelectedItem.Content)") { $Array += "$($_)" } }
            $Config.param.Poolname = $Array
            $Pool_List.ITEMS.Clear()
            $Config.param.Poolname | % {
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
