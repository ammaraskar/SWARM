using namespace System;
using namespace System.Collections;

$Test = [Avalonia.Controls.DataGrid]::New()

class Data_Object {
  [string]$Type
  [string]$Miner
  [string]$HashRate
  [String]$Profit_Day

    Data_Object([string]$Type,[String]$miner,[String]$HashRate,[String]$Profit_Day) {
      [string]$this.Type = $Type
      [string]$this.Miner = $Miner
      [string]$this.HashRate = $HashRate
      [string]$this.Profit_Day = $Profit_Day
    }
}

$Data = @()
$Data += [Data_Object]::New("AMD1","minerx","34048","`$5.00")
$Data += [Data_Object]::New("NVIDIA2","minery","5465","`$10.00")

$Test.AutoGenerateColumns = $true
$Test.Items = $Data

$Tab1.Children.Add($Test)
$Grid = [Avalonia.Controls.Grid]::SetRow($Test,5)
