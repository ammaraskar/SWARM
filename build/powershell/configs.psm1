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

## This is the config files converted to powershell objects.
class Configs {
    [string]$Dir
    [PSCustomObject]$asic
    [hashtable[]]$miners
    [PSCustomObject[]]$oc
    [PSCustomObject[]]$pools
    [PSCustomObject]$power
    [PSCustomObject[]]$update
    [PSCustomObject]$wallets

    Configs([string]$Dir) {
        $this.dir = $dir
    }

    get_configs() {
        $c = ".\config"
        
        ## ASIC
        $path = "$c\asic\asic-list.json"
        $this.asic = cat $path | jq

        ## Miners
        $paths = "$c\miners"
        $get = Get-ChildItem $paths | % {
            if ($_.BaseName -ne "README") {
                $file = cat $_ | jq
                $this.miners += @{ $_.BaseName = $file }
            }
        }

        ## OC
        $paths = "$c\oc"
        $get = Get-ChildItem $paths | % {
            if ($_.BaseName -ne "README") {
                $file = cat $_ | jq
                switch ($_.BaseName) {
                    "oc-algos"{ $this.oc += @{ "algos" = $file} }
                    "oc-defaults"{ $this.oc += @{ "default" = $file} }
                }
            }
        }

        ## Pool-Algos
        $paths = "$c\pools"
        $get = Get-ChildItem $paths | % {
            if ($_.BaseName -ne "README") {
                $file = cat $_ | jq
                switch ($_.BaseName) {
                    "bans"{ $this.pools += @{ "bans" = $file} }
                    "pool-algos"{ $this.pools += @{ "pool_algos" = $file} }
                    "pool-priority"{ $this.pools += @{ "pool_priority" = $file} }
                }
            }
        }
    }
}