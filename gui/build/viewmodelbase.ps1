using namespace System.ComponentModel

Import-Module ".\gui\PSAvalonia\1.0\PSAvalonia.psd1"

class ViewModelbase : ReactiveUI.ReactiveObject {

}

class stat {
    [string]$Type
    [string]$Miner
    [string]$Item
    [string]$HashRate
    [string]$Watt_Day
    [String]$BTC_Day
    [string]$Coin_Day
    [String]$Fiat_Day
    [string]$Pool

    stat([string]$Type, [String]$miner, [string]$Item, [String]$HashRate, [String]$Watt_Day, [String]$BTC_Day, [string]$Coin_Day, [String]$Fiat_Day, [String]$Pool) {
        [string]$this.Type = $Type
        [string]$this.Miner = $Miner
        [string]$this.Item = $Item
        [string]$this.HashRate = $HashRate
        [string]$this.Watt_Day = $Watt_Day
        [string]$this.BTC_Day = $BTC_Day
        [string]$this.Coin_Day = $Coin_Day
        [string]$this.Fiat_Day = $Fiat_Day
        [string]$this.Pool = $Pool
    }
}

class MainWindowViewModel : ViewModelbase {
    [String]                 $Greeting = "Hello World"
    [stat[]]                 $Stats

    [void] Change_Stat([stat[]]$Data) {
        $This.Stats = $Data
        $this.RaisePropertyChanged("Stats")
    }

    [void] Change_Greeting([String]$Value) {
        $this.Greeting = $Value
        $this.RaisePropertyChanged("Greeting")
    }
}

$MainWindowViewModel = [MainWindowViewModel]::New()