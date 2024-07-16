// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainBadges,BadgeMetadata,BadgeTierMetadata} from "../src/SuperChainBadges.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        BadgeMetadata[] memory badges = new BadgeMetadata[](2);
        badges[0] = BadgeMetadata({
            badgeId: 1,
            generalURI: "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[1] = BadgeMetadata({
            badgeId: 2,
            generalURI: "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000.json"
        });
        

        BadgeTierMetadata[] memory badgeTiers = new BadgeTierMetadata[](4);
        badgeTiers[0] = BadgeTierMetadata({
            badgeId: 1,
            tier: 1,
            newURI: "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[1] = BadgeTierMetadata({
            badgeId: 1,
            tier: 2,
            newURI: "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002.json",
            points: 50
        });
        badgeTiers[2] = BadgeTierMetadata({
            badgeId: 2,
            tier: 1,
            newURI: "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[3] = BadgeTierMetadata({
            badgeId: 2,
            tier: 2,
            newURI: "ipfs/QmX2mMkn7hEuZUNyoUSwLECQvLFC7UDJhNgWcrqcT7np7L/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002.json",
            points: 50
        });

         SuperChainBadges badgesContract = new SuperChainBadges(badges, badgeTiers);
     

        console.logString(
            string.concat(
                "SuperChainBadges deployed at: ",
                vm.toString(address(badges))
            )
        );
        vm.stopBroadcast();
    }
}
