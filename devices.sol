
/*
 * Contract to keep track of all the registered devices in the network. 
 */
contract DevicePool {
    address owner;
    // Device representation struct.
    struct device_t {
        name,
        reg_date,
        wireless_if,
        resources
    };
    // Stored devices 
    mapping<address, device_t> devices;

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
        reg_date = current_date;
        device = new device_t(name, reg_date, wireless_if, resources);
        
        devices[msg.sender] = device;

        return true;
    }

    //--------------------------------------------------------------------------
    // Unregister a device
    //--------------------------------------------------------------------------
    function unregister(byte32 name) {
        devices[msg.sender] = 0x0;
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

