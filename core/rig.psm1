Using namespace System;
Using namespace System.Text;
Using namespace System.Diagnostics;
Using module ".\process.psm1";
Using module ".\helper.psm1";
Using module ".\motherboard.psm1";
Using module ".\disk.psm1";
Using module ".\ram.psm1";
Using module ".\cpu.psm1";
Using module ".\gpu.psm1";

if (-not $Global:DIR) { $Global:Dir = (Convert-Path ".") }

## Placeholder
## This will probably be done in separate psm1
class MINER {

}

## Placeholder
## This will probably be done in separate psm1
class STATS {
    [Hashtable]$Miners
    [Hashtable]$Pools
    [Hashtable]$Power
    [Hashtable]$Wallets
}

## Placeholder
## This will probably be done in separate psm1
class CONFIG {
    [hashtable]$config;
    [hashtable]$wallet;
    [hashtable]$params;
}

## Base Class For RIG.
## After Constructed, Used To Send 'hello' to HiveOS
class RIG {
    [CPU]$cpu = [CPU]::New();
    [MOTHERBOARD]$mb = [MOTHERBOARD]::New();
    [DISK]$disk = [DISK]::New();
    [RAM]$ram = [RAM]::New();
    [DEVICE_GROUP[]]$Groups;
    [Array]$gpus = @(); ##Mix of nvidia and amd cards
    [Hashtable]$net_interfaces = @{ };
    [hashtable]$lan_config = @{ };
    [String]$version;
    [String]$nvidia_version;
    [String]$amd_version;
    [String]$gpu_count_nvidia;
    [String]$gpu_count_amd;
    [String]$uid;
    [String]$openvpn;
    [String]$kernel;
    [string[]]$ip
    [String]$boot_time;

    RIG() {
        ## Kernel
        $this.kernel = [RIG_RUN]::get_kernel();

        ## Net Interfaces & uid
        [hashtable]$data = [RIG_RUN]::uid();
        $this.net_interfaces = $data.net_interfaces;
        $this.uid = $data.uid;

        ## AMD Driver
        $this.amd_version = [AMD_RUN]::get_driver();

        ## NVIDIA Driver
        ## Nvidia NVML
        if ($Global:IsWindows) { [NVIDIA_RUN]::get_nvml() }
        $this.nvidia_version = [NVIDIA_RUN]::get_driver();

        ## Boot Time
        $this.boot_time = [RIG_RUN]::get_uptime();

        ## IPs
        $this.ip = [RIG_RUN]::get_ip();

        ## LAN config
        $this.lan_config = [RIG_RUN]::get_lan();

        ## Version
        [string]$Path = Join-Path $Global:Dir "h-manifest.conf"
        $this.version = ([filedata]::stringdata("$($Path)")).CUSTOM_VERSION

        ## Get GPU Information
        $this.gpus = [RIG_RUN]::get_gpus();
        $this.gpu_count_amd = ($this.gpus | Where { $_ -is [AMD_CARD] }).count
        $this.gpu_count_nvidia = ($this.gpus | Where { $_ -is [NVIDIA_CARD] }).count

    }

    ## Returns JSON for hello method.
    [string] hello () {
        $hello = @{ }
        $get_cpu = $this.cpu;
        $get_cpu.cores = $get_cpu.cores.ToString();
        $get_cpu = $get_cpu | Select -ExcludeProperty features
        $Hello.Add("cpu", $get_cpu);
        $Hello.Add("version", $this.version);
        $Hello.Add("nvidia_version", $this.nvidia_version);
        $Hello.Add("amd_version", $this.amd_version);
        $Hello.Add("gpu_count_nvidia", $this.gpu_count_nvidia);
        $Hello.Add("gpu_count_amd", $this.gpu_count_amd);
        $get_gpu = $this.gpus | Select -ExcludeProperty PCI_SLOT, Device, Speed, Temp, Fan, Wattage
        $Hello.Add("gpu", $get_gpu);
        $Hello.Add("uid", $this.uid);
        $Hello.Add("disk_model", $this.disk.disk_model);
        $Hello.Add("mb", $this.mb);
        $Hello.Add("net_interfaces", $this.net_interfaces);
        $Hello.Add("kernel", $this.kernel);
        $Hello.Add("ip", $this.ip);
        $Hello.Add("boot_time", $this.boot_time);
        return $Hello | ConvertTo-Json -Depth 5 -Compress;
    }
}

