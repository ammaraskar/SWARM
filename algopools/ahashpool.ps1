using module "..\build\powershell\global\stats.psm1"

## return values
## return 1 = "Pool Not Specified"
## return 2 = "SWARM contacted ($Name) but there was no response."
## return 3 = "SWARM contacted ($Name) but ($Name) the response was empty."

## TODO
# Add wallet to rigname
# Add volume hashrate to pools
# Add percent value of hashrate volume to pools / sort
# New get wallets features / by rig

param(
    ## Direct User Parameters
    [string[]]$Pools,               ## poolname parameter
    [string]$xnsub = "no",          ## xnsub parameter
    [Double]$Historical_Bias = 0,   ## historical_bias parameter
    [string]$stat_level,            ## stat_algo parameter
    [string]$interval,              ## interval parameter
    [string]$Max_Periods,           ## max_periods parameter

    ## Internal Data
    [string[]]$Algorithms,          ## GPU & CPU algos
    [string[]]$Asic_Algorithms,     ## ASIC algos
    [hashtable]$Wallets,            ## User Wallets
    [string[]]$Bans,                ## Global Bans
    [PSCustomObject]$Pool_Algos     ## pool-algos.json (argument modified)
)

$Name = "ahashpool"
$Link = "https://www.ahashpool.com/api/status"
if ($xnsub -eq "Yes") { $X = "#xnsub" }
if ("ahashpool" -notin $Pools) { return 1 }

## Connnect To Pool, Add Data
try { 
    $Pool_Request = Invoke-RestMethod $Link -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
}  catch { return 2 }
if ( ($Pool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore).Count -eq 0) { 
    return 3 
}

## Determine What Algo Data To Grab
[array]$Algos += $Algorithms, $Asic_Algorithms

## Only get algos we need & convert original name to a universal naming schema
$Pool_Sorted = $Pool_Request.PSobject.Properties.Value | 
    Where-Object { [Double]$_.estimate_current -gt 0 } | 
    ForEach-Object { 
        $Algo_Name = $_.Name;
        $_ | Add-Member "Original_Algo" $Algo_Name
        $_.Name = $Pool_Algos.PSObject.Properties.Name | Where { $Algo_Name -in $Pool_Algos.$_.alt_names };
        if ($_.Name -in $Algos -and $Name -notin $Pool_Algos.$($_.Name).exclusions -and $($_.Name) -notin $Bans) { $_ }
    }
  
## Create Values From Algo Data
$Pool_Sorted | ForEach-Object {

    ## Deviation of estimates vs returns
    $Day_Estimate = [Double]$_.estimate_last24h;
    $Day_Return = [Double]$_.actual_last24h;
    $_ | Add-Member "deviation" (Global:Start-Shuffle $Day_Estimate $Day_Return)

    ## Naming
    $StatAlgo = $_.Name -replace "`_", "`-"
    $StatPath = "$($Name)_$($StatAlgo)_profit"

    ## Determine Starting Estimate
    if (-not (test-Path ".\stats\$StatPath") ) { $Estimate = [Double]$_.estimate_last24h }
    else { $Estimate = [Double]$_.estimate_current }
    
    ## Connection Info
    $Pool_Port = $_.port
    $Pool_Host = "$($_.Original_Algo).mine.ahashpool.com$X"

    ## Hashrate Volume
    $Hashrate = $_.hashrate
    if ([double]$HashRate -eq 0) { $Hashrate = 1 }  ## Set to prevent volume dividebyzero error

    ## Estimate Info/Stat
    $Divisor = 1000000 * $_.mbtc_mh_factor
    $previous = [Math]::Max(([Double]$_.actual_last24h * 0.001) / $Divisor * (1 - ($_.fees / 100)), $SmallestValue)

    ## Make New Stat
    $Stat = [pool_stat]::new(
        "$($Name)_$($StatAlgo)_profit",                 ## Name of Stat File
        $interval,                                      ## Current Interval Param
        ($Estimate / $Divisor * (1 - ($_.fees / 100))), ## Stat value
        $Max_Periods,                                   ## Current Max_Periods Param
        $Hashrate,                                      ## Pool Current Hashrate
        $_.Deviation                                    ## 24 estimate vs. 24 actual     
    )
        
    ## Historical Bias Penalty To Incoming Estimate
    $Level = $Stat.$stat_level
    if ($Historical_Bias -gt 0) { $Level = [Math]::Max($Level + ($Level * $Stat.Deviation), 1E-20) }

    ## Set Wallet Values
    $Pass1 = $Wallets.Wallet1.Keys
    $User1 = $Wallets.Wallet1.Pass1.address
    $Rig1   = $Wallets.Wallet1.Rigname
    $Pass2 = $Wallets.Wallet2.Keys
    $User2 = $Wallets.Wallet2.Pass2.address
    $Rig2   = $Wallets.Wallet2.Rigname
    $Pass3 = $Wallets.Wallet3.Keys
    $User3 = $Wallets.Wallet3.Pass3.address
    $Rig3   = $Wallets.Wallet3.Rigname
                    
    ## Create a New Pool Value
    [Pool]::New(
        "$($_.Name)-Algo",    ## Symbol
        "$($_.Name)",         ## Algorithm
        $Level,               ## Level
        "stratum+tcp",        ## Stratum
        $Pool_Host,           ## Pool_Host
        $Pool_Port,           ## Pool_Port
        $User1,               ## User1
        $User2,               ## User2
        $User3,               ## User3
        "c=$Pass1,id=$Rig1",  ## Pass1
        "c=$Pass2,id=$Rig2",  ## Pass2
        "c=$Pass3,id=$Rig3",  ## Pass3
        $previous,            ## Previous
        $Stat.volume_hashrate ## Average Pool Hashrate
    )
}