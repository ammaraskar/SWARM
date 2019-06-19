function Global:set-minerconfig($ConfigMiner,$Logs) {
      
    $ConfigPathDir = Split-Path $ConfigMiner.Path
    if ($ConfigMiner.Devices -ne "none") {$MinerDevices = Global:Get-DeviceString -TypeDevices $ConfigMiner.Devices}
    else {
        $(vars).GCount = Get-Content ".\build\txt\devicelist.txt" | ConvertFrom-Json
        if($ConfigMiner.Type -like "*NVIDIA*"){$TypeS = "NVIDIA"}
        if($ConfigMiner.Type -like "*AMD*"){$TypeS = "AMD"}
        $MinerDevices = Global:Get-DeviceString -TypeCount $($(vars).GCount.$TypeS.PSObject.Properties.Value.Count)
    }
    $ConfigFile = @()

    switch ($ConfigMiner.DeviceCall) {
        "grin-miner" {
            $ConfigPath = "grin-miner.toml"
            $ConfigFile += "[logging]"
            $ConfigFile += "log_to_stdout = true"
            $ConfigFile += "stdout_log_level = `"Info`""
            $ConfigFile += "log_to_file = true"
            $ConfigFile += "log_file_path = `"$($Logs)`""
            $ConfigFile += "log_file_append = false"
            $ConfigFile += "file_log_level = `"Debug`""
            $ConfigFile += ""
            $ConfigFile += "[mining]"
            $ConfigFile += "run_tui = true"
            $ConfigFile += "stratum_server_addr = `"$($ConfigMiner.Host)`""
            $ConfigFile += "stratum_server_login = `"$($ConfigMiner.User)`""
            $ConfigFile += "stratum_server_password = `"x`""
            $ConfigFile += "stratum_server_tls_enabled = false"
            $ConfigFile += ""
            switch ($ConfigMiner.Algo) {
                "cuckaroo29" {
                    switch -WildCard ($ConfigMiner.Type) {
                        "*NVIDIA*" {
                            $MinerDevices | % {
                                $ConfigFile += "[[mining.miner_plugin_config]]"
                                $ConfigFile += "plugin_name = `"cuckaroo_cuda_29`""
                                $ConfigFile += "[mining.miner_plugin_config.parameters]"
                                $ConfigFile += "device = $($_)"
                                $ConfigFile += "cpuload = 1"
                                $ConfigFile += "ntrims = 176"
                                $ConfigFile += "genablocks = 4096"
                                $ConfigFile += "genatpb = 128"
                                $ConfigFile += "genbtpb = 128"
                                $ConfigFile += "trimtpb = 512"
                                $ConfigFile += "tailtpb = 1024"
                                $ConfigFile += "recoverblocks = 1024"
                                $ConfigFile += "recovertpb = 1024"
                                $ConfigFile += ""
                            }
                        }
                        "*AMD*" {
                            $MinerDevices | % {
                                $ConfigFile += "[[mining.miner_plugin_config]]"
                                $ConfigFile += "plugin_name = `"ocl_cuckaroo`""
                                $ConfigFile += "[mining.miner_plugin_config.parameters]"
                                $ConfigFile += "platform = 1"
                                $ConfigFile += "device = $($_)"
                                $ConfigFile += ""
                            }
                        }
                    }
                }
             "cuckatoo31"
             {
                $NDevices = Get-Content ".\build\txt\gpucount.txt"
                $NDevices = $NDevices | Select-String "VGA", "3D"
                $NDevices = $NDevices | Where {$_ -like "*NVIDIA*" -and $_ -notlike "*nForce*"}
                $MinerDevices | % {
                 $Current = $NDevices | Select -skip $($_) -First 1
                  if($Current -Like "*GTX*")
                  {
                    $ConfigFile += "[[mining.miner_plugin_config]]"
                    $ConfigFile += "plugin_name = `"cuckatoo_mean_cuda_gtx_31`""
                    $ConfigFile += "[mining.miner_plugin_config.parameters]"
                    $ConfigFile += "device = $($_)"
                    $ConfigFile += "expand = 3"
                    $ConfigFile += "cpuload = 1"
                    $ConfigFile += "ntrims = 176"
                    $ConfigFile += "genablocks = 4096"
                    $ConfigFile += "genatpb = 128"
                    $ConfigFile += "genbtpb = 128"
                    $ConfigFile += "trimtpb = 512"
                    $ConfigFile += "tailtpb = 1024"
                    $ConfigFile += "recoverblocks = 1024"
                    $ConfigFile += "recovertpb = 1024"
                    $ConfigFile += ""
                  }
                  if($Current -Like "*RTX*")
                  {
                    $ConfigFile += "[[mining.miner_plugin_config]]"
                    $ConfigFile += "plugin_name = `"cuckatoo_mean_cuda_rtx_31`""
                    $ConfigFile += "[mining.miner_plugin_config.parameters]"
                    $ConfigFile += "device = $($_)"
                    $ConfigFile += "expand = 3"
                    $ConfigFile += "cpuload = 1"
                    $ConfigFile += "ntrims = 176"
                    $ConfigFile += "genablocks = 4096"
                    $ConfigFile += "genatpb = 128"
                    $ConfigFile += "genbtpb = 128"
                    $ConfigFile += "trimtpb = 512"
                    $ConfigFile += "tailtpb = 1024"
                    $ConfigFile += "recoverblocks = 1024"
                    $ConfigFile += "recovertpb = 1024"
                    $ConfigFile += ""
                  }
                }
              }
            }
        }

    }
    $Config = Join-Path $ConfigPathDir $ConfigPath
    Write-Log "Settng Config File To $Config" -ForegroundColor Yellow
    $ConfigFile | Set-Content $Config
}

