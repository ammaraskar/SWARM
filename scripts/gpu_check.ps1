#! /usr/bin/pwsh
Using namespace System;
Using module "..\core\colors.psm1";
Using module "..\core\process.psm1";
Using module "..\core\gpu.psm1";

Set-Location $env:SWARM_DIR

$lspci_file = Join-Path $env:SWARM_DIR "debug\lspci.txt";

if ($IsWindows) {
    $smi_path = Join-Path $env:ProgramFiles "NVIDIA Corporation\NVSMI\nvidia-smi.exe"
    $lspci_exe = Join-Path $env:SWARM_DIR "apps\pci-win\lspci.exe"
}
elseif ($IsLinux) {
    $smi_path = "/usr/bin/nvidia-smi"
    $lspci_exe = "/usr/bin/lspci"
}


class Win_Loader {
    ## This is labeled 'object', because I have seen it convert
    ## it to two different types before, and I don't know
    ## why. Forcing it to a type can draw an error.
    static [object] GPUZ([string[]]$lspci, [string]$lspci_file) {
        [String[]]$old_gpu_list = $null;
        [bool]$check_file = [IO.File]::Exists($lspci_file);
        [string[]]$old_gpu_list = if ($check_file) { [IO.File]::ReadLines($lspci_file); }
        [string[]]$new_gpu_list = $lspci | Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" };
        [string]$file = Join-Path $env:SWARM_DIR "debug\lspci.txt"
        [string]$exe = Join-Path $env:SWARM_DIR "apps\gpu-z\gpu-z.exe"
        [string]$xml = Join-Path $env:SWARM_DIR "debug\data.xml"

        ## Write lscpi to file
        [IO.File]::WriteAllLines($file, $new_gpu_list);

        ## Start GPU-Z if needed
        if ([string]$new_gpu_list -ne [string]$old_gpu_list) {
            $reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::CurrentUser, [Microsoft.Win32.RegistryView]::Default)
            if (-not ($reg.OpenSubKey("Software\techPowerUp"))) {
                $reg.CreateSubKey("Software\techPowerUp\GPU-Z")
                $key = $reg.OpenSubKey("Software\techPowerUp\GPU-Z", $true)
                $key.SetValue("Install_Dir", "no", [Microsoft.Win32.RegistryValueKind]::String);
            }
            if (-not ([IO.Directory]::Exists("debug"))) { [IO.Directory]::CreateDirectory("debug") | Out-Null }
            $proc = Start-Process -Path $exe -ArgumentList "-dump $xml" -PassThru
            $proc | Wait-Process
        }

        ## Get GPU-Z Data
        $Data = ([xml]([IO.File]::ReadLines("$xml"))).gpuz_dump.card;
        foreach ($Card in $Data) {
            switch ($card.location) {
                "0:2:2" { $card.location = "00:02.0" }
                "1:0:0" { $card.location = "01:00.0" }
                "2:0:0" { $card.location = "02:00.0" }
                "3:0:0" { $card.location = "03:00.0" }
                "4:0:0" { $card.location = "04:00.0" }
                "5:0:0" { $card.location = "05:00.0" }
                "6:0:0" { $card.location = "06:00.0" }
                "7:0:0" { $card.location = "07:00.0" }
                "8:0:0" { $card.location = "08:00.0" }
                "9:0:0" { $card.location = "09:00.0" }
                "10:0:0" { $card.location = "0a:00.0" }
                "11:0:0" { $card.location = "0b:00.0" }
                "12:0:0" { $card.location = "0c:00.0" }
                "13:0:0" { $card.location = "0d:00.0" }
                "14:0:0" { $card.location = "0e:00.0" }
                "15:0:0" { $card.location = "0f:00.0" }
                "16:0:0" { $card.location = "0g:00.0" }
                "17:0:0" { $card.location = "0h:00.0" }
                "18:0:0" { $card.location = "0i:00.0" }
                "19:0:0" { $card.location = "0j:00.0" }
                "20:0:0" { $card.location = "0k:00.0" }
                "21:0:0" { $card.location = "0l:00.0" }
                "22:0:0" { $card.location = "0m:00.0" }
                "23:0:0" { $card.location = "0n:00.0" }
                "24:0:0" { $card.location = "0o:00.0" }
                "25:0:0" { $card.location = "0p:00.0" }
                "26:0:0" { $card.location = "0q:00.0" }
                "27:0:0" { $card.location = "0r:00.0" }
                "28:0:0" { $card.location = "0s:00.0" }
                "29:0:0" { $card.location = "0t:00.0" }
                "30:0:0" { $card.location = "0u:00.0" }
            }    
        }    
        return $Data;
    }
}

