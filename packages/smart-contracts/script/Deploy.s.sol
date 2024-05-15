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
        SuperChainGuard guard = new SuperChainGuard();
        SuperChainResolver resolver = new SuperChainResolver(
            IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e),
            msg.sender
        );
        SuperChainModule module = new SuperChainModule(address(resolver));
        resolver.updateSuperChainAccountsManager(module);
        console.logString(
            string.concat(
                "SuperChainModule deployed at: ",
                vm.toString(address(module)),
                "\n",
                "SuperChainGuard deployed at: ",
                vm.toString(address(guard)),
                "\n",
                "SuperChainResolver deployed at: ",
                vm.toString(address(resolver))
            )
        );
        vm.stopBroadcast();
    }
}
