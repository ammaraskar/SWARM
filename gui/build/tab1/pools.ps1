## Pools

## Gather Pool Binding.
$Pool_List = Win "Pool_List"
$Add_Pool_List = Win "Add_Pool_List"
$Add_Pool = Win "Add_Pool_Button"
$Remove_Pool = Win "Remove_Pool_Button"

## Create A New ListBox Item, And Add It To The Pool List Box.
## This Is The Pools The User Is Currently Using.
$Config.param.PoolName | % {
    $Item = [Avalonia.Controls.ListBoxItem]::new()
    $Item.Content = "$($_)"
    $Pool_List.ITEMS.Add($Item)
}

## This Is The Pools Available.
$AllPools = @()
$Pool = Get-ChildItem ".\algopools"
$Pool | % { $AllPools += $_.BaseName }
$Pool = Get-ChildItem ".\custompools"
$Pool | % { $AllPools += $_.BaseName }

## If Pools Are Not Being Used- Add Them To Available Pool List
$AllPools | % {
    if ($_ -notin $Pool_List.ITEMS.Content) {
        $Item = [Avalonia.Controls.ListBoxItem]::new()
        $Item.Content = "$($_)"
        $Add_Pool_List.ITEMS.Add($Item)
    }
}

## Handle Click Of Add Pool
$Add_Pool_Check = {

    ## Rebuild The Two List Boxes
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

## Same Process As Adding Pool, Only Now We Reversing Directions (Removing Pool)
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
