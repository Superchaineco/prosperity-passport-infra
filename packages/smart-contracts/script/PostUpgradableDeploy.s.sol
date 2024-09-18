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
        module.addTiersTreshold([50, 150, 400, 750, 1250, 2000, 3250, 5000, 7000, 10000]);

        vm.stopBroadcast();
    }
}