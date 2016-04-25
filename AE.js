/*
********************************************************************************
* Authencication Executor Node
* AE in the use case is the nest thermostat.
* Workflow for this node is:
*   1. Retrieve related devices of AS.
*   2. Print each device information.
*   3. Select authentcating devices and generate tokens for them (next phase).
*   4. Set authentication contract and send tokens to AS (next phase).
* Contracts used: devices.sol, relations.sol
********************************************************************************
*/

// requires
var fs = require('fs')
var erisC = require('eris-contracts');

// NOTE. On Windows/OSX do not use localhost. use host IP address instead.
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
var addrAE = accountData.authiot_authexecutor_AE.address;
var contractsManager = erisC.newContractManagerDev(erisdbURL, 
                                        accountData.authiot_authexecutor_AE);

// properly instantiate the contract objects using the abi and address
var devsContract = contractsManager.newContractFactory(devsAbi).
                                                    at(devsContractAddress);
var relsContract = contractsManager.newContractFactory(relsAbi).
                                                    at(relsContractAddress);

var devs = getRelatedDevices(addrAS, retrieveAllDevs);

//------------------------------------------------------------------------------
// Retrieve all devices info. 
// Used as callback after get related devices.
//------------------------------------------------------------------------------
function retrieveAllDevs(devs) {
    for (var i=0; i < devs.length; i++) {
        retrieveDevInfo(devs[i]);
    }
}

//------------------------------------------------------------------------------
// Retrieve device information
//------------------------------------------------------------------------------
function retrieveDevInfo(addr) {
    devsContract.getDevInfo(addr, function(error, result) {
            if (error) { throw error }
            if (result[0] != "") {
                console.log();
                console.log("Device name: " + result[0]);
                console.log("Device address: " + result[1]);
                console.log("Wireless I/F: " + result[2]);
                console.log("Resources: " + result[3]);
            } else {
                console.log("No device info for " + addr);
            }
        }
    );
}

//------------------------------------------------------------------------------
// Find all related devices of the specified address.
//------------------------------------------------------------------------------
function getRelatedDevices(addr, callback) {
    // Retrieve related devices.
    relsContract.getRelates(addr, function(error, result) {
        if (error) { throw error}
        for (var i=0; i < result.length; i++)
            console.log("Related devices " + "(" + (i+1) + "): " + result[i]);
        callback(result);
    });
}


