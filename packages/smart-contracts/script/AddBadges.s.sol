// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainBadges, BadgeMetadata, BadgeTierMetadata} from "../src/SuperChainBadges.sol";

contract AddBadges is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        SuperChainBadges badgesContract = SuperChainBadges(
            payable(0x8D7D367D85Ba078B431c383722b37ed89C2f7633)
        );
        BadgeMetadata[] memory badges = new BadgeMetadata[](2);
        badges[0] = BadgeMetadata({
            badgeId: 5,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[1] = BadgeMetadata({
            badgeId: 6,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000.json"
        });

        BadgeTierMetadata[] memory badgeTiers = new BadgeTierMetadata[](3);
        badgeTiers[0] = BadgeTierMetadata({
            badgeId: 5,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[1] = BadgeTierMetadata({
            badgeId: 5,
            tier: 2,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000002.json",
            points: 50
        });
        badgeTiers[2] = BadgeTierMetadata({
            badgeId: 6,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });

        for (uint256 i = 0; i < badges.length; i++) {
            badgesContract.setBadgeMetadata(badges[i].badgeId,badges[i].generalURI);
        }
        for (uint256 i = 0; i < badgeTiers.length; i++) {
            badgesContract.setBadgeTier(badgeTiers[i].badgeId, badgeTiers[i].tier, badgeTiers[i].newURI, badgeTiers[i].points);
        }

        vm.stopBroadcast();
    }
}
