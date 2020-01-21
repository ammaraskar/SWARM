using namespace Avalonia;
using namespace ReactiveUI;

class ViewModelBase : ReactiveUI.ReactiveObject {

}

class MainWindow : ViewModelBase {
    [string]$Test

    MainWindow() {
        $this.test = "This is a test";
    }
}