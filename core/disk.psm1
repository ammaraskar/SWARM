class DISK {
    [string]$disk_model
    [string]$freespace
    DISK() {
        $this.disk_model = [DISK_RUN]::Get_Model();
        $this.freespace = [DISK_RUN]::Get_FreeSpace();
    }
}

## methods for disk actions
class DISK_RUN {
    static [string] Get_Model() {
        [string]$disk = "unknown"
        if ($global:ISLinux) {
            $bootpart = "$(Invoke-Expression "readlink -f /dev/block/`$(mountpoint -d `/)")"
            $bootpart = $bootpart.Substring(0, $bootpart.Length - 1)
            $disk = Invoke-Expression "parted -ml | grep -m1 `"$bootpart`:`""
            $disk = $disk -split ":"
            $disk = "$($disk | Select-Object -Last 2 | Select-Object -First 1) $($disk | Select-Object -Skip 1 -First 1)"
        }
        if ($global:IsWindows) {
            $model = (Get-CimInstance win32_diskdrive).model | Select -First 1
            $size = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size
            $size = $size.Size / [math]::pow( 1024, 3 )
            $size = [math]::Round($size)
            $disk = "$model $($size)GB"
        }
        return $disk
    }
    static [string] Get_FreeSpace() {
        $freespace = "0"
        if ($global:IsLinux) {
            $freespace = invoke-expression "df -h / | awk '{ print `$4 }' | tail -n 1 | sed 's/%//'"
        }
        if ($global:IsWindows) {
            $freespace = "$([math]::Round((Get-CIMInstance -ClassName Win32_LogicalDisk | Where-Object DeviceID -eq "C:").FreeSpace/1GB,0))G"
        }
        return $freespace;
    }
}