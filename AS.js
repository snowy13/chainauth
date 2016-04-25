/*
********************************************************************************
* Authencication Subject Node
* AS in the use case is the philips hue bridge.
* Workflow for this node is:
*   1. Register itself.
*   2. Add related devices.
* Contracts used: devices.sol, relations.sol
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
var addrAS = accountData.authiot_authparticipant_AS.address;
var addrRD1 = accountData.authiot_authparticipant_RD1.address;
var addrRD2 = accountData.authiot_authparticipant_RD2.address;

// AS contract manager
var contractsManager = erisC.newContractManagerDev(erisdbURL,
                                        accountData.authiot_authparticipant_AS);

// properly instantiate the contract objects using the abi and address
var devsContract = contractsManager.newContractFactory(devsAbi).
                                                at(devsContractAddress);
var relsContract = contractsManager.newContractFactory(relsAbi).
                                                at(relsContractAddress);

// Initialize
registerMe(addRelations);

//------------------------------------------------------------------------------
// Register the node itself.
//------------------------------------------------------------------------------
function registerMe(callback) {
  register("AS-Hue Bridge", "Wifi, bluetooth", "light, speaker", callback);
}

//------------------------------------------------------------------------------
// Add relations to AS.
// Used as callback after registering itself.
//------------------------------------------------------------------------------
function addRelations() {
  // Add related device RD1 and RD2
  addRelation(addrAS, addrRD1);
  addRelation(addrAS, addrRD2);
}

//------------------------------------------------------------------------------
// Register a device
//------------------------------------------------------------------------------
function register(name, wireless_if, resources, callback) {
    devsContract.register(name, wireless_if, resources, function(error, result) {
        if (error) { throw error }
        if (result) {
            // Retrieve and print device info.
            devsContract.getDevInfo(addrAS, function(error, result) {
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
// Add a related device pair.
//------------------------------------------------------------------------------
function addRelation(addr, related) {
    relsContract.addRelation(addr, related, function (error, result) {
        if (error) { throw error }
        if (result) {
            console.log("Added new related device: " + related);
        }
        // Retrieve related devices.
        //relsContract.getRelates(addr,
         //   function(error, result) {
        //        if (error) { throw error}
         //       for (var i=0; i < result.length; i++)
          //          console.log("Related devices " + "(" + (i+1) + "): " + result[i]);
           // }
        //);
    });
}

//------------------------------------------------------------------------------
// Unregister the device.
//------------------------------------------------------------------------------
function unregister() {
    devsContract.unregister( function (error, result) {
        if (error) { throw error }
        if (result) {
            console.log("Unregistered " + accountData.authiot_authexecutor_AE.address)
        } else {
            console.log("Unregistration failed!")
        }
    });
}

