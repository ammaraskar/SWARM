### Wallets Bar

## Name Binding
$global:Wallet_List = win "Wallet_List"
$global:Symbol = win "Symbol"
$global:Address = win "Address"
$global:Save = win "Save_Wallet"

##Load Initial Params- Will Always Be Wallet1 At Start
$global:Symbol.Text = $Config.param.Passwordcurrency1
$global:Address.Text = $Config.param.Wallet1

## EVENTS

## When "Save Wallet Is Pushed"
$Save_Click = {
    $Wallet = $Wallet_List.SelectedItem.Content
    $New_Address = $global:Address.Text
    $New_Symbol = $global:Symbol.Text

    switch ($Wallet) {
        "Wallet1" { $Config.param.Passwordcurrency1 = $New_Symbol; $Config.param.Wallet1 = $New_Address }
        "Wallet2" { $Config.param.Passwordcurrency2 = $New_Symbol; $Config.param.Wallet2 = $New_Address }
        "Wallet3" { $Config.param.Passwordcurrency3 = $New_Symbol; $Config.param.Wallet2 = $New_Address }
        "AltWallet1" { $Config.param.AltPassword1 = $New_Symbol; $Config.param.AltWallet1 = $New_Address }
        "AltWallet2" { $Config.param.AltPassword2 = $New_Symbol; $Config.param.AltWallet2 = $New_Address }
        "AltWallet3" { $Config.param.AltPassword3 = $New_Symbol; $Config.param.AltWallet3 = $New_Address }
        "NiceHash_Wallet1" { $Config.param.Nicehash_Wallet1 = $New_Address }
        "NiceHash_Wallet2" { $Config.param.Nicehash_Wallet2 = $New_Address }
        "NiceHash_Wallet3" { $Config.param.Nicehash_Wallet3 = $New_Address }
        "ETH" { $Config.param.ETH = $New_Address}
    }
    $Save.Foreground = "Green"
    $Save.Content = "Saved!"
}
$Save.add_Click($Save_Click)

## When New Wallet Is Selected

$New_Selection = {
    $Save.Foreground = "Black"
    $Save.Content = "Save Wallet"
    $Wallet = $global:Wallet_List.SelectedItem.Content
    switch ($Wallet) {
        "Wallet1" {
            if (-not $Config.param.PasswordCurrency1) { $global:Symbol.Text = "BTC" } else { $global:Symbol.Text = $Config.param.Passwordcurrency1 }
            if ($Config.param.Wallet1) { $global:Address.Text = $Config.param.Wallet1 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Enter Address Here. Used With AMD1/NVIDIA1/CPU1/AUTO."
        }
        "Wallet2" {
            if (-not $Config.param.PasswordCurrency2) { $global:Symbol.Text = "BTC" } else { $global:Symbol.Text = $Config.param.PasswordCurrency2 }
            if ($Config.param.Wallet2) { $global:Address.Text = $Config.param.Wallet2 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Enter Adress Here. Used With NVIDIA2 Group"
        }
        "Wallet3" {
            if (-not $Config.param.Passwordcurrency3) { $global:Symbol.Text = "BTC" } else { $global:Symbol.Text = $Config.param.PasswordCurrency3 }
            if ($Config.param.Wallet3) { $global:Address.Text = $Config.param.Wallet3 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Enter Adress Here. Used With NVIDIA3 Group"
        }
        "AltWallet1" {
            if (-not $Config.param.AltPassword1) { $global:Symbol.Text = "LTC" } else { $global:Symbol.Text = $Config.param.AltPassword1 }
            if ($Config.param.AltWallet1) { $global:Address.Text = $Config.param.AltWallet1 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Secondary Address. Used With AMD1/NVIDIA1/CPU1/AUTO."
        }
        "AltWallet2" {
            if (-not $Config.param.AltPassword2) { $global:Symbol.Text = "LTC" } else { $global:Symbol.Text = $Config.param.AltPassword2 }
            if ($Config.param.AltWallet2) { $global:Address.Text = $Config.param.AltWallet2 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Secondary Address. Used With NVIDIA2 Group."
        }
        "AltWallet3" {
            if (-not $Config.param.AltPassword3) { $global:Symbol.Text = "LTC" } else { $global:Symbol.Text = $Config.param.AltPassword3 }
            if ($Config.param.AltWallet3) { $global:Address.Text = $Config.param.AltWallet3 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Secondary Address. Used With NVIDIA3 Group."
        }
        "NiceHash_Wallet1" {
            $global:Symbol.Text = "NONE"
            if ($Config.param.NiceHash_Wallet1) { $global:Address.Text = $Config.param.NiceHash_Wallet1 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "NiceHash Wallet. Used With AMD1/NVIDIA1/CPU1/AUTO."
        }
        "NiceHash_Wallet2" {
            $global:Symbol.Text = "NONE"
            if ($Config.param.NiceHash_Wallet2) { $global:Address.Text = $Config.param.NiceHash_Wallet2 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "NiceHash Wallet. Used With NVIDIA2 Group."
        }
        "NiceHash_Wallet3" {
            $global:Symbol.Text = "NONE"
            if ($Config.param.NiceHash_Wallet3) { $global:Address.Text = $Config.param.NiceHash_Wallet3 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "NiceHash Wallet. Used With NVIDIA3 Group."
        }
        "ETH" {
            $global:Symbol.Text = "ETH"
            if ($Config.param.ETH) { $global:Address.Text = $Config.param.ETH } else { $global:Address.Text = $null }
            $global:Address.Watermark = "ETH Wallet. Used With whalesburg pool."
        }
    }
}
$global:Wallet_List.Add_SelectionChanged($New_Selection)
