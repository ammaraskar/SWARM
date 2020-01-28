Using namespace System;
Using module "..\control\process.psm1"

## Motherboard constructor
class MOTHERBOARD {
    [String]$system_uuid;
    [String]$product;
    [String]$manufacturer;

    MOTHERBOARD() {
        $data = $(
            if ($Global:IsLinux) { [Proc_Data]::read((Join-Path $env:SWARM_DIR "\apps\dmidecode\dmidecode"), $null, $null, 0) }
            elseif ($Global:IsWindows) { Get-CimInstance Win32_BaseBoard }
        )
        $this.manufacturer = $(
            if ($global:ISLinux) {
                [string]((($data | Select-String "Base Board Information" -Context 0, 4).Context.PostContext | Select-String "Manufacturer:").Line).Split("Manufacturer: ")[1]
            }
            if ($global:IsWindows) {
                ($data | Select-Object Manufacturer).Manufacturer
            }
        )
        $this.product = $(
            if ($global:IsLinux) {
                [string]((($data | Select-String "Base Board Information" -Context 0, 4).Context.PostContext | Select-String "Product Name:").Line).Split("Product Name: ")[1]
            }
            if ($global:IsWindows) {
                ($Data | Select-Object Product).Product
            }
        )
        $this.system_uuid = $(
            if ($global:ISLinux) {
                [string]([Proc_Data]::Read((Join-Path $env:SWARM_DIR "\apps\dmidecode\dmidecode"), $null, "-s system-uuid", 0))
            }
            if ($global:IsWindows) {
                (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID
            }
        )
    }
}
