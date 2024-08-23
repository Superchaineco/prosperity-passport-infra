// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainBadges, BadgeMetadata, BadgeTierMetadata} from "../src/SuperChainBadges.sol";

contract AddBadges is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        SuperChainBadges badgesContract = SuperChainBadges(
            payable(0x972Be3883862d85d726E01129e99C2A69b6529a6)
        );
        BadgeMetadata[] memory badges = new BadgeMetadata[](2);
        badges[0] = BadgeMetadata({
            badgeId: 7,
            generalURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[1] = BadgeMetadata({
            badgeId: 8,
            generalURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000.json"
        });

        BadgeTierMetadata[] memory badgeTiers = new BadgeTierMetadata[](8);
        badgeTiers[0] = BadgeTierMetadata({
            badgeId: 7,
            tier: 1,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000001.json",
            points: 10
        });
        badgeTiers[1] = BadgeTierMetadata({
            badgeId: 7,
            tier: 2,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000002.json",
            points: 20
        });
        badgeTiers[2] = BadgeTierMetadata({
            badgeId: 7,
            tier: 3,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000003.json",
            points: 30
        });
        badgeTiers[3] = BadgeTierMetadata({
            badgeId: 7,
            tier: 4,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000004.json",
            points: 40
        });
         badgeTiers[4] = BadgeTierMetadata({
            badgeId: 8,
            tier: 1,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000001.json",
            points: 10
        });
        badgeTiers[5] = BadgeTierMetadata({
            badgeId: 8,
            tier: 2,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000002.json",
            points: 20
        });
        badgeTiers[6] = BadgeTierMetadata({
            badgeId: 8,
            tier: 3,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000003.json",
            points: 30
        });
        badgeTiers[7] = BadgeTierMetadata({
            badgeId: 8,
            tier: 4,
            newURI: "ipfs/QmbUwFGR4BTBh6gZv6Sa8T3ZrjoxZaB4CLsQx71JP9Jj4H/00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000004.json",
            points: 40
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
