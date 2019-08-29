
## Location Tool

## Name Binding
$USA = Win "USA"
$ASIA = Win "ASIA"
$EUROPE = WIn "EUROPE"

## Change Param Locations With Each Radio Button.
$Change = {
    if($Config.Param.Location -ne "USA"){
        $Config.Param.Location = "USA"
    }
}

$USA.add_Click($Change)

$Change = {
    if($Config.Param.Location -ne "ASIA"){
        $Config.Param.Location = "ASIA"
    }
}
$ASIA.add_Click($Change)

$Change = {
    if($Config.Param.Location -ne "EUROPE"){
        $Config.Param.Location = "EUROPE"
    }
}
$EUROPE.add_Click($Change)