using module ".\logging.psm1"

class booting {
    static [void] crashreporting() {
        $boot = $null
        if ($global:IsWindows) {
            Get-CimInstance -ClassName win32_operatingsystem | 
                Select-Object lastbootuptime | 
                ForEach-Object { 
                    $Boot = [math]::Round(((Get-Date) - $_.LastBootUpTime).TotalSeconds) 
                }
        }
        elseif ($global:IsLinux) {
            $Boot = cat "/proc/uptime" | ForEach-Object { $_ -split " " | Select-Object -First 1 } 
        }
        if ([Double]$Boot -lt 600) {
            $logs = ".\logs"
            $debug = ".\build\txt"
            [log]::info("SWARM was started in 600 seconds of last boot. Generating a crash report to logs directory","Yellow")
            $Report = "crash_report_$(Get-Date)";
            $Report = $Report | ForEach-Object { $_ -replace ":", "_" } | ForEach-Object { $_ -replace "\/", "-" } | ForEach-Object { $_ -replace " ", "_" };
            New-Item -Path $logs -Name $Report -ItemType "Directory" | Out-Null;
            Get-ChildItem $debug | Copy-Item -Destination ".\logs\$Report";
            $TypeLogs = @("NVIDIA1", "AMD1", "NVIDIA2", "NVIDIA3", "CPU")
            Get-ChildItem "logs" | Where BaseName -in $TypeLogs | Foreach-Object { Copy-Item -Path $_.FullName -Destination ".\logs\$Report" | Out-Null }
            Get-ChildItem "logs" | Where BaseName -like "*miner*" | Foreach-Object { Copy-Item -Path $_.FullName -Destination ".\logs\$Report" | Out-Null }
            Start-Sleep -S 3
        } else {
            [log]::info("methods")
        }
    }
}

class SWARM {
}