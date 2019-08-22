## Rigname Items

## Bind Naming
$Rig_List = Win "Rig_List"
$Rig = Win "Rig"
$Rig_Text = Win "Rig_Text"
$Rig_But = Win "Save_Rig"

##Load Initial Params- Will Always Be Wallet1 At Start
$Rig.Text = $Config.param.Rigname1
$Rig_Text.Text = "Enter Name For Group1"

## When "Rigname" is changed:
$Save_Click = {
    $Rig_Item = $Rig_List.SelectedItem.Content
    $Rigname = $Rig.Text
    
    $Config.param.$Rig_Item = $Rigname
    $Rig_But.Foreground = "Green"
    $Rig_But.Content = "Saved!"
}
$Rig_But.add_Click($Save_Click)

## When New Wallet Is Selected
$New_Selection = {
    $Rig_But.Foreground = "Black"
    $Rig_But.Content = "Save Rig Name"

    $Rig_Item = $Rig_List.SelectedItem.Content

    switch ($Rig_Item) {
        "Rigname1" {
            if ($Config.param.RigName1) { $Rig.Text = $Config.param.RigName1 } else { $Rig.Text = $null }
            $Rig_Text.Text = "Enter Name For Group1"
        }
        "Rigname2" {
            if ($Config.param.Rigname2) { $Rig.Text = $Config.param.RigName2 } else { $Rig.Text = $null }
            $Rig_Text.Text = "Enter Name For Group2"
        }
        "Rigname3" {
            if ($Config.param.RigName3) { $Rig.Text = $Config.param.RigName3 } else { $Rig.Text = $null }
            $Rig_Text.Text = "Enter Name For Group3"
        }
    }
}
$Rig_List.add_SelectionChanged($New_Selection)

