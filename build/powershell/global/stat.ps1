function Global:Start-Shuffle([double]$X, [double]$Y) {
    $X = [Double]$X * 1000
    $Z = [Double]$Y - $X
    $X = [math]::Round( ($Z / $X) , 4)
    return $X
}

class stat {
    hidden [hashtable]$time_periods = @{
        "Minute"    = 0
        "Minute_5"  = 0
        "Minute_15" = 0
        "Hour"      = 0
        "Hour_4"    = 0
        "Day"       = 0
    }
    hidden [double]$SmallestValue = 1E-20
    [string]$name
    [double]$live
    [double]$minute
    [double]$minute_5
    [double]$minute_15
    [double]$hour
    [double]$hour_4
    [double]$day
    [double[]]$values
    [Datetime]$Last_Checked

    [double] Alpha([double]$value) { return 2 / ($value + 1) }

    [Microsoft.PowerShell.Commands.GenericMeasureInfo] Theta([int]$time_period, [double[]]$values) {
        return $values | 
            Select-Object -First $time_period | 
            Measure-Object -Sum
    }

    [void] Rolling_MA (
        [string]$name,
        [double]$Value,
        [double]$Max_Periods,
        [int]$Rounding
    ) {
        if ($this."$($name)_periods" -lt $Max_Periods) { $this."$($name)_periods"++ }
        $this.$name = [Math]::Round(
            ( ($this.$name * $this."$($name)_periods") + $Value) / ($this."$($name)_periods" + 1), $Rounding
        )
    }

    [void] EMA (
        [double]$item, 
        [double[]]$values, 
        [string]$time_period
    ) {
        $Theta = $this.theta( $this.time_periods.$time_period, $this.values )
        $Alpha = $this.alpha($Theta.Count)
        $Zeta = [Double]$Theta.Sum / $Theta.Count
        $this.$time_period = [Math]::Max( 
            ( $Zeta * $Alpha + $($this.$time_period) * (1 - $Alpha) ) , $this.SmallestValue )
    }
    
    Set_StatFile([string]$Path) {
        ## Convert Everything Back To Decimal
        $Stat = [ordered]@{ }
        $Stat.Add("Live", [Decimal]$this.live)
        $Stat.Add("Minute", [Decimal]$this.Minute)
        $Stat.Add("Minute_5", [Decimal]$this.Minute_5)
        $Stat.Add("Minute_15", [Decimal]$this.Minute_15)
        $Stat.Add("Hour", [Decimal]$this.Hour)
        $Stat.Add("Hour_4", [Decimal]$this.Hour_4)
        $Stat.Add("Day", [Decimal]$this.Day)
        if ($this.rejection_percent) { $Stat.Add("rejection_percent", $this.rejection_percent) }
        if ($this.rejection_percent_periods) { $Stat.Add("rejection_percent_periods", $this.rejection_percent_periods) }
        if ($this.volume_hashrate) { $Stat.Add("volume_hashrate", $this.volume_hashrate) }
        if ($this.volume_hashrate_periods) { $Stat.Add("volume_hashrate_periods", $this.volume_hashrate_periods) }
        if ($this.deviation) { $Stat.Add("deviation", $this.deviation) }
        if ($this.deviation_periods) { $Stat.Add("deviation_periods", $this.deviation_periods) }
        $Stat.Add("Last_Checked", $this.Last_Checked.ToUniversalTime())
        $Stat.Add("Values", @( $this.Values | % { [Decimal]$_ } ))
        $Stat | ConvertTo-Json -Depth 10 | Set-Content $Path
    }

