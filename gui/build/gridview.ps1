## PSAvalonia cannot do DataGrid,
# We must generate our own.
function Out-DataGrid {
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=0)]
    $Data,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=1)]
    [String]$Width,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=2)]
    [String]$Height
)

$Grid = [Avalonia.Controls.Grid]::New()

$Column_Count = $Data | Get-member -MemberType NoteProperty
$Rows_Def = [Avalonia.Controls.RowDefinition]::New(20, [Avalonia.Controls.GridUnitType]::Pixel)
$Col_Def = [Avalonia.Controls.RowDefinition]::New(2, [Avalonia.Controls.GridUnitType]::Star)
$Data | ForEach-Object { $Grid.RowDefinitions.Add($Rows_Def) }
$Column_Count | ForEach-Object {$Grid.RowDefinitions.Add($Col_Def)}

## Row One Is Title Bar
$Title = [Avalonia.Controls.Grid]::New()
$Title.Name = "Data_Title"

$Data_Titles = ($Data | Get-Member -MemberType NoteProperty).Name

for($i=0; $i -lt $Data_Titles.Count; $i++) {
    $TextBlock = [Avalonia.Controls.TextBlock]::New()
    $TextBlock.Background = "Gray"
    $TextBlock.HorizontalAlignment = "Center"
    $TextBlock.VerticalAlignment = "Center"
    $TextBlock.FontWeight = "Bold"
    $TextBlock.Text = $Data_Titles[$i]
    $Title.Children.Add($TextBlock)
    [Avalonia.Controls.Grid]::SetColumn($TextBlock,$i)
    [Avalonia.Controls.Grid]::SetRow($TextBlock,0)
}

$Grid.Children.Add($Title)
$Set = [Avalonia.Controls.Grid]::SetRow($Title,0)

$Grid
}