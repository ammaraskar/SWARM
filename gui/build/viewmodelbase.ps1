Import-Module ".\gui\PSAvalonia\1.0\PSAvalonia.psd1"

class viewmodelbase : ReactiveUI.ReactiveObject{}

class MainWindowViewModel : viewmodelbase {
    [String]$Greeting = "Hello World!"
}