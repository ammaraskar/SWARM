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
            if ($wait -gt 0) {
                $proc.WaitForExit(($wait * 1000)) | Out-Null
            }
            else {
                $proc.WaitForExit() | Out-Null
            }
            if ($proc.HasExited) {
                while (-not $Proc.StandardOutput.EndOfStream) {
                    $Data += $Proc.StandardOutput.ReadLine()
                }    
            }
            else { 
                Stop-Process -Id $Proc.Id -ErrorAction Ignore 
                $Message = "Error: $Path timed out. Attempting To Stop Manually."
                if ($Global:Log) { $Global:Log.screen($Message, "Red") }
                else { Write-Host $Message -ForegroundColor Red }
            }
        } else {
            $Message = "Error: $Path does not exist."
            if ($Global:Log) { $Global:Log.screen($Message, "Red") }
            else { Write-Host $Message -ForegroundColor Red }
        }
        return $data
    }
}