using Avalonia;
using Avalonia.Markup.Xaml;

namespace SWARM_GUI
{
	public class App : Application
	{
		public override void Initialize()
		{
			AvaloniaXamlLoader.Load(this);
		}
	}
}
