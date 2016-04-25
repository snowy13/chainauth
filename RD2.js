/*
********************************************************************************
* Related device node 2
* AS in the use case is the Wemo switch.
* Workflow for this node is:
*   1. Register itself.
*   2. Confirm authentication (Next phase).
* Contracts used: devices.sol
********************************************************************************
*/

// requires
var fs = require('fs')
var erisC = require('eris-contracts');

var erisdbURL = "http://localhost:1337/rpc";

// get the abi and deployed data squared away
var contractData = require('./contracts/epm.json');
var devsContractAddress = contractData["deployDeviceK"];
var devsAbi = JSON.parse(fs.readFileSync("./contracts/abi/" + devsContractAddress));

var relsContractAddress = contractData["deployRelationK"];
var relsAbi = JSON.parse(fs.readFileSync("./contracts/abi/" + relsContractAddress))

// properly instantiate the contract objects manager using the erisdb URL
// and the account data (which is a temporary hack)
var accountData = require('./accounts.json');
var addrRD2 = accountData.authiot_authparticipant_RD2.address
var contractsManager = erisC.newContractManagerDev(erisdbURL,
                                        accountData.authiot_authparticipant_RD2);

// properly instantiate the contract objects using the abi and address
var devsContract = contractsManager.newContractFactory(devsAbi).
                                                        at(devsContractAddress);
var relsContract = contractsManager.newContractFactory(relsAbi).
                                                        at(relsContractAddress);

// Initialize
registerMe(function() {});

//------------------------------------------------------------------------------
// Register the node itself.
//------------------------------------------------------------------------------
function registerMe(callback) {
    register("RD2-Wemo Switch", "Wifi, bluetooth", "light, microphone", callback);
}

//------------------------------------------------------------------------------
// Register a device
//------------------------------------------------------------------------------
function register(name, wireless_if, resources, callback) {
    devsContract.register(name, wireless_if, resources, function(error, result) {
        if (error) { throw error }
        if (result) {
            // Retrieve and print device info.
            devsContract.getDevInfo(addrRD2, function(error, result) {
                    if (error) { throw error }
                    console.log("Device name: " + result[0]);
                    console.log("Device address: " + result[1]);
                    console.log("Wireless I/F: " + result[2]);
                    console.log("Resources: " + result[3]);
                }
            );
            callback();
        } else {
            // Unregister existing device. Then register.
            unregister();
            registerMe(callback);
        }
    });
}

//------------------------------------------------------------------------------
// Unregister the device.
//------------------------------------------------------------------------------
function unregister() {
    devsContract.unregister( function (error, result) {
        if (error) { throw error }
        if (result) {
            console.log("Unregistered " + addrRD2);
        } else {
            console.log("Unregistration failed!");
        }
    });
}