## run lspci
$lspci = [Proc_Data]::read($lspci_exe, $null, $null, 0);

## See if GPUZ needs to be ran
if ($IsWindows) { $Data = [Win_Loader]::GPUZ($lspci, $lspci_file); }

## Build VIDEO_CARDS list
$Video_Cards = @()
$NVIDIA_CARDS = $lspci |
Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" } |
Where { $_ -like "*NVIDIA*" } |
Where { $_ -notlike "*nForce*" }

$AMD_CARDS = $lspci |
Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" } |
Where { $_ -like "*Advanced Micro Devices*" } |
Where { $_ -notlike "*RS880*" } |
Where { $_ -notlike "*Stoney*" }

$OTHER_CARDS = $lspci |
Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" } |
Where { $_ -notlike "*Advanced Micro Devices*" } |
Where { $_ -notlike "*NVIDIA*" }


foreach ($card in $NVIDIA_CARDS) { 
    ##Get BusId
    $busid = $card.split(' VGA')[0]
    $busid = $busid.split(' 3D')[0]    
    ## Get Name
    $Regex = '\[(.*)\]';
    $match = ([Regex]::Matches($card, $Regex).Value)
    if ([string]$match -ne "") {
        $name = ($match.replace('[', '')).replace(']', '')
    }
    else {
        $name = $card.split('controller: ')[1]
        $name = $name.split(' (')[0]
    }
    $brand = "NVIDIA"
    $Video_Cards += [VIDEO_CARD]::New($busid, $name, $brand);
}

foreach ($card in $AMD_CARDS) {
    $busid = $card.split(' VGA')[0]
    $busid = $busid.split(' 3D')[0]
    $name = ($card.split("[AMD/ATI] ")[1]).split(" (")[0]
    $brand = "AMD"
    $Video_Cards += [VIDEO_CARD]::New($busid, $name, $brand)
}

foreach ($card in $OTHER_CARDS) {
    $busid = $card.split(' VGA')[0]
    $busid = $busid.split(' 3D')[0]
    $brand = "cpu"
    $name = $card.split('controller: ')[1]
    $name = $name.split(' (')[0]
    $Video_Cards += [VIDEO_CARD]::New($busid, $name, $brand)
}


$Video_Cards = $Video_Cards | Sort-Object busid


## Process / Sort each VIDEO_CARD
$GPUS = @()
$NVIDIA_CARDS = $Video_Cards | Where brand -eq "NVIDIA"
$AMD_CARDS = $Video_Cards | Where brand -eq "AMD"
$OTHER_CARDS = $Video_Cards | Where brand -eq "cpu"

if ($NVIDIA_CARDS) {
    $nvidia_smi = [Proc_Data]::Read($smi_path, $null, '--query-gpu=gpu_bus_id,gpu_name,memory.total,power.min_limit,power.default_limit,power.max_limit,vbios_version --format=csv', 10)
    if ($nvidia_smi) { $nvidia_smi = $nvidia_smi | ConvertFrom-Csv }
    foreach ($item in $nvidia_smi) { $item.'pci.bus_id' = $item.'pci.bus_id'.replace('00000000:', '') }

    foreach ($card in $NVIDIA_CARDS) {
        $smi_card = $nvidia_smi | Where pci.bus_id -eq $card.busid    
        $vmms = [Proc_Data]::Read($lspci_exe, $null, "-vmms $($card.busid)", 0)
        $subvendor = ((($vmms | Select-String "SVendor").line).split("SVendor:")[1]).TrimStart("`t")
        $GPUS += [NVIDIA_CARD]::new($card, $subvendor, $smi_card.'memory.total [MiB]', $smi_card.vbios_version, $smi_card.'power.min_limit [W]', $smi_card.'power.default_limit [W]', $smi_card.'power.max_limit [W]')
    }
}

