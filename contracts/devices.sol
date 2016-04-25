
/*
 * Contract to keep track of all the registered devices in the network. 
 */
contract DevicePool {
    address owner;
    // Device representation struct.
    struct Device {
        string name;
        address addr;
        uint32 reg_ts;
        string wireless_if;
        string resources;
    }
    // Stored devices 
    mapping (address => Device) devices;

    //---------------------------- Constructor ---------------------------------
    function DevicePool() {
        owner = msg.sender;
    }
    
    //--------------------------------------------------------------------------
    // Register a new device
    //     name : Name of the deivce.
    //     wireless_if: Supported wireless interfaces.
    //     resources: Supported resources (speaker, mic, sensors...).
    // res: Operation result. 
    //--------------------------------------------------------------------------
    function register(string name, string wireless_if, string resources) 
                      returns (bool res) {
        Device dev = devices[msg.sender];
        // Return false if already registered.
        if ( dev.addr != 0x0) {
            return false;
        }
        dev.name = name;
        dev.addr = msg.sender;
        dev.reg_ts = 100000;    // current timestamp
        dev.wireless_if = wireless_if;
        dev.resources = resources;
        
        devices[msg.sender] = dev;

        return true;
    }

    //--------------------------------------------------------------------------
    // Unregister a device
    //--------------------------------------------------------------------------
    function unregister() returns (bool res) {
        Device dev = devices[msg.sender];
        if ( dev.addr == 0x0) {
             return false;
        }
        delete dev.name;
        dev.addr = 0x0;
        dev.reg_ts = 0;
        dev.wireless_if = "";
        dev.resources = "";
        return true;
    }
    
    //--------------------------------------------------------------------------   
    // Get device information by the device address.
    //--------------------------------------------------------------------------
    function getDevInfo(address addr) returns (string name, address dev_addr,
            string wireless, string resources) {
        Device dev = devices[addr];
        if ( dev.addr == 0x0) {
            // TODO: Exception
        }
        name = dev.name;
        dev_addr = dev.addr;
        wireless = dev.wireless_if;
        resources = dev.resources;
    }

    //--------------------------------------------------------------------------
    // Get all registered devices.
    //--------------------------------------------------------------------------
    //function getAllDevs() return (Device[] devs) {
        //return devices;
    //}

    //--------------------------------------------------------------------------
    // Remove DevicePool contract
    //--------------------------------------------------------------------------
    function remove() returns (bool res) {
        if (msg.sender == owner) {
            suicide(owner);
        }

    }
}

