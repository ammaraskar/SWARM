Function Global:Invoke-UpdateData {
    $Timer.Stop()
    $Timer.IsEnabled = $False
    if (test-path ".\build\txt\bestminers.txt") { $C_Data = Get-Content ".\build\txt\bestminers.txt" | ConvertFrom-Json }
    if (test-path ".\build\txt\json_stats.txt") { $D_Data = Get-Content ".\build\txt\json_stats.txt" | ConvertFrom-Json }
    if (test-path ".\build\txt\json_stats.txt") { $Rates = Get-Content ".\build\txt\Rates.txt" | ConvertFrom-Json }
    $Data_Objects = @()
    
    if ($D_Data) {
        $C_Data | Sort-Object -Property Type | ForEach-Object {
            $Sel = $_
            $HashRate = $D_Data.TypeHashes.$($Sel.Type) | ConvertTo-Hash
            $WattDay = $($($_.Power) | ForEach-Object { if ($null -ne $_) { ($_ * $Rates.Rate).ToString("N2") }else { "Bench" } })
            $BTCDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { $_.ToString("N5") }else { "Bench" } })
            $CoinDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { ($_ / $Rates.Exchange).ToString("N5") }else { "Bench" } } )
            $CurDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { ($_ * $Rates.Rate).ToString("N2") }else { "Bench" } })
            $Data_Objects += [stat]::New($Sel.Type, $Sel.Name, $Sel.Symbol, $HashRate, $WattDay, $BTCDay, $CoinDay, $CurDay, $Sel.MInerPool)
            $Config.window.DataContext.Change_Stat($Data_Objects)
            $Config.Window.DataContext.Change_Greeting("This is a Test")
        }
        $Data_Grid.Columns[6].Header = "$($Rates.Coin)/Day"
        $Data_Grid.Columns[7].Header = "$($Rates.Currency)/Day"
    } else {
        $Data_Objects += [stat]::New("Waiting For Data...", "None", "None", "None", "None", "None", "None", "None","None")
        $Config.window.DataContext.Change_Stat($Data_Objects)
        $Config.Window.DataContext.Change_Greeting("This is a Test")
    }
    [int32]$RefreshInterval = 10
    $Timer.Interval = New-Timespan -Seconds ($RefreshInterval -as [int32])
    $Timer.IsEnabled = $True
    $Timer.start()
    Remove-Variable -name C_Data -ErrorAction Ignore
    Remove-Variable -name D_Data -ErrorAction Ignore
    Remove-Variable -name Rates -ErrorAction Ignore
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