function Global:set-nicehash {
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [String]$NHPool,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$NHPort,
        [Parameter(Position = 2, Mandatory = $false)]
        [String]$NHUser,
        [Parameter(Position = 3, Mandatory = $false)]
        [String]$NHAlgo,
        [Parameter(Position = 4, Mandatory = $false)]
        [String]$CommandFile,
        [Parameter(Position = 5, Mandatory = $false)]
        [String]$NHDevices,
        [Parameter(Position = 6, Mandatory = $false)]
        [String]$NHCommands
    )
    ##apt-get install ocl-icd-libopencl1
    ##sudo dpkg -i excavator_1.5.13a-cuda10_amd64.deb
    ## run excavator nhmp.usa.nicehash.com:3200
    ##$NHPool = "nhmp.usa.nicehash.com"
    ##$NHPort = 3200
    ##$NHUser = "34HKWdzLxWBduUfJE9JxaFhoXnfC6gmePG.testrig"
    ##$NHAlgo = "equihash"
    ##$CommandFile = ".\bin\excavator-1\command.json"
    ##$NHDevices = "0,2,6,9,10"

    $NHMDevices = Global:Get-DeviceString -TypeDevices $NHDevices
    $Workers = @()
    if ($NHCommands) {
        $Workers += $NHCommands | ConvertFrom-Json
    }
    $Workers += @{time = 0; commands = @(@{id = 1; method = "subscribe"; params = [array]"$($NHPool):$($NHPort)", "$($NHUser)"})}
    $Workers += @{time = 2; commands = @(@{id = 1; method = "algorithm.add"; params = @($NHAlgo)})}
    $NHMDevices | foreach {$Workers += @{time = 3; commands = @(@{id = 1; method = "worker.add"; params = [array]"$NHAlgo", "$($_)"; })}}
    $NHMDevices | Foreach {$Workers += @{time = 10; loop = 10; commands = @(@{id = 1; method = "worker.print.speed"; params = @("$($_)")})}}

    $Workers | ConvertTo-Json -Depth 4 | Set-Content $CommandFile

}