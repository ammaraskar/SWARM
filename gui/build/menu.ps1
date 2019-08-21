## Control for Menu Bar

## Bind Names
$Exit = Win "Exit"
$Start = Win "Start_Swarm"
$Stop = Win "Stop_Swarm"
$Save_and_Start = Win "Save_Swarm"
$Save_and_Exit = Win "Save_Exit"


## Exit
$Exit.add_Click( { $global:window.Close() })

## Start SWARM
$Start.add_Click( { .\startup.ps1 })

## Save and Start Swarm
$Save_and_Start.add_Click({
    $global:config.param | ConvertTo-Json -Depth 10 |Set-Content ".\config\parameters\newarguments.json"
    .\startup.ps1
})

## Save and Exit
$Save_and_Exit.add_Click({
    $global:config.param | ConvertTo-Json -Depth 10 |Set-Content ".\config\parameters\newarguments.json"
    $global:config.window.Close()
    Exit
})

## Stop SWARM
$Stop.add_Click( {
        $Miner_PID = if (test-Path ".\build\pid\miner_pid.txt") { cat ".\build\pid\miner_pid.txt" }
        $Background_PID = if (test-Path ".\build\pid\background_pid.txt") { cat ".\build\pid\background_pid.txt" }
        if ($Miner_PID) {
            $Proc = Get-Process -Id $Miner_PID -ErrorAction Ignore
            if ($Proc) { Stop-Process -Id $Proc.Id }
        }
        if ($Background_PID) {
            $Proc = Get-Process -Id $Background_PID -ErrorAction Ignore
            if ($Proc) { Stop-Process -Id $Proc.Id }
        }
    })
