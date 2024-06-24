// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainBadges} from "../src/SuperChainBadges.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        SuperChainBadges badges = new SuperChainBadges();
        badges.setBadgeLevel(1,1,"https://picsum.photos/id/1/200/300", 10);
        badges.setBadgeLevel(1,2,"https://picsum.photos/id/2/200/300", 20);
        badges.setBadgeLevel(1,3,"https://picsum.photos/id/3/200/300", 30);

        console.logString(
            string.concat(
              
                "SuperChainBadges deployed at: ",
                vm.toString(address(badges))
               
            )
        );
        vm.stopBroadcast();
    }
}
