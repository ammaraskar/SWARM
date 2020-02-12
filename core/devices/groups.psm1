Using namespace System;
Using namespace System.Text;

## Device Groups Used To Execute Miner.
class DEVICE_GROUP {
    [String]$Name #User denoted name of group
    [String]$Device #Device this is (NVIDIA,AMD,CPU,ASIC)
    [String]$Hashrate #Current Hashrate
    [Miner]$Miner #Current Miner
    [Int]$Accepted ## Miner Current Accepted Shares
    [Int]$Rejected ## Miner Current Rejected Shares
    [Int]$Rej_Percent ## Rejection Percent
    [Array]$Devices = @() ## Can be AMD cards, NVIDIA cards, ASIC, CPU

    Add_GPU($GPU) {
        $this.Devices += $GPU
        $this.Device = $GPU.Brand
    }

    Add_Thread([Thread]$Thread) {
        $this.Devices += $Thread
        $this.Device = $Thread.Brand
    }
}

## Placeholder
## This will probably be done in separate psm1
class MINER {

}


## Placeholder
## This will probably be done in separate psm1
class STATS {
    [Hashtable]$Miners
    [Hashtable]$Pools
    [Hashtable]$Power
    [Hashtable]$Wallets
}

## Mining Threads for CPU
class THREAD {
    [String]$Brand = "CPU"
    [Decimal]$Speed; #Current Hashrate
    [Int]$Temp = 0; #Current Temperature Not Used Yet
    [Int]$Fan = 0; #Current Fan Speed Not Used Yet
    [Int]$Wattage = 0; #Current Wattage Not Used Yet
}