if ($AMD_CARDS) {
    if ($IsLinux) {
        $rocm_path = Join-Path $env:SWARM_DIR "build\apps\rocm\rocm-smi";
        $mem_path = Join-Path $env:SWARM_DIR "build\apps\amdmeminfo\amdmeminfo";
        $rocm_smi = [Proc_Data]::Read($rocm_path, $null, "--showproductname --showid --showvbios --showbus --json", 0);
        $mem_info = [Proc_Data]::Read($mem_path, $null, $null, 0);

        ## Parse Rocm_smi into an easier to manage table.
        $rocm_smi = $rocm_smi | ConvertFrom-Json
        $GETSMI = @()
        $rocm_smi.PSObject.Properties.Name | % { 
            $rocm_smi.$_."PCI Bus" = $rocm_smi.$_."PCI Bus".replace("0000:", ""); 
            $GETSMI += [PSCustomObject]@{ 
                "VBIOS version" = $rocm_smi.$_."VBIOS version"; 
                "PCI Bus"       = $rocm_smi.$_."PCI Bus"; 
                "Card vendor"   = $rocm_smi.$_."Card vendor" 
            } 
        }
        $rocm_smi = $GETSMI

        ## Need to do crazy what-the-hell parsing for mem_info
        ## TODO: Figure this mess out into something easier
        ## Can probably do ConvertFrom-StringData -Delimiter ":"
        $amdmeminfo = $mem_info | 
        where { $_ -notlike "*AMDMemInfo by Zuikkis `<zuikkis`@gmail.com`>*" } | 
        where { $_ -notlike "*Updated by Yann St.Arnaud `<ystarnaud@gmail.com`>*" }

        $amdmeminfo = $amdmeminfo | Select -skip 1
        $amdmeminfo = $amdmeminfo.replace("Found Card: ", "Found Card=")
        $amdmeminfo = $amdmeminfo.replace("Chip Type: ", "Chip Type=")
        $amdmeminfo = $amdmeminfo.replace("BIOS Version: ", "BIOS Version=")
        $amdmeminfo = $amdmeminfo.replace("PCI: ", "PCI=")
        $amdmeminfo = $amdmeminfo.replace("OpenCL Platform: ", "OpenCL Platform=")
        $amdmeminfo = $amdmeminfo.replace("OpenCL ID: ", "OpenCL ID=")
        $amdmeminfo = $amdmeminfo.replace("Subvendor: ", "Subvendor=")
        $amdmeminfo = $amdmeminfo.replace("Subdevice: ", "Subdevice=")
        $amdmeminfo = $amdmeminfo.replace("Sysfs Path: ", "Sysfs Path=")
        $amdmeminfo = $amdmeminfo.replace("Memory Type: ", "Memory Type=")
        $amdmeminfo = $amdmeminfo.replace("Memory Model: ", "Memory Model=")
        for ($i = 0; $i -lt $amdmeminfo.count; $i++) { $amdmeminfo[$i] = "$($amdmeminfo[$i]);" }
        $amdmeminfo | % { $_ = $_ + ";" }
        $amdmeminfo = [string]$amdmeminfo
        $amdmeminfo = $amdmeminfo.split("-----------------------------------;")
        $memarray = @()
        for ($i = 0; $i -lt $amdmeminfo.count; $i++) { 
            $item = $amdmeminfo[$i].split(";"); 
            $data = $item | ConvertFrom-StringData; 
            $memarray += [PSCustomObject]@{
                "busid"     = $data."PCI"; 
                "mem_type"  = $data."Memory Type"; 
                "mem_model" = $data."Memory Model"; 
            } 
        }
        $amdmeminfo = $memarray
    }

    foreach ($card in $AMD_CARDS) {
        $vmms = [Proc_Data]::Read($lspci_exe, $null, "-vmms $($card.busid)", 0)
        $subvendor = ((($vmms | Select-String "SVendor").line).split("SVendor:")[1]).TrimStart("`t")
        if ($IsWindows) {
            $gpuz_card = $data | where location -eq $card.busid
            $memtype = "$($gpuz_card.memvendor) $($gpuz_card.memtype)"
            $vbios = $gpuz_card.biosversion
            $memsize = "$($gpuz_card.memsize) MiB"
        }
        elseif ($IsLinux) {
            $smi_card = $rocm_smi | Where { $_."PCI Bus" -eq $busid }
            $meminfo = $amdmeminfo | Where busid -eq $busid
            $memtype = $meminfo."mem_model"
            $vbios = $smi_card."VBIOS version"
        }
        $GPUS += [AMD_CARD]::New($card, $subvendor, $memsize, $vbios, $memtype)
    }
}

