<#
SWARM is open-source software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
SWARM is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
#>

## This is class constructors for all parameters.
## parameters are user specified items.
## they are added when needed, and removed when no longer
## used to save memory.

class parameters {
    [string]$dir ## Local directory
    [hashtable]$user_params = @{}  ## User params.
    [hashtable]$current = @{} ## modified params (through remote or donation).
    [hashtable]$hive_params = @{} ## HiveOS params
    [hashtable]$swarm_params = @{} ## SWARM site params

    parameters([string]$dir) {
        $this.dir = $dir
    }

    get_parameters() {
        $path = ".\config\parameters\arguments.json"
        if (Test-Path $path) {
            $arguments = cat $path | jq
            $arguments.PSObject.Properties.Name | % { $this.current.Add("$($_)", $arguments.$_) }
            $arguments.PSObject.Properties.Name | % { $this.user_params.Add("$($_)", $arguments.$_) }    
        }
        if([string]$this.user_params.platform -eq "") {
            write-Host "Detecting Platform..." -Foreground Cyan
            if ($global:IsWindows) { 
                $this.user_params.platform = "windows"
                $this.current.platform = "windows"
            }
            if($global:IsLinux) {
                $this.user_params.platform = "linux"
                $this.current.platform = "linux"
                if(test-path "/hive/bin"){
                    $this.user_params.hiveos = "yes"
                    $this.current.hiveos = "yes"
                } else {
                    $this.user_params.hiveos = "no"
                    $this.current.hiveos = "no"
                }
            }
            Write-Host "OS = $($this.user_params.Platform)" -ForegroundColor Green

            ## Set debug folder
            if (-not (Test-Path ".\build\txt")) { New-Item -Name "txt" -ItemType "Directory" -Path ".\build" | Out-Null }
        }
    }

    get_hive_parameters() {
        $path = ".\config\parameters\Hive_params_keys.json"
        if (Test-Path $path) {
            $Stuff = cat $path | jq
            $Stuff.PSObject.Properties.Name | % { $this.hive_params.Add("$($_)", $Stuff.$_) }
        }
        if (-not $this.hive_params.Id) {
            $this.hive_params.Add("Id", $Null)
            $this.hive_params.Add("Password", $Null)
            $this.hive_params.Add("Worker", "$($this.user_params.worker)")
            $this.hive_params.Add("Mirror", "https://api.hiveos.farm")
            $this.hive_params.Add("FarmID", $Null)
            $this.hive_params.Add("Wd_Enabled", $null)
            $this.hive_params.Add("Wd_miner", $Null)
            $this.hive_params.Add("Wd_reboot", $Null)
            $this.hive_params.Add("Wd_minhashes", $Null)
            $this.hive_params.Add("Miner", $Null)
            $this.hive_params.Add("Miner2", $Null)
            $this.hive_params.Add("Timezone", $Null)
            $this.hive_params.Add("WD_CHECK_GPU", $Null)
            $this.hive_params.Add("PUSH_INTERVAL", $Null)
            $this.hive_params.Add("MINER_DELAY", $Null)
        }

        if ($global:IsWindows -and [string]$this.hive_params.MINER_DELAY -ne "") {
            Write-Host "Miner Delay Specified- Sleeping for $($this.hive_params.MINER_DELAY)"
            $Sleep = [Double]$this.hive_params.MINER_DELAY
            Start-Sleep -S $Sleep
        }        
    }

    get_swarm_parameters() {
        $path = ".\config\parameters\SWARM_params_keys.json"

        if (Test-Path $path) {
            $Stuff = cat $path | jq
            $Stuff.PSObject.Properties.Name | % { $this.swarm_params.Add("$($_)", $Stuff.$_) }
        }
        if (-not $this.swarm_params.Id) {
            $this.swarm_params.Add("Id", $Null)
            $this.swarm_params.Add("Password", $Null)
            $this.swarm_params.Add("Worker", "$($this.user_params.worker)")
            $this.swarm_params.Add("Mirror", "https://swarm-web.davisinfo.ro")
            $this.swarm_params.Add("FarmID", $Null)
            $this.swarm_params.Add("Wd_Enabled", $null)
            $this.swarm_params.Add("Wd_miner", $Null)
            $this.swarm_params.Add("Wd_reboot", $Null)
            $this.swarm_params.Add("Wd_minhashes", $Null)
            $this.swarm_params.Add("Miner", $Null)
            $this.swarm_params.Add("Miner2", $Null)
            $this.swarm_params.Add("Timezone", $Null)
            $this.swarm_params.Add("WD_CHECK_GPU", $Null)
            $this.swarm_params.Add("PUSH_INTERVAL", $Null)
            $this.swarm_params.Add("MINER_DELAY", $Null)
        }

        if ($global:IsWindows -and [string]$this.swarm_params.MINER_DELAY -ne "") {
            Write-Host "Miner Delay Specified- Sleeping for $($this.swarm_params.MINER_DELAY)"
            $Sleep = [Double]$this.swarm_params.MINER_DELAY
            Start-Sleep -S $Sleep
        }        
    }
}