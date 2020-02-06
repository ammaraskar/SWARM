Using namespace System;
Using namespace System.Diagnostics;

class Proc_Data {
    static [string[]] read([string]$path, [string]$working_dir, [string]$arguments, [int]$wait) {
        [string[]]$data = @();
        if (test-path $path) {
            $info = [ProcessStartInfo]::New();
            $info.FileName = $path;
            if ($working_dir) { $info.WorkingDirectory = $working_dir };
            if ($arguments) { $info.Arguments = $arguments };
            $info.UseShellExecute = $false;
            $info.RedirectStandardOutput = $true;
            if ($global:IsWindows) { $info.Verb = "runas" }
            $proc = [Process]::New()
            $proc.StartInfo = $Info
            $proc.Start() | Out-Null
            $Stopwatch = [Stopwatch]::New();
            $Stopwatch.Restart();
            while (-not $Proc.StandardOutput.EndOfStream) {
                $Data += $Proc.StandardOutput.ReadLine()
                if ($wait -and $Stopwatch.Elapsed.Seconds -gt $wait) {
                    $Message = "Error: Process $Path has exceeded wait time. Stopping."
                    if ($Global:Log) { $Global:Log.screen($Message, "Red") }
                    else { write-Host $Message -ForegroundColor Red }
                    Stop-Process $Proc;
                    break
                }
            }    
        }
        else {
            $Message = "Error: $Path does not exist."
            if ($Global:Log) { $Global:Log.screen($Message, "Red") }
            else { Write-Host $Message -ForegroundColor Red }
        }
        return $data
    }
}