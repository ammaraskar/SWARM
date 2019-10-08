$host.ui.RawUI.WindowTitle = 'OC-Start';
Invoke-Expression '.\inspector\nvidiaInspector.exe -setMemoryClockOffset:0,0,500  -setMemoryClockOffset:1,0,500  -setMemoryClockOffset:2,0,500  -setPowerTarget:0,100  -setPowerTarget:1,100  -setPowerTarget:2,100  -setBaseClockOffset:0,0,100  -setBaseClockOffset:1,0,100  -setBaseClockOffset:2,0,100 '
Invoke-Expression '.\nvfans\nvfans.exe --index 0 --speed 85'
Invoke-Expression '.\nvfans\nvfans.exe --index 1 --speed 85'
Invoke-Expression '.\nvfans\nvfans.exe --index 2 --speed 85'
