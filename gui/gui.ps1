using namespace Avalonia;
using namespace Avalonia.Controls;
using namespace PSAvalonia;
using module ".\ViewModels\MainWindow.xaml.psm1"



$xaml = Get-Content ".\gui\ViewModels\MainWindow.xaml" | Out-String
$Global:MainWindow = [GUI]::CreateWindow($xaml)
$MainWindow_Context = [MainWindow]::New()
$MainWindow.HasSystemDecorations = $false;
$MainWindow.DataContext = $MainWindow_Context
[GUI]::ShowWindow($MainWindow);