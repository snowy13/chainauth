
/*
 * Contract to keep track of all the registered devices in the network. 
 */
contract DevicePool {
    address owner;
    // Device representation struct.
    struct Device {
        byte32 name,
        uint32 reg_ts,
        byte32[] wireless_if,
        byte32[] resources
    };
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
    function register(byte32 name, byte32[] wireless_if, byte32[] resources) 
                      returns (bool res) {
        // Return false if already registered.
        if (devices[msg.sender] != 0x0) {
            return false;
        }
        reg_ts = 100000; //current_ts;
        device = new Device(name, reg_ts, wireless_if, resources);
        
        devices[msg.sender] = device;

        return true;
    }

    //--------------------------------------------------------------------------
    // Unregister a device
    //--------------------------------------------------------------------------
    function unregister() returns (bool res) {
        if (devices[msg.sender] == 0x0) {
            return false;
        }
        devices[msg.sender] = 0x0;
        return true;
    }
    
    //--------------------------------------------------------------------------
    // Remove DevicePool contract
    //--------------------------------------------------------------------------
    function remove() returns (bool res) {
        if (msg.sender == owner) {
            suicide(owner);
        }

    }
}

