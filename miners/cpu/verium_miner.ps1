$(vars).CPUTypes | ForEach-Object {
    
    $ConfigType = $_;

    ##Miner Path Information
    if ($(vars).cpu.verium_miner.$ConfigType) { $Path = "$($(vars).cpu.verium_miner.$ConfigType)" }
    else { $Path = "None" }
    if ($(vars).cpu.verium_miner.uri) { $Uri = "$($(vars).cpu.verium_miner.uri)" }
    else { $Uri = "None" }
    if ($(vars).cpu.verium_miner.minername) { $MinerName = "$($(vars).cpu.verium_miner.minername)" }
    else { $MinerName = "None" }

    $Name = "verium_miner";

    ##Log Directory
    $Log = Join-Path $($(vars).dir) "logs\$ConfigType.log"

    ##Parse -CPUThreads
    if ($(arg).CPUThreads -ne '') { $Devices = $(arg).CPUThreads }

    ##Get Configuration File
    $MinerConfig = $Global:config.miners.verium_miner

    ##Export would be /path/to/[SWARMVERSION]/build/export##
    $ExportDir = Join-Path $($(vars).dir) "build\export"
    $Miner_Dir = Join-Path ($(vars).dir) ((Split-Path $Path).replace(".", ""))

    ##Prestart actions before miner launch
    $Prestart = @()
    if ($IsLinux) { $Prestart += "export LD_PRELOAD=$(Join-Path $(vars).Dir "build\export\libcurl.so.3")" }    
    $PreStart += "export LD_LIBRARY_PATH=$ExportDir`:$Miner_Dir"
    if ($IsLinux) { $Prestart += "export DISPLAY=:0" }
    $MinerConfig.$ConfigType.prestart | ForEach-Object { $Prestart += "$($_)" }

    if ($(vars).Coins) { $Pools = $(vars).CoinPools } else { $Pools = $(vars).AlgoPools }

    if ($(vars).Bancount -lt 1) { $(vars).Bancount = 5 }

    $MinerConfig.$ConfigType.commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {

        $MinerAlgo = $_

        if ( 
            $MinerAlgo -in $(vars).Algorithm -and 
            $Name -notin $global:Config.Pool_Algos.$MinerAlgo.exclusions -and 
            $ConfigType -notin $global:Config.Pool_Algos.$MinerAlgo.exclusions -and 
            $Name -notin $(vars).BanHammer
        ) {
            $StatAlgo = $MinerAlgo -replace "`_", "`-"
            $Stat = Global:Get-Stat -Name "$($Name)_$($StatAlgo)_hashrate" 
            if ($(arg).Rej_Factor -eq "Yes" -and $Stat.Rejections -gt 0 -and $Stat.Rejection_Periods -ge 3) { $HashStat = $Stat.Hour * (1 - ($Stat.Rejections * 0.01)) }
            else { $HashStat = $Stat.Hour }
            $Pools | Where-Object Algorithm -eq $MinerAlgo | ForEach-Object {
                if ($MinerConfig.$ConfigType.difficulty.$($_.Algorithm)) { $Diff = ",d=$($MinerConfig.$ConfigType.difficulty.$($_.Algorithm))" }else { $Diff = "" }
                [PSCustomObject]@{
                    MName      = $Name
                    Coin       = $(vars).Coins
                    Delay      = $MinerConfig.$ConfigType.delay
                    Fees       = $MinerConfig.$ConfigType.fee.$($_.Algorithm)
                    Symbol     = "$($_.Symbol)"
                    MinerName  = $MinerName
                    Prestart   = $PreStart
                    Type       = $ConfigType
                    Path       = $Path
                    Devices    = $Devices
                    Stratum    = "$($_.Protocol)://$($_.Pool_Host):$($_.Port)" 
                    Version    = "$($(vars).cpu.verium_miner.version)"
                    DeviceCall = "cpuminer-opt"
                    Arguments  = "--cpu-affinity AAAA -q -o stratum+tcp://$($_.Pool_Host):$($_.Port) -b 0.0.0.0:10001 -u $($_.User1) -p $($_.Pass1)$($Diff) $($MinerConfig.$ConfigType.commands.$($_.Algorithm))"
                    HashRates  = $Stat.Hour
                    Worker     = $(arg).Rigname1
                    Quote      = if ($HashStat) { $HashStat * ($_.Price) }else { 0 }
                    Rejections = $Stat.Rejections
                    Power      = if ($(vars).Watts.$($_.Algorithm)."$($ConfigType)_Watts") { $(vars).Watts.$($_.Algorithm)."$($ConfigType)_Watts" }elseif ($(vars).Watts.default."$($ConfigType)_Watts") { $(vars).Watts.default."$($ConfigType)_Watts" }else { 0 } 
                    MinerPool  = "$($_.Name)"
                    Port       = 10001
                    API        = "cpuminer"
                    Wallet     = "$($_.User1)"
                    URI        = $Uri
                    Server     = "localhost"
                    Algo       = "$($_.Algorithm)"
                    Log        = $Log 
                }            
            }
        }
    }
}