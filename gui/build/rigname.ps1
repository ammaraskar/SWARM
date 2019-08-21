## Rigname Items

## Bind Naming
$Rig_List = Win "Rig_List"
$Rig = Win "Rig"
$Rig_Text = Win "Rig_Text"

##Load Initial Params- Will Always Be Wallet1 At Start
$Rig.Text = $global:config.param.Rigname1
$Rig_Text.Text = "Enter Name For Group1"

## When "Rigname" is changed:
