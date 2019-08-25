function Global:Get-StatsExcavator {

    $Message = @{id = 1; method = "algorithm.list"; params = @() } | ConvertTo-Json -Compress
    $Request = Global:Get-TCP -Server $global:Server -Port $global:Port -Message $Message
    if ($Request) {
        try { $Data = $Null; $Data = $Request | ConvertFrom-Json -ErrorAction Stop; }
        catch { Write-Host "Failed To parse API" -ForegroundColor Red; break }
        $global:RAW = $Summary.algorithms.speed
        $global:TypeHashes.$($Global:MinerType) = $global:RAW
        Global:Write-MinerData2;
        $global:GPUKHS += [Double]$Summary.algorithms.speed / 1000
    }
    else { Global:Set-APIFailure; Break }

    $Message = @{id = 1; method = "worker.list"; params = @() } | ConvertTo-Json -Compress
    $GetThreads = $Null; $GetThreads = Global:Get-TCP -Server $global:Server -Port $global:Port -Message $Message
    if ($GetThreads) {
        $Threads = $GetThreads | ConvertFrom-Json -ErrorAction Stop
        $Hash = $Null; $Hash = $Threads.workers.algorithms.speed
        try { 
            for ($global:i = 0; $global:i -lt $Devices.Count; $global:i++) { 
                $global:GPUHashrates.$(Global:Get-GPUs) = (Global:Set-Array $Hash $global:i) / 1000 
            } 
        }
        catch { Write-Host "Failed To parse threads" -ForegroundColor Red }
        $global:MinerACC = $Summary.algorithms.accepted_shares
        $global:MinerREJ = $Summary.algorithms.rejected_shares
        $global:ALLACC += $global:MinerACC
        $global:ALLREJ += $global:MinerREJ
    }
    else { Write-Host "API Threads Failed"; break }
}