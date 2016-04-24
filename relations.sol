
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
    function add(address addr, address related) returns (bool res) {
        if (msg.sender != addr) return false;

        if (relations[addr] != 0x0) {
            relations[addr].add(related);
        } else {
            relations[addr] = [related];
        }
        return true;
    }

    //--------------------------------------------------------------------------
    // Delete a related device.
    //--------------------------------------------------------------------------
    function del(address addr, address toremove) return (bool res) {
        if (msg.sender != addr || relations[addr] == 0x0) return false;

        relations[addr].remove(toremvoe);
        return true;
    }

    //--------------------------------------------------------------------------
    // Remove the contruct
    //--------------------------------------------------------------------------
    function remove() {
        if (msg.sender == owner) {
            suicide(owner);
        }
    }
}
