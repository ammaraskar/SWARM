<#
PCIUtils FOR POWERSHELL
This is open-source software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
SWARM is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

If you use my code, please include my github: https://github.com/maynardminer
#>


## USE CIM to get to PnP Devices- To my knowledge this should not require administrator,
## but you know...Windows...
$Devices = Get-CimInstance -class Win32_PnPEntity | Where { $_.PNPDeviceID -match "PCI\\*" } | Select -Unique

## This is a json list of pci.ids.
$pci = Get-Content ".\apps\device\pci_ids.json" | ConvertFrom-Json

## First we need to get locations
## I have found unlike linux that Windows
## can have devices listed without locations
## We only want devices with locations.
foreach ($Device in $Devices) {
    $device_Id = $Device.PNPDeviceID
    $locations = ((get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Enum\$device_ID" -name locationinformation).locationINformation).split(";")[2]
    if ($locations) {
        $location_map = $locations.TrimStart("(").TrimEnd(")")
        $location = $location_map.split(",")

        [int]$get_busid = $location[0]
        [int]$get_deviceID = $location[1]
        [int]$get_functionId = $location[2]

        $new_busid = "{0:x2}" -f $get_busid
        $new_deviceID = "{0:x2}" -f $get_deviceID
        $new_functionId = "{0:x2}" -f $get_functionId

        $Device | Add-Member "location" "$new_busid`:$new_deviceID`:$new_functionId"
    }
}

## IF using parsable argument to get a single device
if ($args[0] -eq "-vmms") {
    $Devices = $Devices | Where location -eq $args[1]
}
else {
    $Devices = $Devices | Where location -ne $null
}

## I only have so many devices to test with
## but so far I haven't found a device yet
## that doesn't match pci.ids
foreach ($Device in $Devices) {
    $id = $null
    $Value = $null
    $vendorId = $null
    $deviceId = $null
    $deviceSubsysId = $null
    $manufacturerId = $null
    $vendor = $null
    $device_name = $null
    $manufacturer = $null
    $cc = $null
    $code = $null
    $Code_Id = $null
    $title = $null
    $rev = $null
    $revision = $null
    $new_rev = $null
    $deviceSubsys = $null

    $id = $Device.DeviceID
    $Value = $id.split('&')
    $vendorId = $value[0].Substring($Value[0].Length - 4)
    $deviceId = $value[1].Substring($Value[1].Length - 4)
    $deviceSubsysId = $value[2].Substring($Value[2].Length - 4) + ' ' + $value[2].Substring($Value[2].Length - 8, 4)
    $manufacturerId = $value[2].Substring($Value[2].Length - 4)
 
    $vendor = $pci.PSobject.Properties.name | Where { $_.substring(0, 4) -eq $vendorId }
    $device_name = $pci.$vendor.PSObject.Properties.Name | Where { $_.substring(0, 4) -eq $deviceId }
    $deviceSubsys = $pci.$vendor.$device_name.$deviceSubsysId
    if ($null -eq $deviceSubsys) { $deviceSubsys = ($device_name.split("   ")[1]) }
    $manufacturer = $pci.PSobject.Properties.name | Where { $_.substring(0, 4) -eq $manufacturerId }

    $CC = $device.CompatibleID | Where { $_ -like "*CC_*" } | Select -First 1
    $Get = $CC.IndexOf("CC_")
    $CC = $CC.Substring(13 + 3, 4)

    $Code = $CC.Substring(0, 2)
    $Code_Id = $CC.Substring(2, 2)
    $title = $pci.PSObject.Properties.Name | Where { $_.substring(0, 4) -eq "C $Code" }
    if ($pci.$title.PSObject.Properties.Name) {
        $title = $pci.$title.PSObject.Properties.Name | Where { $_.substring(0, 2) -eq $Code_Id }
    }

    $rev = $Device.DeviceID.IndexOf("REV_")
    $revision = $Device.DeviceID.substring($rev + 4, 2)
    $new_rev = "{0:x2}" -f $revision

    $Device | Add-Member "irev" $new_rev
    $Device | Add-Member "ititle" ($title.split("   ")[1])
    $Device | Add-Member "ivendor" ($vendor.split("   ")[1])
    $Device | Add-Member "idevice" ($device_name.split("   ")[1])
    $Device | Add-Member "idevicesubsys" $deviceSubsys
    $Device | Add-Member "imanufacturer" ($manufacturer.split("   ")[1])
}

## Print single view
if ($args[0] -eq "-vmms") {
    $Devices | % {
        Write-Host "Slot:`t$($_.location)"
        Write-Host "Class:`t$($_.ititle)"
        Write-Host "Vendor:`t$($_.ivendor)"
        Write-Host "Device:`t$($_.idevice)"
        Write-Host "SVendor:`t$($_.imanufacturer)"
        Write-Host "SDevice:`t$($_.idevicesubsys)"
        Write-Host "Rev:`t$($_.irev)"
    }
}
## Print list just like PCIUtils
else {
    $Devices | Sort-Object location | ForEach-Object {
        $a = " $($_.idevicesubsys)"
        $b = " (rev $($_.irev))"
        Write-Host "$($_.location) $($_.ititle): $($_.ivendor)$a$b"
    }
}

## I have found this to be slightly slower than lscpi
## mainly because its using .json rather than binary,
## but still seems to work fine for me.