Function Global:Invoke-UpdateData {

    ## Stop The Timer, To Handle The Event.
    $Timer.Stop()
    $Timer.IsEnabled = $False

    ## Gather Various Stat Params
    if (test-path ".\build\txt\bestminers.txt") { $C_Data = Get-Content ".\build\txt\bestminers.txt" | ConvertFrom-Json }
    if (test-path ".\build\txt\json_stats.txt") { $D_Data = Get-Content ".\build\txt\json_stats.txt" | ConvertFrom-Json }
    if (test-path ".\build\txt\json_stats.txt") { $Rates = Get-Content ".\build\txt\rates.txt" | ConvertFrom-Json }

    $Data_Objects = @()
    
    if ($D_Data) {
        $C_Data | Sort-Object -Property Type | ForEach-Object {
            ## Convert Data Of The Selected Type
            $Sel = $_
            $HashRate = $D_Data.TypeHashes.$($Sel.Type) | ConvertTo-Hash
            $WattDay = $($($_.Power) | ForEach-Object { if ($null -ne $_) { ($_ * $Rates.Rate).ToString("N2") }else { "Bench" } })
            $BTCDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { $_.ToString("N5") }else { "Bench" } })
            $CoinDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { ($_ / $Rates.Exchange).ToString("N5") }else { "Bench" } } )
            $CurDay = $($($_.Profit) | ForEach-Object { if ($null -ne $_) { ($_ * $Rates.Rate).ToString("N2") }else { "Bench" } })

            ## Build A New Stat And Add It To Array
            $Data_Objects += [stat]::New($Sel.Type, $Sel.Name, $Sel.Symbol, $HashRate, $WattDay, $BTCDay, $CoinDay, $CurDay, $Sel.MInerPool)

            ## Change the Binding
            $Config.window.DataContext.Change_Stat($Data_Objects)
        }

        ## Change the Headers For The Data Grid
        $Data_Grid.Columns[6].Header = "$($Rates.Coin)/Day"
        $Data_Grid.Columns[7].Header = "$($Rates.Currency)/Day"
    } else {  ## Build Generic Table Letting User Know We Are Waiting For Stats.
        $Data_Objects += [stat]::New("Waiting" "For", "Incoming", "Data", "None", "None", "None", "None","None")
        $Config.window.DataContext.Change_Stat($Data_Objects)
    }

    ## Reset the timer
    [int32]$RefreshInterval = 10
    $Timer.Interval = New-Timespan -Seconds ($RefreshInterval -as [int32])
    $Timer.IsEnabled = $True
    $Timer.start()

    ## Since this is the most used function- Use This Moment To Perform Garbage Collection.
    Get-Job -State Completed | Remove-Job
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    [GC]::Collect()
    Clear-History
}

## Get The Data Grid. Set The New Timer.
$Data_Grid = Win "Tab1_Row6"
$Timer = [Avalonia.Threading.DispatcherTimer]::New()
[int32]$RefreshInterval = 10
$Timer.Interval = New-Timespan -Seconds ($RefreshInterval -as [int32])
$Timer.IsEnabled = $false
$Timer.add_Tick({Global:Invoke-UpdateData})

## Gather Data For First Time.
Global:Invoke-UpdateData
