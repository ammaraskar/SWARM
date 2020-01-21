Using namespace System;
Using module "..\core\process.psm1";
Using module "..\core\gpu.psm1";
. .\core\colors.ps1

$GPUZ = $false;

## Check if lscpi.txt exists

if ($IsWindows) {
    $lspci = [Proc_Data]::read("$env:SWARM_DIR\apps\pci-win\lspci.exe", $null, $null, 0)
}
elseif ($IsLinux) {
    $lspci = [Proc_Data]::('lspci', $null, $null, 0)
}

## See if GPUZ needs to be ran
if ($IsWindows) {
    $lspci_file = "$env:SWARM_DIR\debug\lspci.txt";
    $check_file = [IO.file]::Exists($lspci_file);

    $old_gpu_list = if ($check_file) { 
        cat $lspci_file 
    }

    $new_gpu_list = $lspci | Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" }

    if ([string]$new_gpu_list -ne $old_gpu_list) {
        $GPUZ = $true;
    }
    
    $new_gpu_list | Set-Content $lspci_file

    ## GPUZ can take a long time to run. Only run it
    ## if needed.
    if ($GPUZ) {
        ## Need to set registry entries first
        Set-Location HKCU:;
        if (-not (test-Path .\Software\techPowerUp)) {
            New-Item -Path .\Software -Name techPowerUp | Out-Null
            New-Item -path ".\Software\techPowerUp" -Name "GPU-Z" | Out-Null
            New-ItemProperty -Path ".\Software\techPowerUp\GPU-Z" -Name "Install_Dir" -Value "no" | Out-Null
        }
        Set-Location $env:SWARM_DIR;

        ## Run GPU-Z for GPU information
        $proc = Start-Process "$env:SWARM_DIR\apps\gpu-z\gpu-z.exe" -ArgumentList "-dump $env:SWARM_DIR\debug\data.xml" -PassThru
        $proc | Wait-Process
    }


    $Data = $([xml](cat "$env:SWARM_DIR\debug\data.xml")).gpuz_dump.card

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
}

## Build GPU hashtable
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

    ##Get BusId
    $busid = $card.split(' VGA')[0]
    $busid = $busid.split(' 3D')[0]

    $brand = "NVIDIA"

    $Video_Cards += [VIDEO_CARD]::New($busid, $name, $brand);
}

foreach ($card in $AMD_CARDS) {
    $busid = $card.split(' VGA')[0]
    $busid = $busid.split(' 3D')[0]

    if ($IsWindows) {
        $Get_card = $data | Where location -eq $busid
        $name = $Get_card.cardname
    }

    $brand = "AMD"

    if ($IsLinux) {
    }

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

## now that we have all video cards, build GPUS

$GPUS = @()

$NVIDIA_CARDS = $Video_Cards | Where brand -eq "NVIDIA"
$AMD_CARDS = $Video_Cards | Where brand -eq "AMD"
$OTHER_CARDS = $Video_Cards | Where brand -eq "cpu"

foreach ($card in $NVIDIA_CARDS) {
    $nvidia_smi = Join-Path $env:ProgramFiles "NVIDIA Corporation\NVSMI\nvidia-smi.exe"
    $smi = [Proc_Data]::Read($nvidia_smi, $null, '--query-gpu=gpu_bus_id,gpu_name,memory.total,power.min_limit,power.default_limit,power.max_limit,vbios_version --format=csv', 10)
    if ($smi) { $smi = $smi | ConvertFrom-Csv }
    foreach ($item in $smi) { $item.'pci.bus_id' = $item.'pci.bus_id'.replace('00000000:', '') }
    $smi_card = $smi | Where pci.bus_id -eq $card.busid
    if ($IsWindows) {
        $vmms = [Proc_Data]::Read("$env:SWARM_DIR\apps\pci-win\lspci.exe", $null, "-vmms $($card.busid)", 0)
    }
    elseif ($IsLinux) {
        $vmms = [Proc_Data]::Read("lspci", $null, "-vmms $($card.busid)", 0)
    }
    $subvendor = ((($vmms | Select-String "SVendor").line).split("SVendor:")[1]).TrimStart("`t")
    $GPUS += [NVIDIA_CARD]::new($card, $subvendor, $smi_card.'memory.total [MiB]', $smi_card.vbios_version, $smi_card.'power.min_limit [W]', $smi_card.'power.default_limit [W]', $smi_card.'power.max_limit [W]')
}

foreach ($card in $AMD_CARDS) {
    if ($IsWindows) {
        $vmms = [Proc_Data]::Read("$env:SWARM_DIR\apps\pci-win\lspci.exe", $null, "-vmms $($card.busid)", 0)
        $gpuz_card = $data | where location -eq $card.busid
    }
    elseif ($IsLinux) {
        $vmms = [Proc_Data]::Read("lspci", $null, "-vmms $($card.busid)", 0)
    }
    $subvendor = ((($vmms | Select-String "SVendor").line).split("SVendor:")[1]).TrimStart("`t")

    ## Mem invfor
    if ($IsWindows) {
        $memtype = "$($gpuz_card.memvendor) $($gpuz_card.memtype)"
        $vbios = $gpuz_card.biosversion
        $memsize = "$($gpuz_card.memsize) MiB"
    }
    if ($IsLinux) {

    }

    $GPUS += [AMD_CARD]::New($card, $subvendor, $memsize, $vbios, $memtype)
}

foreach ($card in $OTHER_CARDS) {
    $GPUS += $card
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

