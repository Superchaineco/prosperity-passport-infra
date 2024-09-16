// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Defender, ApprovalProcessResponse} from "openzeppelin-foundry-upgrades/Defender.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {SuperChainModuleUpgradeable} from "../src/SuperChainModuleUpgradeable.sol";
import {SuperChainGuard} from "../src/SuperChainGuard.sol";
import {SuperChainResolver} from "../src/SuperChainResolver.sol";
import {SuperChainBadges, BadgeMetadata, BadgeTierMetadata} from "../src/SuperChainBadges.sol";
import {IEAS} from "eas-contracts/IEAS.sol";

contract DeployUpgradeable is Script {
    function setUp() public {}

    function run() public {
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

        BadgeMetadata[] memory badges = new BadgeMetadata[](6);
        badges[0] = BadgeMetadata({
            badgeId: 1,
            generalURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[1] = BadgeMetadata({
            badgeId: 2,
            generalURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000.json"
        });

        badges[2] = BadgeMetadata({
            badgeId: 3,
            generalURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[3] = BadgeMetadata({
            badgeId: 4,
            generalURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000.json"
        });

        badges[4] = BadgeMetadata({
            badgeId: 5,
            generalURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000.json"
        });
        badges[5] = BadgeMetadata({
            badgeId: 6,
            generalURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000.json"
        });

        BadgeTierMetadata[] memory badgeTiers = new BadgeTierMetadata[](19);
        badgeTiers[0] = BadgeTierMetadata({
            badgeId: 1,
            tier: 1,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001.json",
            points: 10
        });
        badgeTiers[1] = BadgeTierMetadata({
            badgeId: 1,
            tier: 2,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002.json",
            points: 20
        });
        badgeTiers[2] = BadgeTierMetadata({
            badgeId: 1,
            tier: 3,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000003.json",
            points: 30
        });
        badgeTiers[3] = BadgeTierMetadata({
            badgeId: 1,
            tier: 4,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000004.json",
            points: 40
        });
        badgeTiers[4] = BadgeTierMetadata({
            badgeId: 1,
            tier: 5,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000005.json",
            points: 50
        });

        // OP Mainnet User
        badgeTiers[5] = BadgeTierMetadata({
            badgeId: 2,
            tier: 1,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001.json",
            points: 10
        });
        badgeTiers[6] = BadgeTierMetadata({
            badgeId: 2,
            tier: 2,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002.json",
            points: 20
        });
        badgeTiers[7] = BadgeTierMetadata({
            badgeId: 2,
            tier: 3,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003.json",
            points: 30
        });
        badgeTiers[8] = BadgeTierMetadata({
            badgeId: 2,
            tier: 4,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004.json",
            points: 40
        });
        badgeTiers[9] = BadgeTierMetadata({
            badgeId: 2,
            tier: 5,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000005.json",
            points: 50
        });

        // Ethereum Sepolia User
        badgeTiers[10] = BadgeTierMetadata({
            badgeId: 3,
            tier: 1,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001.json",
            points: 20
        });
        badgeTiers[11] = BadgeTierMetadata({
            badgeId: 3,
            tier: 2,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000002.json",
            points: 80
        });

        // Mode User
        badgeTiers[12] = BadgeTierMetadata({
            badgeId: 4,
            tier: 1,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001.json",
            points: 10
        });
        badgeTiers[13] = BadgeTierMetadata({
            badgeId: 4,
            tier: 2,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002.json",
            points: 20
        });
        badgeTiers[14] = BadgeTierMetadata({
            badgeId: 4,
            tier: 3,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000003.json",
            points: 30
        });

        // Nouns
        badgeTiers[15] = BadgeTierMetadata({
            badgeId: 5,
            tier: 1,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000001.json",
            points: 10
        });
        badgeTiers[16] = BadgeTierMetadata({
            badgeId: 5,
            tier: 2,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000002.json",
            points: 20
        });
        badgeTiers[17] = BadgeTierMetadata({
            badgeId: 5,
            tier: 3,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000003.json",
            points: 30
        });

        //Citizen
        badgeTiers[18] = BadgeTierMetadata({
            badgeId: 6,
            tier: 1,
            newURI: "ipfs/QmPp9Zac4YbUQ79KKwPptLHZarVZLWEZB2uj2cS5y4N4dD/00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000001.json",
            points: 100
        });
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
        ApprovalProcessResponse memory upgradeApprovalProcess = Defender
            .getUpgradeApprovalProcess();
        if (upgradeApprovalProcess.via == address(0)) {
            revert(
                string.concat(
                    "Upgrade approval process with id ",
                    upgradeApprovalProcess.approvalProcessId,
                    " has no assigned address"
                )
            );
        }
        Options memory opts;
        opts.defender.useDefenderDeploy = true;

        address proxy = Upgrades.deployUUPSProxy(
            "SuperChainModuleUpgradeable.sol",
            abi.encodeCall(
                SuperChainModuleUpgradeable.initialize,
                (address(resolver), address(msg.sender))
            ),
            opts
        );

        resolver.updateSuperChainAccountsManager(SuperChainModuleUpgradeable(proxy));

        vm.stopBroadcast();
        console.log("Deployed proxy to address", proxy);
    }
}