    [string] Set_Stat(
        [string]$Name, 
        [Double]$Interval,
        [Double]$Value,
        [int]$Max_Periods
    ) {

        ## Set Date
        $this.Last_Checked = Get-Date

        ## Calculate number of values to use for each time period based on
        ## How often user contacts pool (-Interval Argument)
        $this.time_periods.Minute = [Math]::Max([Math]::Round(60 / $Interval), 1)
        $this.time_periods.Minute_5 = [Math]::Max([Math]::Round(300 / $Interval), 1)
        $this.time_periods.Minute_15 = [Math]::Max([Math]::Round(900 / $Interval), 1)
        $this.time_periods.Hour = [Math]::Max([Math]::Round(3600 / $Interval), 1)
        $this.time_periods.Hour_4 = [Math]::Max([Math]::Round(14400 / $Interval), 1)
        $this.time_periods.Day = [Math]::Max([Math]::Round(86400 / $Interval), 1)

        ## Set Initial Stat Value
        $this.live = $Value
        $this.minute = $Value
        $this.minute_5 = $Value
        $this.minute_15 = $Value
        $this.hour = $Value
        $this.hour_4 = $Value
        $this.Day = $value
        $this.values += $value

        ## Get last pull
        ## Overwrite Initial Stat Values To Previous Values
        $this.name = $Name.replace("`/", "`-")
        $Path = ".\stats\$($this.name).txt"
        if (test-path $path) {
            $stat = Get-Content $Path | ConvertFrom-Json
            $this.minute = [double]$stat.Minute
            $this.minute_5 = [double]$stat.Minute_5
            $this.minute_15 = [double]$stat.minute_15
            $this.hour = [double]$stat.hour
            $this.hour_4 = [double]$stat.hour_4
            $this.day = [double]$stat.day
            if ($stat.volume_hashrate) { $this.volume_hashrate = $stat.volume_hashrate }
            if ($stat.volume_hashrate_periods) { $this.volume_hashrate_periods = $stat.volume_hashrate_periods }
            if ($stat.deviation) { $this.deviation = $stat.deviation }
            if ($stat.deviation_periods) { $this.deviation_periods = $stat.deviation_periods }
            if ($stat.rejection_percent) { $this.rejection_percent = $stat.rejection_percent }
            if ($stat.rejection_percent_periods) { $this.rejection_percent_periods = $stat.rejection_percent_periods }
            $this.values += [double[]]$stat.values
            ## Remove item values beyond maximum number of values.
            if ($this.values.count -gt $Max_Periods) {
                $this.values = $this.values | Select -First $Max_Periods
            }
        }

        ## Calculate New Values For Each Time Period
        $this.time_periods.keys | % {
            $this.EMA($value, $this.values, [string]$_)
        }

        ## In case it doesn't exist, or user deletes.
        if (-not (Test-Path "stats")) { New-Item "stats" -ItemType "directory" }

        return $path
    }
}

class hashrate_stat : stat {
    [double]$rejection_percent
    [double]$rejection_percent_periods

    hashrate_stat(
        [string]$Name,
        [int]$Interval,
        [Double]$Value,
        [int]$Max_Periods,
        [double]$rejection_percent
    ) {
        if ($rejection_percent) { $this.rejection_percent = $rejection_percent }
        $Path = $this.Set_Stat($Name, $Interval, $Value, $Max_Periods)
        if ($rejection_percent) { 
            $this.Rolling_MA(
                "rejection_percent",
                $rejection_percent,
                [int]$this.time_periods.hour_4, ## Last 4 hour average
                4
            )
        }
        $this.Set_StatFile($Path)
    }
}

class load_average : stat {
    load_average(
        [string]$Name,
        [Double]$Value,
        [int]$Max_Periods
    ) {
        $Path = $this.Set_Stat($Name, 10, $Value, 60)
        $this.Set_StatFile($Path)
    }
}

class pool_stat : stat {
    hidden [int]$Hashrate_Interval = 15 ## last 15 pulls
    [double]$volume_hashrate
    [double]$volume_hashrate_periods
    [double]$deviation
    [double]$deviation_periods

    pool_stat(
        [string]$Name,
        [int]$Interval,
        [Double]$Value,
        [int]$Max_Periods,
        [double]$Pool_Hashrate,
        [double]$Shuffled
    ) {
        if ($Pool_Hashrate) { $this.volume_hashrate = $Pool_Hashrate }
        if ($Shuffled) { $this.deviation = $Shuffled }
        $Path = $this.Set_Stat($Name, $Interval, $Value, $Max_Periods)
        if ($Pool_Hashrate) { 
            $this.Rolling_MA(
                "volume_hashrate",
                $Pool_Hashrate,
                [int]$this.Hashrate_Interval, ## Last 15 periods
                0
            ) 
        }
        if ($Shuffled) {
            $this.Rolling_MA(
                "deviation",
                $Shuffled,
                [int]$this.time_periods.day, ## Daily rolling average
                4
            )
        }
        $this.Set_StatFile($Path)
    }
}

##$test = [hashrate_stat]::new("my_test_hash", 300, 14580000, 288, 15)