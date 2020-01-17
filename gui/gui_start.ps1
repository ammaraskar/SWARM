## Load Avalonia Library
$libs = Get-ChildItem ".\gui\libs"
foreach($file in $libs) {
    if($file.extension -eq ".dll" -and $file.BaseName -ne "libSkiaSharp" -and $File.BaseName -ne "Serilog") {
        Write-Host "Adding $($file.name)"
        Add-Type -Path $file.Fullname
    }
}

. .\gui\gui.ps1