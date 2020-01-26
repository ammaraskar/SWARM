Using module ".\process.psm1";

## Base class for video card
class VIDEO_CARD {
    [String]$busid; 
    [String]$name;
    [String]$brand;

    VIDEO_CARD($Busid, $Name, $Brand) {
        $this.busid = $Busid;
        $this.name = $Name;
        $this.brand = $Brand;
    }
}

## A NVIDIA gpu
class NVIDIA_CARD {
    [String]$busid; 
    [String]$name;
    [String]$brand;
    [String]$subvendor;
    [String]$mem;
    [String]$vbios;
    [string]$plim_min;
    [string]$plim_def;
    [string]$plim_max;
    [Int]$PCI_SLOT;
    [Int]$Device;
    [Decimal]$Speed = 0.0;
    [Int]$Temp = 0;
    [Int]$Current_Fan = 0;
    [Int]$Wattage = 0;
    [Int]$Fan_Speed = 0;
    [Int]$Power_Limit = 0;
    [int]$Core_Clock = 0;
    [int]$Mem_Clock = 0;

    NVIDIA_CARD (
        [VIDEO_CARD]$card, 
        [string]$Subvendor, 
        [string]$Mem, 
        [string]$Vbios, 
        [string]$Plim_min, 
        [string]$Plim_def, 
        [string]$Plim_max
    ) {
        $this.busid = $card.busid;
        $this.name = $card.name;
        $this.brand = $card.brand;
        $this.subvendor = $Subvendor
        $this.mem = $Mem;
        $this.vbios = $Vbios;
        $this.plim_min = $Plim_min;
        $this.plim_def = $Plim_def;
        $this.plim_max = $Plim_max;
    }
}

## A AMD gpu
class AMD_CARD {
    [String]$busid; 
    [String]$name;
    [String]$brand;
    [String]$subvendor
    [String]$mem
    [String]$vbios
    [String]$mem_type
    [Int]$PCI_SLOT;
    [Int]$Device;
    [Decimal]$Speed;
    [Int]$Temp = 0;
    [Int]$Current_Fan = 0;
    [Int]$Wattage = 0;
    [int]$Core_Clock = 0;
    [int]$Core_Voltage = 0;
    [int]$Core_State = 0;
    [int]$Mem_Clock = 0;
    [int]$Mem_State = 0;
    [int]$Fan_Speed = 0;
    [int]$REF = 0;

    AMD_CARD($card, $Subvendor, $Mem, $Vbios, $Mem_Type) {
        $this.busid = $card.Busid;
        $this.name = $card.Name;
        $this.brand = $card.Brand;
        $this.subvendor = $Subvendor
        $this.mem = $Mem;
        $this.vbios = $Vbios;
        $this.mem_type = $Mem_Type;
    }
}

## NVIDIA specific
class NVIDIA_RUN {

    static [string] get_driver() {
        $driver = "0.0"
        $smi_path = "/usr/bin/nvidia-smi"
        if ($Global:IsWindows) {
            $smi_path = Join-Path $env:ProgramFiles "NVIDIA Corporation\NVSMI\nvidia-smi.exe"
        }
        $check = [IO.File]::Exists($smi_path)
        if ($check) {
            ## nvidia-smi -h causes [System.Diagnostics.Process] waitforexit() to lock up.
            ## It is the only instance in which it does.
            $run = "$smi_path -h"
            if($Global:IsWindows){$run = ". '$smi_path' -h"}
            $nvidia_smi = invoke-expression $run
            $driver = $nvidia_smi[0].split("-- v") | Select -Last 1
        }
        return $driver;
    }

    static [void] get_nvml() {
        ## Check for NVIDIA-SMI and nvml.dll in system32. If it is there- copy to NVSMI
        $x86_driver = Join-Path ${env:ProgramFiles(x86)} "NVIDIA Corporation"
        $x64_driver = Join-Path $env:ProgramFiles "NVIDIA Corporation"
        $x86_NVSMI = Join-Path $x86_driver "NVSMI"
        $x64_NVSMI = Join-Path $x64_driver "NVSMI"
        $smi = Join-Path $env:windir "system32\nvidia-smi.exe"
        $nvml = Join-Path $env:windir "system32\nvml.dll"

        ## Set the device order to match the PCI bus if NVIDIA is installed
        if ([IO.Directory]::Exists($x86_driver) -or [IO.Directory]::Exists($x64_driver)) {
            $Target1 = [System.EnvironmentVariableTarget]::Machine
            $Target2 = [System.EnvironmentVariableTarget]::Process
            [Environment]::SetEnvironmentVariable("CUDA_DEVICE_ORDER", "PCI_BUS_ID", $Target1)
            [Environment]::SetEnvironmentVariable("CUDA_DEVICE_ORDER", "PCI_BUS_ID", $Target2)
        }

        if ( [IO.Directory]::Exists($x86_driver) ) {
            if (-not [IO.Directory]::Exists($x86_NVSMI)) { [IO.Directory]::CreateDirectory($x86_NVSMI) | Out-Null }
            $dest = Join-Path $x86_NVSMI "nvidia-smi.exe"
            try { [IO.File]::Copy($smi, $dest, $true) | Out-Null } catch { }
            $dest = Join-Path $x86_NVSMI "nvml.dll"
            try { [IO.File]::Copy($nvml, $dest, $true) | Out-Null } catch { }
        }

        if ( [IO.Directory]::Exists($x64_driver) ) {
            if (-not [IO.Directory]::Exists($x64_NVSMI)) { [IO.Directory]::CreateDirectory($x64_NVSMI) | Out-Null }
            $dest = Join-Path $x64_NVSMI "nvidia-smi.exe"
            try { [IO.File]::Copy($smi, $dest, $true) | Out-Null } catch { }
            $dest = Join-Path $x64_NVSMI "nvml.dll"
            try { [IO.File]::Copy($nvml, $dest, $true) | Out-Null } catch { }
        }
    }
}

## AMD Specific
class AMD_RUN {
    static [string] get_driver() {
        $driver = "0.0"
        if ($global:IsWindows) {
            [string]$aMDPnPId = 'pci\\ven_1002.*';
            [string]$DriverName = 'RadeonSoftwareVersion';
            [string]$regKeyName = 'SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}';
            $reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default);
            $key = $reg.OpenSubKey($regKeyName, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadSubTree);
            ForEach ($subKey in $key.GetSubKeyNames()) {
                if ($subKey -match '\d{4}') {
                    $driver_gpu = $key.OpenSubKey($subKey, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadSubTree);
                    if ($driver_gpu) {
                        $pnPId = $driver_gpu.GetValue("MatchingDeviceId");
                        if ($pnPId -match $aMDPnPId ) {
                            $gpukey = $key.OpenSubKey($subKey, $true);
                            $driver = $gpukey.GetValue($DriverName);                         
                        }
                    }
                }
            }
        }
        if ($Global:IsLinux) {
            $driver = Invoke-Expression "dpkg -s amdgpu-pro 2>&1 | grep `'^Version: `' | sed `'s/Version: //`' | awk -F`'-`' `'{print `$1}`'";
            if ([string]$driver -eq "") { $driver = invoke-expression "dpkg -s amdgpu 2>&1 | grep `'^Version: `' | sed `'s/Version: //`' | awk -F`'-`' `'{print `$1}`'" };
            if ([string]$Driver -eq "") { $driver = Invoke-Expression "dpkg -s opencl-amdgpu-pro-icd 2>&1 | grep `'^Version: `' | sed `'s/Version: //`' | awk -F`'-`' `'{print `$1}`'" };
        }
        return $driver;
    }
}