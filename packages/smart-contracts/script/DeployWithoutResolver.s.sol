// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainGuard} from "../src/SuperChainGuard.sol";
import {SuperChainModule} from "../src/SuperChainModule.sol";
import {SuperChainResolver} from "../src/SuperChainResolver.sol";
import {IEAS} from "eas-contracts/IEAS.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // SuperChainGuard guard = new SuperChainGuard();
        SuperChainResolver resolver = SuperChainResolver(
            payable(0xD8060F8f0C3DD073F7c7676d31156d7A712a239c)
        );
        SuperChainModule module = new SuperChainModule(address(resolver));
        resolver.updateSuperChainAccountsManager(module);
        module._addTierTreshold(10);
        module._addTierTreshold(50);
        module._addTierTreshold(100);

        console.logString(
            string.concat(
                "SuperChainModule deployed at: ",
                vm.toString(address(module))
                // "\n",
                // "SuperChainGuard deployed at: ",
                // vm.toString(address(guard)),
                // "\n",
                // "SuperChainResolver deployed at: ",
                // vm.toString(address(resolver))
            )
        );
        vm.stopBroadcast();
    }
}