if ($OTHER_CARDS) {
    foreach ($card in $OTHER_CARDS) {
        $GPUS += $card
    }
}

$GPUS = $GPUS | Sort-Object busid

for ($i = 0; $i -lt $GPUS.count; $i++) { 
    if ("PCI_SLOT" -in $GPUS[$i].PSOBject.Properties.Name) {
        $GPUS[$i].PCI_SLOT = $i 
    }
}
$count = 0;
$GPUS | Where brand -eq "NVIDIA" | ForEach-Object {
    $_.Device = $count
    $count++
}
$count = 0;
$GPUS | Where brand -eq "AMD" | ForEach-Object {
    $_.Device = $count
    $count++
}


## Now that table is built, time to perform actions.

if ($args[0] -eq "list" -or $args[0] -eq "json") {
    $tolist = $(
        if ($args[1] -eq "NVIDIA") { $GPUS | Where brand -eq "NVIDIA" }
        elseif ($args[1] -eq "AMD") { $GPUS | Where brand -eq "AMD" }
        else { $GPUS }
    )

    if ($args[0] -eq "list") {
        for ($i = 0; $i -lt $tolist.count; $i++) {
            $gpu = $tolist[$i]
            switch ($gpu.brand) {
                "NVIDIA" {
                    $color = $GREEN
                    $additional = "($($gpu.mem) $($gpu.plim_def))"
                }
                "AMD" {
                    $color = $RED
                    $additional = "($($gpu.mem) $($gpu.vbios) $($gpu.mem_type))"
                }
                "cpu" { $color = $YELLOW }
            }
            Write-Host "${BLUE}$i${NOCOLOR} $($gpu.busid) ${color}$($gpu.name)${NOCOLOR} $additional"
        }
        $tolist | Foreach {
        }
    }

    if ($args[0] -eq "json") {
        $tolist | Select -ExcludeProperty PCI_SLOT, Device, Speed, `
            Temp, Current_Fan, Wattage, Fan_Speed, Power_Limit, Power_Limit, Core_Clock, `
            Mem_Clock, Core_Voltage, Core_State, Mem_Clock, Mem_State, Fan_Speed, REF |
        ConvertTo-Json | Out-Host
    }
}

if ($args[0] -eq "count") {
    $tolist = $(
        if ($args[1] -eq "NVIDIA") { $GPUS | Where brand -eq "NVIDIA" }
        elseif ($args[1] -eq "AMD") { $GPUS | Where brand -eq "AMD" }
        else { $GPUS }
    )
    $tolist.count
}

if ($args[0] -eq "swarm") {
    return $GPUS
}

