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
        uint256[] memory tresholds = new uint256[](10);
        tresholds[0] = 50;
        tresholds[1] = 150;
        tresholds[2] = 400;
        tresholds[3] = 750;
        tresholds[4] = 1250;
        tresholds[5] = 2000;
        tresholds[6] = 3250;
        tresholds[7] = 5000;
        tresholds[8] = 7000;
        tresholds[9] = 10000;
        module.addTiersTreshold(tresholds);

        vm.stopBroadcast();
    }
}