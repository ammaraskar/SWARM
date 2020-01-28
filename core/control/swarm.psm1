Using namespace System; 
using module ".\logging.psm1";
using module ".\helper.psm1";
using module "..\devices\rig.psm1";

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

        ## The next step is gathering user config information
        ## To Prevent to much module depth, this is ran as a
        ## script. User can run themselves with 'check_configs json'.
        $Global:Log.screen("Gathering Last Known Configurations...");
        $Global:Data.rig.Configs = . .\scripts\configs_check swarm;

    }
}