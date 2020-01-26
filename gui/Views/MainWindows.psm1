using namespace PSAvalonia;
using namespace Avalonia;
using namespace Avalonia.Media;
using namespace Avalonia.Interactivity;
using namespace Avalonia.Input;
using namespace Avalonia.Controls;

Class MainWindow_Views {
    static [Grid] menu_bar() { 
        return [Grid]([GUI]::FindControl($Global:MainWindow, "menu_bar")); 
    }
    static [Button] exit_button() { 
        return [Button]([GUI]::FindControl($Global:MainWindow, "exit_button"));
    }
    static [Menu] main_menu() { 
        return [Menu]([GUI]::FindControl($Global:MainWindow, "main_menu")); 
    }
    static [IBrush ]exitBrush_leave() { 
        return [SolidColorBrush]::New([Colors]::White); 
    }
    static [IBrush] exitBrush_enter() { 
        return [SolidColorBrush]::New([Colors]::Red); 
    }
}