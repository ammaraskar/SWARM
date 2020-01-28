Using namespace System;

class filedata {
    static [hashtable] stringdata([string[]]$file) {
        $table = @{ }
        [string[]]$Data = [IO.File]::ReadAllLines($File);

        ## CUSTOM_USER_CONFIG can be multiline. Extract it.
        $CUSTOM_USER_CONFIG = $null
        if ($Data -like "*CUSTOM_USER_CONFIG=`'{*") {

            ## Extract json data from CUSTOM USER CONFIG and its position
            $Start = $Data.IndexOf("CUSTOM_USER_CONFIG=`'{")
            $Cut = $Data[$Start .. $Data.Count]
            $End = $Cut.IndexOf("}`'")
            $Get = $Cut[0 .. $End]
            $End = $Start + $End
            $CUSTOM_USER_CONFIG = $Get.Replace("CUSTOM_USER_CONFIG=`'", "")
            $CUSTOM_USER_CONFIG = $CUSTOM_USER_CONFIG.Replace("}`'", "}")
            $CUSTOM_USER_CONFIG = $CUSTOM_USER_CONFIG | ConvertFrom-Json

            ## Rebuild Array without custom user config- It will be added in later.
            [string[]]$New = @()
            for ($i = 0; $i -lt $Data.Count; $i++) {
                if ($i -lt $start) {
                    $New += $Data[$i]
                }
                elseif ($i -gt $Start -and $i -gt $end) {
                    $New += $Data[$i]
                }
            }
            $Data = $New
        }


        $Where = [func[string, bool]] { $args -like "*=*" };
        $Lines = [Linq.Enumerable]::Where($Data, $Where) -replace "`"", ""
        $Lines | Foreach { 
            $split = $_.split("=");
            $Name = [Linq.Enumerable]::First($split);
            $Value = [Linq.Enumerable]::Last($split);
            $table.Add($Name, $Value);
        }

        if ($CUSTOM_USER_CONFIG) {
            $table.ADD("CUSTOM_USER_CONFIG", $CUSTOM_USER_CONFIG);
        }

        return $table
    }

    static [void] to_file([string]$filename, [hashtable]$data) {
        $file_data = @()
        $data.keys | ForEach-Object { 
            if ($Data.$_ -is [Hashtable] -or $Data.$_ -is [PSCustomObject]) {
                $file_data += "$($_)=`'$($data.$_ | ConvertTo-Json)`'"
            }
            else {
                $file_data += "$($_)=$($data.$_)" 
            }
        }
        [IO.File]::WriteAllLines($filename, $file_data)
    }
}

class startup {
    ## Make folders if they don't exsist.
    static [void] make_folders(){
        [string[]]$Folders = @()
        $Folders += 'stats'
        $Folders += 'logs'
        $Folders += 'debug'

        foreach($Folder in $Folders) {
            [string]$Path = Join-Path $Global:Dir $Folder
            [bool]$Check = [IO.Directory]::Exists($Path)
            if(-not $Check) {
                New-Item -ItemType Directory -Path $Global:Dir -Name $folder | Out-Null
            }
        }
    }
}