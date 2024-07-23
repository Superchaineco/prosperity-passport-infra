// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuperChainGuard} from "../src/SuperChainGuard.sol";
import {SuperChainModule} from "../src/SuperChainModule.sol";
import {SuperChainResolver} from "../src/SuperChainResolver.sol";
import {SuperChainBadges, BadgeMetadata, BadgeTierMetadata} from "../src/SuperChainBadges.sol";
import {IEAS} from "eas-contracts/IEAS.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        BadgeMetadata[] memory badges = new BadgeMetadata[](6);
        badges[0] = BadgeMetadata({
            badgeId: 1,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[1] = BadgeMetadata({
            badgeId: 2,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000.json"
        });

        badges[2] = BadgeMetadata({
            badgeId: 3,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[3] = BadgeMetadata({
            badgeId: 4,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000.json"
        });

        badges[4] = BadgeMetadata({
            badgeId: 5,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[5] = BadgeMetadata({
            badgeId: 6,
            generalURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000.json"
        });

        BadgeTierMetadata[] memory badgeTiers = new BadgeTierMetadata[](11);
        badgeTiers[0] = BadgeTierMetadata({
            badgeId: 1,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[1] = BadgeTierMetadata({
            badgeId: 1,
            tier: 2,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002.json",
            points: 50
        });
        badgeTiers[2] = BadgeTierMetadata({
            badgeId: 2,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[3] = BadgeTierMetadata({
            badgeId: 2,
            tier: 2,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002.json",
            points: 50
        });

        badgeTiers[4] = BadgeTierMetadata({
            badgeId: 3,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[5] = BadgeTierMetadata({
            badgeId: 3,
            tier: 2,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000002.json",
            points: 80
        });
        badgeTiers[6] = BadgeTierMetadata({
            badgeId: 4,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[7] = BadgeTierMetadata({
            badgeId: 4,
            tier: 2,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002.json",
            points: 50
        });
        badgeTiers[8] = BadgeTierMetadata({
            badgeId: 5,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[9] = BadgeTierMetadata({
            badgeId: 5,
            tier: 2,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000002.json",
            points: 50
        });
        badgeTiers[10] = BadgeTierMetadata({
            badgeId: 6,
            tier: 1,
            newURI: "ipfs/Qmej7BDXB8hFe28P7uQKY5ECH1UhzLR2uawNpoXMDTQr1x/00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        SuperChainBadges badgesContract = new SuperChainBadges(
            badges,
            badgeTiers
        );

        SuperChainGuard guard = new SuperChainGuard();
        SuperChainResolver resolver = new SuperChainResolver(
            IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e),
            msg.sender,
            badgesContract
        );
        SuperChainModule module = new SuperChainModule(address(resolver));
        module._addTierTreshold(100);
        module._addTierTreshold(250);
        module._addTierTreshold(500);
        resolver.updateSuperChainAccountsManager(module);

        console.logString(
            string.concat(
                "SuperChainModule deployed at: ",
                vm.toString(address(module)),
                "\n",
                "SuperChainBadges deployed at: ",
                vm.toString(address(badgesContract)),
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
