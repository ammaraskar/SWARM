$Mod = Get-Module -ListAvailable -Name PSAvalonia
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
Set-Location $Dir

if(-not $Mod) {
    Write-Host "Installing GUI Module, please wait..."
    Install-Module PSAvalonia -Force
    Write-Host "Installed!"
}

if($IsWindows){
Start-Process pwsh -ArgumentList "-executionpolicy Bypass -WindowStyle Hidden -command `"Set-Location C:\; Set-Location `'$Dir`'; .\gui\gui.ps1`"" -Verb RunAs
}
elseif($IsLinux) {
.\gui\gui.ps1
}



<TextBox Name="Wallets" Grid.Row="0" Grid.Column="2"/>
<TextBox HorizontalAlignment="Left" Name="Address" AcceptsReturn="False" Focusable="True" MinWidth="375" MaxWidth="375" Height="27" Watermark="BTC ADDRESSS" Grid.Row="0" Grid.Column="2"/>
<TextBlock Classes="h1" HorizontalAlignment="Center" Margin="0,9" Text="RigName1:   " Grid.Row="1" Grid.Column="0"/>
<TextBox HorizontalAlignment="Left" Name="Rigname1" AcceptsReturn="False" Height="27" Focusable="True" MinWidth="375" MaxWidth="375" Watermark="Your Rig NickName" Grid.Row="1" Grid.Column="1"/>
<TextBlock Classes="h1" HorizontalAlignment="Left" Margin="5,9" Text="Donate: " Grid.Row="1" Grid.Column="2"/>
<TextBox HorizontalAlignment="Left" Name="Donate" AcceptsReturn="False" Margin="0,5" Focusable="True" MinWidth="55" MaxWidth="55" Watermark="Amount" Grid.Row="1" Grid.Column="3"/>
<CheckBox Classes="h1" HorizontalAlignment="Left" Margin="-30,0" Name="Auto_Coin" Grid.Row="1" Grid.Column="4" Content="Auto Coin" Foreground="Black" Background="White" BorderBrush="Black"/>
<TextBlock Classes="h1" HorizontalAlignment="Left" Margin="40,5" Text="Pools Available  " Grid.Row="2" Grid.Column="1"/>
<TextBlock Classes="h1" HorizontalAlignment="Center" Margin="10,5" Text="Pools Used" Grid.Row="2" Grid.Column="3"/>
<ListBox Classes="h1" Name="Add_Pool_List" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="-10,0" Grid.Row="3" Width="180" Height="200" Grid.Column="1"></ListBox>
<Button Classes="h1" Name="Add_Pool_Button" HorizontalAlignment="Right" VerticalAlignment="Top" Height="27" Width="200" Margin="-8,0" Grid.Row="3" Grid.Column="1" Content="Add Pool ==&gt;"/>
<Button Classes="h1" Name="Remove_Pool_Button" HorizontalAlignment="Right" VerticalAlignment="Top" Height="27" Width="200" Margin="-8,-150" Grid.Row="4" Grid.Column="1" Content="&lt;== Remove Pool"/>
<ListBox Classes="h1" Name="Pool_List" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="-42,0" Grid.Row="3" Width="180" Height="200" Grid.Column="3"></ListBox>
