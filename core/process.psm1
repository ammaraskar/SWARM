Using namespace System;
Using namespace System.Diagnostics;

class Proc_Data {
    static [string[]] read([string]$path,[string]$working_dir,[string]$arguments,[int]$wait) {
        [string[]]$data = @();
        $info = [ProcessStartInfo]::New();
        $info.FileName = $path;
        if($working_dir){$info.WorkingDirectory = $working_dir};
        if($arguments){$info.Arguments = $arguments};
        $info.UseShellExecute = $false;
        $info.RedirectStandardOutput = $true;
        if($global:IsWindows){ $info.Verb = "runas" }        
        $proc = [Process]::New()
        $proc.StartInfo = $Info
        $proc.Start() | Out-Null
        if($wait -gt 0) {
            $proc.WaitForExit($wait) | Out-Null
        }
        else{
            $proc.WaitForExit() | Out-Null
        }
        if ($proc.HasExited) {
            while(-not $Proc.StandardOutput.EndOfStream){
                $Data += $Proc.StandardOutput.ReadLine()
            }    
        }
        else { Stop-Process -Id $Proc.Id -ErrorAction Ignore }
        return $data
    }
}