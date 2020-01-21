using namespace Avalonia;
using namespace Avalonia.Controls;
using namespace PSAvalonia;
using module ".\ViewModels\MainWindow.xaml.psm1"

$xaml = Get-Content ".\gui\ViewModels\MainWindow.xaml" | Out-String
$Test = [GUI]::CreateWindow($xaml)
$MainWindow = [MainWindow]::New()
$Test.DataContext = $MainWindow
[GUI]::ShowWindow($Test);