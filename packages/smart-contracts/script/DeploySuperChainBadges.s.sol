// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainBadges} from "../src/SuperChainBadges.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        SuperChainBadges badges = new SuperChainBadges();
        badges.setBadgeMetadata(
            1,
            "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000.json"
        );
        badges.setBadgeMetadata(
            2,
            "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000.json"
        );
        badges.setBadgeTier(
            1,
            1,
            "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001.json",
            20
        );
        badges.setBadgeTier(
            1,
            2,
            "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002.json",
            50
        );
    
        badges.setBadgeTier(
            2,
            1,
            "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001.json",
            20
        );
        badges.setBadgeTier(
            2,
            2,
            "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002.json",
            50
        );
     

        console.logString(
            string.concat(
                "SuperChainBadges deployed at: ",
                vm.toString(address(badges))
            )
        );
        vm.stopBroadcast();
    }
}
