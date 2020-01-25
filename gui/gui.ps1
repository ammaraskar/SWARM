using namespace Avalonia;
using namespace Avalonia.Controls;
using namespace PSAvalonia;
using module ".\ViewModels\MainWindow.xaml.psm1"

$Debug = $true


$xaml = Get-Content ".\gui\ViewModels\MainWindow.xaml" | Out-String
$Global:MainWindow = [GUI]::CreateWindow($xaml)
$Global:MainWindow.HasSystemDecorations = $false
$MainWindow_Context = [MainWindow]::New()
$MainWindow.DataContext = $MainWindow_Context

## For now, eventually will be in a runspace
if($Debug) { $MainWindow.Add_Closed({Stop-Process -ID $PID})}

[GUI]::ShowWindow($MainWindow);

