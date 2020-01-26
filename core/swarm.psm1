Using namespace System; 
using module ".\maintenance.psm1";
using module ".\rig.psm1";
using module ".\logging.psm1";

class SWARM {
    static [void] main([String[]]$arguments) {
        ## Start Logger
        $Global:Log = [Logging]::New();
    
        ## Folder Check/Generation and Maintenence
        $Global:Log.screen('Checking For Directories And Making As Required');
        [startup]::make_folders();

        ## Build Rig
        $Global:Log.screen('Building Rig Before Starting GUI...This can take a moment.');
        $Global:Data = [Hashtable]::Synchronized(@{});
        $Global:Data.Add('rig',[SWARM_RIG]::New());

        ## Print Rig details
        $Global:Log.screen('');
        $Global:Data.Rig.list();

        ## List GPUS
        $Global:Log.screen('');
        $Global:Log.screen('');
        [RIG_RUN]::list_gpus();
        $Global:Log.screen('');
        $Global:Log.screen('');
    }
}