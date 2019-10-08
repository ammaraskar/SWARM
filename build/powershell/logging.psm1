using namespace System.Management.Automation

class log {

    static [void] clear() {
        if (test-path ".\logs\miner.log") {
            clear-content ".\logs\miner.log"
        }
    }

    static [void] info([string]$text) {
        if ($global:Error) {
            $global:Error | % {
                $data = @()
                $Data += "$($_.InvocationInfo.InvocationName) : $($_.exception.message)"
                $info = $_.InvocationInfo.PositionMessage.split("`n")
                $info | % { $Data += "$($_)" }
                $Data += "CategoryInfo          : $($_.CategoryInfo)"
                $Data += "FullyQualifiedErrorId : $($_.FullyQualifiedErrorId)"
                $Data | Add-Content ".\logs\miner.log"
            }
            $global:error.clear()
        }
        $Date = Get-Date
        $info = "`[$Date`]: "
        "$info$text" | Add-Content ".\logs\miner.log"
        Write-Host $info -NoNewline
        Write-Host $text
    }

    static [void] info([string]$text, [string]$color) {
        if ($global:Error) {
            $global:Error | % {
                $data = @()
                $Data += "$($_.InvocationInfo.InvocationName) : $($_.exception.message)"
                $info = $_.InvocationInfo.PositionMessage.split("`n")
                $info | % { $Data += "$($_)" }
                $Data += "CategoryInfo          : $($_.CategoryInfo)"
                $Data += "FullyQualifiedErrorId : $($_.FullyQualifiedErrorId)"
                $Data | Add-Content ".\logs\miner.log"
            }
            $global:error.clear()
        }
        $Date = Get-Date
        $info = "`[$Date`]: "
        "$info$text" | Add-Content ".\logs\miner.log"
        Write-Host $info -NoNewline
        Write-Host $text -ForegroundColor $color
    }

    static [void] info([string]$text, [string]$color, [bool]$NoNewLine) {
        if ($global:Error) {
            $global:Error | % {
                $data = @()
                $Data += "$($_.InvocationInfo.InvocationName) : $($_.exception.message)"
                $info = $_.InvocationInfo.PositionMessage.split("`n")
                $info | % { $Data += "$($_)" }
                $Data += "CategoryInfo          : $($_.CategoryInfo)"
                $Data += "FullyQualifiedErrorId : $($_.FullyQualifiedErrorId)"
                $Data | Add-Content ".\logs\miner.log"
            }
            $global:error.clear()
        }
        $Date = Get-Date
        $info = "`[$Date`]: "
        "$info$text" | Add-Content ".\logs\miner.log" -NoNewline
        if ($color -and $NoNewLine) {
            Write-Host $info -NoNewline
            Write-Host $text -ForegroundColor $color -NoNewline
        }
        else {
            Write-Host $info -NoNewline
            Write-Host $text -NoNewline
        }
    }

    static [void] info([string]$text, [string]$color, [bool]$NoNewLine, [bool]$NoDate) {
        if ($global:Error) {
            $global:Error | % {
                $data = @()
                $Data += "$($_.InvocationInfo.InvocationName) : $($_.exception.message)"
                $info = $_.InvocationInfo.PositionMessage.split("`n")
                $info | % { $Data += "$($_)" }
                $Data += "CategoryInfo          : $($_.CategoryInfo)"
                $Data += "FullyQualifiedErrorId : $($_.FullyQualifiedErrorId)"
                $Data | Add-Content ".\logs\miner.log"
            }
            $global:error.clear()
        }
        $Date = Get-Date
        $info = "`[$Date`]: "
        switch ($NoDate) {
            $true {
                if ($color -and $NoNewLine) {
                    $text | Add-Content ".\logs\miner.log" -NoNewline
                    Write-Host $text -ForegroundColor $color -NoNewline
                }
                elseif ($NoNewLine -and -not $color) {
                    $text | Add-Content ".\logs\miner.log" -NoNewline
                    Write-Host $text -NoNewline
                }
                elseif ($color -and -not $NoNewLine) {
                    $text | Add-Content ".\logs\miner.log"
                    Write-Host $text -ForegroundColor $color
                }
            }
            $false {
                if ($color -and $NoNewLine) {
                    "$info$text" | Add-Content ".\logs\miner.log" -NoNewline
                    Write-Host $info -NoNewline
                    Write-Host $text -ForegroundColor $color -NoNewline
                }
                elseif ($NoNewLine -and -not $color) {
                    "$info$text" | Add-Content ".\logs\miner.log" -NoNewline
                    Write-Host $info -NoNewline
                    Write-Host $text -NoNewline
                }
                elseif ($color -and -not $NoNewLine) {
                    $info | Add-Content ".\logs\miner.log"
                    Write-Host $info -NoNewline
                    Write-Host $text -ForegroundColor $color
                }
            }
        }
    }
}