## Used in SWARM, adds additional items to RIG for tracking.
class SWARM_RIG : RIG {
    [Stats]$Stats;
    [DEVICE_GROUP[]]$Device_Groups;
}

## Device Groups Used To Execute Miner.
class DEVICE_GROUP {
    [String]$Name #User denoted name of group
    [String]$Device #Device this is (NVIDIA,AMD,CPU,ASIC)
    [String]$Hashrate #Current Hashrate
    [Miner]$Miner #Current Miner
    [Int]$Accepted ## Miner Current Accepted Shares
    [Int]$Rejected ## Miner Current Rejected Shares
    [Int]$Rej_Percent ## Rejection Percent
    [Array]$Devices = @() ## Can be AMD cards, NVIDIA cards, ASIC, CPU

    Add_GPU($GPU) {
        $this.Devices += $GPU
        $this.Device = $GPU.Brand
    }

    Add_Thread([Thread]$Thread) {
        $this.Devices += $Thread
        $this.Device = $Thread.Brand
    }
}

class RIG_RUN {
    ## Get GPU information
    static [Array] get_gpus() {
        ## this runs gpu-detect, which is a script that users can run.
        $gpus = . $env:SWARM_DIR\scripts\gpu_check.ps1 swarm
        return $gpus
    }
    ## Get lan information
    static [hashtable] get_lan() {
        $lan = @{ }
        if ($Global:ISLinux) {
            $dhcp = [IO.File]::ReadAllLines("/etc/systemd/network/20-ethernet.network") | Select-String "DHCP=No"
            if ($dhcp) { $lan_dhcp = 1 }else { $lan_dhcp = 0 }
            $lan_address = invoke-expression "ip -o -f inet addr show | grep eth0 | awk `'/scope global/ {print `$4}`'"
            $lan_gateway = invoke-expression "ip route | awk `'/default/ && /eth0/ { print `$3 }`' | head -1"
            $lan_dns = invoke-expression "cat /run/systemd/resolve/resolv.conf | grep -m1 ^nameserver | awk `'{print `$2}`'"
            $lan.Add("dhcp", $lan_dhcp)
            $lan.Add("address", $lan_address)
            $lan.Add("gateway", $lan_gateway)
            $lan.Add("dns", $lan_dns)
        }
        elseif ($Global:IsWindows) {
            $ipconfig = invoke-expression "ipconfig /all"
            [string]$dhcp = $($ipconfig | Select-String "DHCP Enabled")
            $get_dhcp = 1
            switch ($dhcp.split(": ") | Select -Last 1) { "Yes" { $get_dhcp = 1 }; "No" { $get_dhcp = 0 } }
            [string]$lan_address = $($ipconfig | Select-String "IPv4 Address")
            $address = ($lan_address.split(": ") | Select -Last 1).Replace("`(Preferred`)", "")
            [string]$lan_gateway = $ipconfig | Select-String "Default Gateway"
            $gateway = ($lan_gateway.split(": ") | Select -Last 1)
            [string]$lan_dns = $ipconfig | Select-String "DNS Servers"
            $dns = ($lan_dns.split(": ") | Select -Last 1)
            $lan.Add("dhcp", $get_dhcp)
            $lan.Add("address", $address)
            $lan.Add("gateway", $gateway)
            $lan.Add("dns", $dns)
        }
        return $lan;
    }
    ## Get IP information
    static [string[]] get_ip() {
        [string[]]$ip = @()
        if ($Global:IsWindows) {
            $ip_host = [System.Net.DNS]::GetHostName()
            $ip_addresses = ([System.Net.DNS]::GetHostEntry($ip_host)).AddressList
            $get_ip = $($ip_addresses | Where AddressFamily -eq "InterNetwork").IPAddressToString
            $get_ip | foreach { $ip += "$($_)" }
        }
        elseif ($GLobal:IsLinux) {
            $get_ip = invoke-expression "hostname -I | sed `'s`/ `/`\n`/g`'"
            $get_ip | foreach { if ([string]$_ -ne "") { $ip += "$($_)" } }
        }
        return $ip;
    }
    ## Gets uptime
    static [string] get_uptime() {
        [string]$boot_time = "";
        if ($global:IsWindows) {
            $BootTime = $((Get-CimInstance -ClassName win32_operatingsystem | select lastbootuptime).lastbootuptime);
            $Get_Uptime = (New-TimeSpan -Start (Get-Date "01/01/1970") -End ($BootTime.ToUniversalTime())).TotalSeconds;
            $boot_time = ([Math]::Round($Get_Uptime)).ToString();
        }
        elseif ($Global:IsLinux) {
            $date = invoke-expression 'date +%s';
            $time = ([IO.File]::ReadAllText("/proc/uptime")).split(" ") | Select -First 1;
            $boot_time = ([math]::Round($date - $time, 0)).ToString();
        }        
        return $boot_time
    }
    ## Get OS kernel version
    static [string] get_kernel() {
        $kernel = "unknown"
        if ($Global:IsLinux) {
            $get_kernel = invoke-expression "uname --kernel-release";
            if ($get_kernel) { 
                $kernel = $get_kernel 
            }
        }
        elseif ($Global:ISWindows) {
            $get_version = [System.Environment]::OSVersion.Version
            $kernel = "$($get_version.Major).$($get_version.Minor).$($get_version.Build)"
        }        
        return $kernel;
    }
    ## Gets uid (and net interfaces needed for uid)
    static [hashtable] uid() {
        $data = @{ }
        $data.Add("net_interfaces", @{ })
        $data.Add("uid", "")

        if ($Global:IsWindows) {
            $mac = (Get-CimInstance win32_networkadapterconfiguration | where { $_.IPAddress -ne $null } | select MACAddress).MacAddress
            $Data.net_interfaces.Add("mac", $mac)
            $get_uid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID
            $Get = (Get-NetAdapter -Physical | Where Status -eq "Up").Name
            $iface = "eth0"
            switch ($Get) {
                "Ethernet" { $iface = "eth0" }
                "Wi-Fi" { $iface = "wlan0" }
            }
            $data.net_interfaces.Add("iface", $iface)
            $get_mac = ($mac.replace(":", "").ToLower())
            $cpu_id = (Get-CimInstance -Class Win32_processor).ProcessorId.ToLower()
            $get_uid = "$get_uid-$cpu_id-$get_mac"
            $StringBuilder = [StringBuilder]::New()
            [System.Security.Cryptography.HashAlgorithm]::Create('SHA1').ComputeHash([Encoding]::UTF8.GetBytes($get_uid)) | % { [Void]$StringBuilder.Append($_.ToString("x2")) }; 
            $data.uid = $StringBuilder.ToString()     
        }
        elseif ($Global:ISLinux) {
            $net = invoke-expression "ip -o link | grep -vE 'LOOPBACK|POINTOPOINT|sit0|can0|docker|sonm|ifb'" 
            $iface = $($net.split(":") | Select -Skip 1 -First 1) -replace " ", ""
            $data.net_interfaces.Add("iface", $iface)
            $mac = $($net.split(" "))
            $mac = $mac | Select -Skip ($mac.count - 3) -First 1
            $data.net_interfaces.Add("mac", $mac)
            $get_uid = invoke-expression 'dmidecode -s system-uuid'
            $cpu_id = invoke-expression "dmidecode -t 4 | grep ID | sed `'s`/.`*ID:`/`/`;s`/ `/`/g`'"
            $get_mac = $data.net_interfaces.mac.replace(":", "").ToLower()
            $get_uid = "$get_uid-$cpu_id-$get_mac"
            $StringBuilder = [StringBuilder]::New()
            [System.Security.Cryptography.HashAlgorithm]::Create('SHA1').ComputeHash([Encoding]::UTF8.GetBytes($get_uid)) | % { [Void]$StringBuilder.Append($_.ToString("x2")) }; 
            $data.uid = $StringBuilder.ToString()     
        }
        return $data
    }

    static [void] list_gpus() {
        $data = ""
        if ($Global:IsLinux) {
            $data = [Proc_Data]::Read((Join-Path $env:SWARM_DIR "linux\gpu_check"), $null, "list", 0);
        }
        elseif ($Global:IsWindows) {
            $data = [Proc_Data]::Read((Join-Path $env:SWARM_DIR "win\gpu_check.bat"), $null, "list", 0);
        }
        if ($Global:Log) {
            $Global:log.screen($data);
        } 
        else {
            $data | ForEach-Object { Write-Host $_ };
        }
    }
}
