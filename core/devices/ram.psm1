class RAM {
    [string]$total_space
    [string]$used_space

    RAM() {
        $this.total_space = [RAM_RUN]::Get_Total()
        $this.used_space = [RAM_RUN]::Get_Used()
    }
}

## methods for disk actions
class RAM_RUN {
    static [string] Get_Total() {
        [string]$total_space = $(
            if ($global:ISLinux) {
                Get-Content '/proc/meminfo' | Select-String "MemTotal:" | ForEach-Object { $($_ -split 'MemTotal:\s+' | Select-Object -Last 1).replace(" kB", "") }
            }
            if ($global:IsWindows) {
                [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1MB, 0)
            }
        )
        return $total_space
    }
    static [string] Get_Used() {
        [string]$used_space = $(
            if ($global:IsLinux) {
                [math]::Round((Get-Content '/proc/meminfo' | Select-String "MemFree:" | ForEach-Object { $($_ -split 'MemFree:\s+' | Select-Object -Last 1).replace(" kB", "") }) / 1KB, 0)
            }
            if ($global:IsWindows) {
                [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1MB, 0) - [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1KB, 0)
            }
        )
        return $used_space
    }
}