// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SuperChainModuleUpgradeable} from "../src/SuperChainModuleUpgradeable.sol";
import {SuperChainResolver} from "../src/SuperChainResolver.sol";
contract PostUpgradableDeploy is Script {
    function setUp() public {}

    function run() public {
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address resolverAddress = vm.envAddress("RESOLVER_ADDRESS");
        vm.startBroadcast();
        SuperChainResolver resolver = SuperChainResolver(payable(resolverAddress));

        resolver.updateSuperChainAccountsManager(
            SuperChainModuleUpgradeable(proxy)
        );

        SuperChainModuleUpgradeable module = SuperChainModuleUpgradeable(proxy);
        module._addTierTreshold(100);
        module._addTierTreshold(250);
        module._addTierTreshold(500);

        vm.stopBroadcast();
    }
}