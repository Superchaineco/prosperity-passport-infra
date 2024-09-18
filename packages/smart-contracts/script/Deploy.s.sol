// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainGuard} from "../src/SuperChainGuard.sol";
import {SuperChainResolver} from "../src/SuperChainResolver.sol";
import {SuperChainBadges, BadgeMetadata, BadgeTierMetadata} from "../src/SuperChainBadges.sol";
import "./ScriptReader.s.sol";
import {IEAS} from "eas-contracts/IEAS.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        JSONReader jsonReader = new JSONReader();
        (JSON memory badgesJson, uint256 tierCount) = jsonReader.run();
        BadgeMetadata[] memory badges = new BadgeMetadata[](
            badgesJson.badges.length
        );
        BadgeTierMetadata[] memory badgeTiers = new BadgeTierMetadata[](
            tierCount
        );
        for (uint256 i = 0; i < badgesJson.badges.length; i++) {
            badges[i] = BadgeMetadata({
                badgeId: i + 1,
                generalURI: badgesJson.badges[i].URI
            });
        }
        uint256 tierIndex = 0;
        for (uint256 i = 0; i < badgesJson.badges.length; i++) {
            for (uint256 j = 0; j < badgesJson.badges[i].levels.length; j++) {
                badgeTiers[tierIndex] = BadgeTierMetadata({
                    badgeId: i + 1,
                    tier: j + 1,
                    newURI: badgesJson.badges[i].levels[j].URI,
                    points: badgesJson.badges[i].levels[j].points
                });
                tierIndex++;
            }
        }

        // console.log("Badges:");
        // for (uint256 i = 0; i < badges.length; i++) {
        //     console.log("Badge ID:", badges[i].badgeId);
        //     console.log("Badge General URI:", badges[i].generalURI);
        // }

        // console.log("Badge Tiers:");
        // for (uint256 i = 0; i < badgeTiers.length; i++) {
        //     console.log("Badge ID:", badgeTiers[i].badgeId);
        //     console.log("Tier:", badgeTiers[i].tier);
        //     console.log("New URI:", badgeTiers[i].newURI);
        //     console.log("Points:", badgeTiers[i].points);
        // }

        vm.startBroadcast();

        string memory network = vm.envString("NETWORK");
        address easAddress;
        if (keccak256(bytes(network)) == keccak256("sepolia")) {
            easAddress = vm.envAddress("EAS_ADDRESS_SEPOLIA");
        } else if (keccak256(bytes(network)) == keccak256("optimism")) {
            easAddress = vm.envAddress("EAS_ADDRESS_OPTIMISM");
        } else {
            revert("Unsupported network");
        }
        require(
            easAddress != address(0),
            "EAS address is not set for this network"
        );

        SuperChainBadges badgesContract = new SuperChainBadges(
            badges,
            badgeTiers
        );

        SuperChainGuard guard = new SuperChainGuard();
        SuperChainResolver resolver = new SuperChainResolver(
            IEAS(easAddress),
            msg.sender,
            badgesContract
        );

        console.logString(
            string.concat(
                "SuperChainBadges deployed at: ",
                vm.toString(address(badgesContract)),
                "\n",
                "SuperChainGuard deployed at: ",
                vm.toString(address(guard)),
                "\n",
                "SuperChainResolver deployed at: ",
                vm.toString(address(resolver)),
                "\n",
                "EAS Address: ",
                vm.toString(easAddress)
            )
        );

        vm.stopBroadcast();
    }
}
