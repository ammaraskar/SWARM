Using namespace System;
Using module "..\core\process.psm1";
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

    $new_gpu_list = $lspci |
    Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" } |
    Where { $_ -like "*Advanced Micro Devices*" -or $_ -like "*NVIDIA*" } |
    Where { $_ -notlike "*RS880*" } |
    Where { $_ -notlike "*Stoney*" } |
    Where { $_ -notlike "*nForce*" }

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
$GPUS = @{ }

$NVIDIA_CARDS = $lspci |
Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" } |
Where { $_ -like "*NVIDIA*" } |
Where { $_ -notlike "*nForce*" }

$AMD_CARDS = $lspci |
Where { $_ -like "*VGA*" -or $_ -like "*3D controller*" } |
Where { $_ -like "*Advanced Micro Devices*" } |
Where { $_ -notlike "*RS880*" } |
Where { $_ -notlike "*Stoney*" }

foreach ($card in $NVIDIA_CARDS) {
    
}




