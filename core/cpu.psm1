Using namespace System;
Using module ".\process.psm1";

## Mining Threads for CPU
class THREAD {
    [String]$Brand = "CPU"
    [Decimal]$Speed; #Current Hashrate
    [Int]$Temp = 0; #Current Temperature Not Used Yet
    [Int]$Fan = 0; #Current Fan Speed Not Used Yet
    [Int]$Wattage = 0; #Current Wattage Not Used Yet
}

class CPU {
    [string]$aes;
    [string]$model;
    [string]$cpu_id;
    [int]$cores;
    [hashtable]$features;

    CPU() {
        $this.Model = [CPU_RUN]::Get_Model();
        $this.Cores = [CPU_RUN]::Get_Cores();
        $this.Aes = [CPU_RUN]::Get_AES();
        $this.cpu_id = [CPU_RUN]::Get_CpuId();
        $this.features = [CPU_RUN]::Get_Features();
    }
}

class CPU_RUN {
    static [string] Get_Model() {
        [string]$model = "unknown"
        if ($global:IsLinux) {
            $model = "lscpu | grep `"Model name:`" | sed `'`s`/Model name:[ `\t]`*`/`/g`'"
        }
        if ($global:IsWindows) {
            $model = (Get-CimInstance -Class Win32_processor).Name.Trim()
        }
        return $model
    }

    static [Int] Get_Cores() {
        $get = "0"
        if ($global:IsLinux) {
            $Get = Invoke-Expression "lscpu | grep `"`^CPU(s):`" | sed `'s`/CPU(s):[ `\t]`*`/`/`g`'"
        }
        if ($global:IsWindows) {
            $Get = (Get-CimInstance -Class Win32_processor).NumberOfCores
        }
        [int]$cores = $Get
        return $cores
    }

    static [string] Get_AES() {
        [string]$HasAES = "1";
        if ($global:IsLinux) {
            Invoke-Expression "lscpu | grep `"`^Flags:`.`*aes`" | wc -l"
        }
        if ($global:IsWindows) {
            $get_features = [Proc_Data]::Read("$env:SWARM_DIR\apps\features\features.exe", $null, $null, 0);
            $Get_AES = "No";
            if ($get_features.count -gt 0) {
                $get_features = $get_features | Select-Object -Skip 1 | ConvertFrom-StringData
                $Get_AES = $get_features."AES-NI"
            }
            if ($Get_AES -eq "Yes") { $HasAES = 1 }else { $HasAES = 0 }
        }
        return $HasAES;
    }

    static [string] Get_CpuId() {
        [string]$cpuid = "unknown"
        if ($global:IsLinux) {
            $cpuid = "$(Invoke-Expression "dmidecode -t 4" | Select-String "ID: " | ForEach-Object{$_ -split "ID: " | Select-Object -Last 1})" -replace " ", ""
        }
        if ($global:IsWindows) {
            $cpuid = (Get-CimInstance -Class Win32_processor).ProcessorId
        }
        return $cpuid
    }

    static [hashtable] Get_Features() {
        $hash = [hashtable]::New()
        if ($global:ISWindows) {
            $get_features = [Proc_Data]::Read("$env:SWARM_DIR\apps\features\features.exe", $null, $null, 0);
            if ($get_features.count -gt 0) {
                $get_features = $get_features | Select-Object -Skip 1 | ConvertFrom-StringData
                foreach ($key in $get_features.keys) {
                    $hash.Add($key, $get_features.$key)
                }    
            }
        }
        return $hash;
    }
}