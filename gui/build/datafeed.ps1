class Data_Object {
    [string]$Type
    [string]$Miner
    [string]$Algorithm
    [string]$HashRate
    [string]$WattDay
    [String]$BTC_Day
    [String]$Profit_Day
    [string]$Pool
    
    Data_Object([string]$Type, [String]$miner, [string]$Algorithm, [String]$HashRate, [String]$WattDay, [String]$BTC_Day, [String]$Profit_Day, [String]$Pool) {
        [string]$this.Type = $Type
        [string]$this.Miner = $Miner
        [string]$this.Algorithm = $Algorithm
        [string]$this.HashRate = $HashRate
        [string]$this.WattDay = $WattDay
        [string]$this.BTC_Day = $BTC_Day
        [string]$this.Profit_Day = $Profit_Day
        [string]$this.Pool = $Pool
    }
}

Function Global:Invoke-UpdateData {
    $Timer.Stop()
    $Timer.IsEnabled = $False
    if (test-path ".\build\txt\bestminers.txt") { $C_Data = Get-Content ".\build\txt\bestminers.txt" | ConvertFrom-Json }
    if (test-path ".\build\txt\json_stats.txt") { $D_Data = Get-Content ".\build\txt\json_stats.txt" | ConvertFrom-Json }

    $Data_Objects = @()
    
    if ($C_Data) {
        $C_Data | ForEach-Object {
            $Sel = $_
            $HashRate = $D_Data.TypeHashes.$($Sel.Type) | ConvertTo-Hash
            $Data_Objects += [Data_Object]::New($Sel.Type, $Sel.Name, $Sel.Algo, $HashRate, $Sel.Profit, $Sel.Fiat_Day, $Sel.Profit_Day, $Sel.MinerPool)
        }
    }
    $Data_Grid.Items = $Data_Objects
    [int32]$RefreshInterval = 30
    $Timer.Interval = New-Timespan -Seconds ($RefreshInterval -as [int32])
    $Timer.IsEnabled = $True
    $Timer.start()
    Write-Host "Timer Started"
}
    
$Data_Grid = Win "Tab1_Row6"

$Timer = [Avalonia.Threading.DispatcherTimer]::New()
[int32]$RefreshInterval = 30
$Timer.Interval = New-Timespan -Seconds ($RefreshInterval -as [int32])
$Timer.IsEnabled = $false
$Timer.add_Tick({Global:Invoke-UpdateData})
Global:Invoke-UpdateData
