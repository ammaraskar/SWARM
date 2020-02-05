$Devices = Get-CimInstance -class Win32_PnPEntity | Where { $_.PNPDeviceID -match "PCI\\*" } | Select -Unique
$pci = Get-Content ".\apps\device\pci_ids.json" | ConvertFrom-Json
$alphabet = @()  
for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++) {  
    $alphabet += [char]$c  
}  

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
    $get = $null
    $code = $null
    $Code_Id = $null
    $title = $null
    $rev = $null
    $revision = $null
    $new_rev = $null
    $subsys = $null
    $deviceSubsys = $null

    $device_Id = $Device.PNPDeviceID
    $locations = ((get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Enum\$device_ID" -name locationinformation).locationINformation).split(";")[2]
    $location_map = $locations.TrimStart("(").TrimEnd(")")
    $location = $location_map.split(",")

    [int]$get_busid = $location[0]
    [int]$get_deviceID = $location[1]
    [int]$get_functionId = $location[2]

    $new_busid = "{0:x2}" -f $get_busid
    $new_deviceID = "{0:x2}" -f $get_deviceID
    $new_functionId = "{0:x2}" -f $get_functionId

    $Device | Add-Member "location" "$new_busid`:$new_deviceID`:$new_functionId"
    $id = $Device.DeviceID
    $Value = $id.split('&')
    $vendorId = $value[0].Substring($Value[0].Length - 4)
    $deviceId = $value[1].Substring($Value[1].Length - 4)
    $deviceSubsysId = $value[2].Substring($Value[2].Length - 4) + ' ' + $value[2].Substring($Value[2].Length - 8, 4)
    $manufacturerId = $value[2].Substring($Value[2].Length - 4)
 
    $vendor = $pci.PSobject.Properties.name | Where { $_.substring(0, 4) -eq $vendorId }
    $device_name = $pci.$vendor.PSObject.Properties.Name | Where { $_.substring(0, 4) -eq $deviceId }
    if ($pci.$vendor.$device_name.PSobject.Properties.Name) {
        $subsys = $pci.$vendor.$device_name.PSObject.Properties.name | Where { $_ -eq $deviceSubsysId }
        $deviceSubsys = $pci.$vendor.$device_name.$subsys
    }
    if($deviceSubsys -eq $null) {$deviceSubsys = ($device_name.split("   ")[1])}
    $manufacturer = $pci.PSobject.Properties.name | Where { $_.substring(0, 4) -eq $manufacturerId }

    $CC = $device.CompatibleID | Where {$_ -like "*CC_*"} | Select -First 1
    $Get = $CC.IndexOf("CC_")
    $CC = $CC.Substring(13 + 3,4)

    $Code = $CC.Substring(0,2)
    $Code_Id = $CC.Substring(2,2)
    $title = $pci.PSObject.Properties.Name | Where {$_.substring(0,4) -eq "C $Code"}
    if($pci.$title.PSObject.Properties.Name) {
        $title = $pci.$title.PSObject.Properties.Name | Where{$_.substring(0,2) -eq $Code_Id}
    }

    $rev = $Device.DeviceID.IndexOf("REV_")
    $revision = $Device.DeviceID.substring($rev + 4,2)
    $new_rev = "{0:x2}" -f $revision

    $Device | Add-Member "irev" $new_rev
    $Device | Add-Member "ititle" ($title.split("   ")[1])
    $Device | Add-Member "ivendor" ($vendor.split("   ")[1])
    $Device | Add-Member "idevice" ($device_name.split("   ")[1])
    $Device | Add-Member "idevicesubsys" $deviceSubsys
    $Device | Add-Member "imanufacturer" ($manufacturer.split("   ")[1])
}


$Devices | Sort-Object location | ForEach-Object {
    $a = " $($_.idevicesubsys)"
    $b = " (rev $($_.irev))"
    Write-Host "$($_.location) $($_.ititle): $($_.ivendor)$a$b"
}