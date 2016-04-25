
/* Relation contract
 */
contract RelationPool {
    address owner;
    // Map device addr to its related devices address list.
    mapping (address => address[]) relations;

    //------------------------------ Constructor -------------------------------
    function RelationPool() {
        owner = msg.sender;
    }

    //--------------------------------------------------------------------------
    // Add a related device
    //--------------------------------------------------------------------------
    function addRelation(address addr, address related) returns (bool res) {
        if (msg.sender != addr) return false;

        address[] relates = relations[addr];
        // Check if it's already in the list. CAUTION: This can be time consuming 
        // if the relates array is large.
        for (uint i=0; i < relates.length; i++) {
            if (relates[i] == related) return false;
        }
        relates.push(related);
        return true;
    }
    
    //--------------------------------------------------------------------------
    // Get all related devices of specified device.
    //--------------------------------------------------------------------------
    function getRelates(address addr) returns (address[] addrs) {
        if (relations[addr].length == 0) return;
        return relations[addr];
    }

    //--------------------------------------------------------------------------
    // Delete a related device.
    //--------------------------------------------------------------------------
    //function delelte(address addr, address toremove) return (bool res) {
        //if (msg.sender != addr || relations[addr] == 0x0) return false;

        //relations[addr].remove(toremvoe);
        //return true;
    //}

    //--------------------------------------------------------------------------
    // Remove the contruct
    //--------------------------------------------------------------------------
    function remove() {
        if (msg.sender == owner) {
            suicide(owner);
        }
    }
}
