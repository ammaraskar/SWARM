class Data_Object {
    [string]$Type
    [string]$Miner
    [string]$Item
    [string]$HashRate
    [string]$Watt_Day
    [String]$BTC_Day
    [string]$Coin_Day
    [String]$Fiat_Day
    [string]$Pool
    
    Data_Object([string]$Type, [String]$miner, [string]$Item, [String]$HashRate, [String]$Watt_Day, [String]$BTC_Day, [string]$Coin_Day, [String]$Fiat_Day, [String]$Pool) {
        [string]$this.Type = $Type
        [string]$this.Miner = $Miner
        [string]$this.Item = $Item
        [string]$this.HashRate = $HashRate
        [string]$this.Watt_Day = $Watt_Day
        [string]$this.BTC_Day = $BTC_Day
        [string]$this.Coin_Day = $Coin_Day
        [string]$this.Fiat_Day = $Fiat_Day
        [string]$this.Pool = $Pool
    }
}

Function Global:Invoke-UpdateData {
    $Timer.Stop()
    $Timer.IsEnabled = $False
    if (test-path ".\build\txt\bestminers.txt") { $C_Data = Get-Content ".\build\txt\bestminers.txt" | ConvertFrom-Json }
    if (test-path ".\build\txt\json_stats.txt") { $D_Data = Get-Content ".\build\txt\json_stats.txt" | ConvertFrom-Json }
    if (test-path ".\build\txt\json_stats.txt") { $Rates = Get-Content ".\build\txt\Rates.txt" | ConvertFrom-Json }

    $Data_Objects = @()
    
    if ($D_Data) {
        $C_Data | ForEach-Object {
            $Sel = $_
            $HashRate = $D_Data.TypeHashes.$($Sel.Type) | ConvertTo-Hash
            $WattDay = $($($_.Power_Day) | ForEach-Object { if ($null -ne $_) { ($_ * $Rates.Rate).ToString("N2") }else { "Bench" } })
            $BTCDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { $_.ToString("N5") }else { "Bench" } })
            $CoinDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { ($_ / $Rates.Exchange).ToString("N5") }else { "Bench" } } )
            $CurDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { ($_ * $Rates.Rate).ToString("N2") }else { "Bench" } })
            $Data_Objects += [Data_Object]::New($Sel.Type, $Sel.Miner, $Sel.Symbol, $HashRate, $WattDay, $BTCDay, $CoinDay, $CurDay, $Sel.MInerPool)
        }
    } else {
        $Data_Objects += [Data_Object]::New("Waiting For Data...", "None", "None", "None", "None", "None", "None", "None","None")
    }
    $Data_Grid.Items = $Data_Objects
    [int32]$RefreshInterval = 10
    $Timer.Interval = New-Timespan -Seconds ($RefreshInterval -as [int32])
    $Timer.IsEnabled = $True
    $Timer.start()
    Remove-Variable -name C_Data -ErrorAction Ignore
    Remove-Variable -name D_Data -ErrorAction Ignore
    Get-Job -State Completed | Remove-Job
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    [GC]::Collect()
    Clear-History
}
    
$Data_Grid = Win "Tab1_Row6"
$Timer = [Avalonia.Threading.DispatcherTimer]::New()
[int32]$RefreshInterval = 10
$Timer.Interval = New-Timespan -Seconds ($RefreshInterval -as [int32])
$Timer.IsEnabled = $false
$Timer.add_Tick({Global:Invoke-UpdateData})
Global:Invoke-UpdateData
