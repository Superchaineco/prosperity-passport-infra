// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SuperChainModuleUpgradeable} from "../src/SuperChainModuleUpgradeable.sol";

contract PostUpgradableDeploy is Script {
    function setUp() public {}

    function run() public {
        address proxy = vm.envAddress("PROXY_ADDRESS");
        vm.startBroadcast();

        SuperChainModuleUpgradeable module = SuperChainModuleUpgradeable(proxy);
        module._addTierTreshold(100);
        module._addTierTreshold(250);
        module._addTierTreshold(500);

        vm.stopBroadcast();
    }
}