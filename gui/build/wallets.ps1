### Wallets Bar

## Name Binding
$global:Wallet_List = win "Wallet_List"
$global:Symbol = win "Symbol"
$global:Address = win "Address"
$global:Save = win "Save_Wallet"

##Load Initial Params- Will Always Be Wallet1 At Start
$global:Symbol.Text = $global:config.param.Passwordcurrency1
$global:Address.Text = $global:config.param.Wallet1

## EVENTS

## When "Save Wallet Is Pushed"
$Save_Click = {
    $Wallet = $Wallet_List.SelectedItem.Content
    $New_Address = $global:Address.Text
    $New_Symbol = $global:Symbol.Text

    $global:config.param.$Wallet = $New_Address

    switch ($Wallet) {
        "Wallet1" { $global:config.param.Passwordcurrency1 = $New_Symbol; $global:config.param.Wallet1 = $New_Address }
        "Wallet2" { $global:config.param.Passwordcurrency2 = $New_Symbol; $global:config.param.Wallet2 = $New_Address }
        "Wallet3" { $global:config.param.Passwordcurrency3 = $New_Symbol; $global:config.param.Wallet2 = $New_Address }
        "AltWallet1" { $global:config.param.AltPassword1 = $New_Symbol; $global:config.param.AltWallet1 = $New_Address }
        "AltWallet2" { $global:config.param.AltPassword2 = $New_Symbol; $global:config.param.AltWallet2 = $New_Address }
        "AltWallet3" { $global:config.param.AltPassword3 = $New_Symbol; $global:config.param.AltWallet3 = $New_Address }
        "NiceHash_Wallet1" { $global:config.param.Nicehash_Wallet1 = $New_Address }
        "NiceHash_Wallet2" { $global:config.param.Nicehash_Wallet2 = $New_Address }
        "NiceHash_Wallet3" { $global:config.param.Nicehash_Wallet3 = $New_Address }
        "ETH" { $global:config.param.ETH = $New_Address}
    }
    $Save.Foreground = "Green"
    $Save.Content = "Wallet Saved!"
}
$Save.add_Click($Save_Click)

## When New Wallet Is Selected

$New_Selection = {
    $Save.Foreground = "Black"
    $Save.Content = "Save Wallet"
    $Wallet = $global:Wallet_List.SelectedItem.Content
    switch ($Wallet) {
        "Wallet1" {
            if (-not $global:Config.param.PasswordCurrency1) { $global:Symbol.Text = "BTC" } else { $global:Symbol.Text = $global:Config.param.Passwordcurrency1 }
            if ($global:Config.param.Wallet1) { $global:Address.Text = $global:Config.param.Wallet1 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Enter Address Here. Used With AMD1/NVIDIA1/CPU1/AUTO."
        }
        "Wallet2" {
            if (-not $global:Config.param.PasswordCurrency2) { $global:Symbol.Text = "BTC" } else { $global:Symbol.Text = $global:Config.param.PasswordCurrency2 }
            if ($global:Config.param.Wallet2) { $global:Address.Text = $global:Config.param.Wallet2 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Enter Adress Here. Used With NVIDIA2 Group"
        }
        "Wallet3" {
            if (-not $global:Config.param.Passwordcurrency3) { $global:Symbol.Text = "BTC" } else { $global:Symbol.Text = $global:Config.param.PasswordCurrency3 }
            if ($global:Config.param.Wallet3) { $global:Address.Text = $global:Config.param.Wallet3 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Enter Adress Here. Used With NVIDIA3 Group"
        }
        "AltWallet1" {
            if (-not $global:Config.param.AltPassword1) { $global:Symbol.Text = "LTC" } else { $global:Symbol.Text = $global:Config.param.AltPassword1 }
            if ($global:Config.param.AltWallet1) { $global:Address.Text = $global:Config.param.AltWallet1 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Secondary Address. Used With AMD1/NVIDIA1/CPU1/AUTO."
        }
        "AltWallet2" {
            if (-not $global:Config.param.AltPassword2) { $global:Symbol.Text = "LTC" } else { $global:Symbol.Text = $global:Config.param.AltPassword2 }
            if ($global:Config.param.AltWallet2) { $global:Address.Text = $global:Config.param.AltWallet2 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Secondary Address. Used With NVIDIA2 Group."
        }
        "AltWallet3" {
            if (-not $global:Config.param.AltPassword3) { $global:Symbol.Text = "LTC" } else { $global:Symbol.Text = $global:Config.param.AltPassword3 }
            if ($global:Config.param.AltWallet3) { $global:Address.Text = $global:Config.param.AltWallet3 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "Secondary Address. Used With NVIDIA3 Group."
        }
        "NiceHash_Wallet1" {
            $global:Symbol.Text = "NONE"
            if ($global:Config.param.NiceHash_Wallet1) { $global:Address.Text = $global:Config.param.NiceHash_Wallet1 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "NiceHash Wallet. Used With AMD1/NVIDIA1/CPU1/AUTO."
        }
        "NiceHash_Wallet2" {
            $global:Symbol.Text = "NONE"
            if ($global:Config.param.NiceHash_Wallet2) { $global:Address.Text = $global:Config.param.NiceHash_Wallet2 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "NiceHash Wallet. Used With NVIDIA2 Group."
        }
        "NiceHash_Wallet3" {
            $global:Symbol.Text = "NONE"
            if ($global:Config.param.NiceHash_Wallet3) { $global:Address.Text = $global:Config.param.NiceHash_Wallet3 } else { $global:Address.Text = $null }
            $global:Address.Watermark = "NiceHash Wallet. Used With NVIDIA3 Group."
        }
        "ETH" {
            $global:Symbol.Text = "ETH"
            if ($global:Config.param.ETH) { $global:Address.Text = $global:Config.param.ETH } else { $global:Address.Text = $null }
            $global:Address.Watermark = "ETH Wallet. Used With whalesburg pool."
        }
    }
}
$global:Wallet_List.Add_SelectionChanged($New_Selection)
