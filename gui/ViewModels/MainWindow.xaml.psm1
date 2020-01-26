using namespace Avalonia;
using namespace Avalonia.Controls;
using namespace ReactiveUI;
using namespace Avalonia.Input;
using namespace Avalonia.Interactivity;
using namespace Avalonia.Media;
using namespace PSAvalonia;
using module "..\Views\MainWindows.psm1"

class ViewModelBase : ReactiveUI.ReactiveObject {

}

class MainWindow : ViewModelBase {

    MainWindow() {
        [MainWindow_Views]::menu_bar().Add_PointerPressed($this.Menu_MouseLeftButtonDown());
        [MainWindow_Views]::exit_button().Add_PointerEnter($this.exit_color_enter());
        [MainWindow_Views]::exit_button().Add_PointerLeave($this.exit_color_leave());
        [MainWindow_Views]::exit_button().Add_Click($this.start_exit());
    }

    hidden [scriptblock] Menu_MouseLeftButtonDown() {
        return {
            param([object]$sender, [PointerPressedEventArgs]$e)
            [MenuItem]$file = [MenuItem]([GUI]::FindControl($global:MainWindow, "file"));
            [MenuItem]$edit = [MenuItem]([GUI]::FindControl($global:MainWindow, "edit"));
            if (-not $file.IsPointerOver -and -not $edit.IsPointerOver) {
                if ($file.IsSubMenuOpen) {
                    $file.close();
                }
                if ($edit.IsSubMenuOpen) {
                    $edit.close();
                }
                $global:MainWindow.BeginMoveDrag($e);
            }
        }
    }

    hidden [scriptblock] start_exit() {
        return {
            param([object]$sender, [RoutedEventArgs]$e)
            $global:MainWindow.Close($e);
        }
    }

    hidden [scriptblock] exit_color_enter() {
        return {
            param([object]$sender, [RoutedEventArgs]$e)
            [MainWindow_Views]::exit_button().Background = [MainWindow_Views]::exitBrush_enter();
        }
    }

    hidden [scriptblock] exit_color_leave() {
        return {
            param([object]$sender, [RoutedEventArgs]$e)
            [MainWindow_Views]::exit_button().Background = [MainWindow_Views]::exitBrush_leave();
        }
    }
}