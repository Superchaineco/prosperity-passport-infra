// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Defender, ApprovalProcessResponse} from "openzeppelin-foundry-upgrades/Defender.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {SuperChainModuleUpgradeable} from "../src/SuperChainModuleUpgradeable.sol";
import {SuperChainGuard} from "../src/SuperChainGuard.sol";
import {SuperChainResolver} from "../src/SuperChainResolver.sol";
import {SuperChainBadges, BadgeMetadata, BadgeTierMetadata} from "../src/SuperChainBadges.sol";
import "./JSONReader.s.sol";
import {IEAS} from "eas-contracts/IEAS.sol";

contract DeployUpgradeable is Script {
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
        vm.startBroadcast();

        SuperChainGuard guard = new SuperChainGuard();
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

        address badgesProxy = Upgrades.deployUUPSProxy(
            "SuperChainBadges.sol",
            abi.encodeCall(
                SuperChainBadges.initialize,
                (badges, badgeTiers, msg.sender)
            ),
            opts
        );

        SuperChainResolver resolver = new SuperChainResolver(
            IEAS(easAddress),
            msg.sender,
            SuperChainBadges(badgesProxy),
            msg.sender
        );

        SuperChainBadges(badgesProxy).setResolver(address(resolver));

        address moduleProxy = Upgrades.deployUUPSProxy(
            "SuperChainModuleUpgradeable.sol",
            abi.encodeCall(
                SuperChainModuleUpgradeable.initialize,
                (address(resolver), msg.sender)
            ),
            opts
        );
        resolver.updateSuperChainAccountsManager(
            SuperChainModuleUpgradeable(moduleProxy)
        );

        SuperChainModuleUpgradeable module = SuperChainModuleUpgradeable(
            moduleProxy
        );
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
        logs(
            badgesProxy,
            moduleProxy,
            badges,
            badgeTiers,
            address(resolver),
            address(guard),
            easAddress
        );
    }

    function logs(
        address badgesProxy,
        address moduleProxy,
        BadgeMetadata[] memory badges,
        BadgeTierMetadata[] memory badgeTiers,
        address resolver,
        address guard,
        address easAddress
    ) public {
        string memory badgesProxyAddress = vm.toString(badgesProxy);
        string memory badgesConstructorArgs = vm.toString(
            abi.encodeCall(
                SuperChainBadges.initialize,
                (badges, badgeTiers, msg.sender)
            )
        );
        string memory proxyAddress = vm.toString(moduleProxy);
        string memory constructorArgs = vm.toString(
            abi.encodeCall(
                SuperChainModuleUpgradeable.initialize,
                (resolver, msg.sender)
            )
        );

        string memory filePath = "deploy_data_upgradeable.txt";
        vm.writeFile(
            filePath,
            string.concat(
                "Proxy Address: ",
                proxyAddress,
                "\n",
                "Constructor Args: ",
                constructorArgs,
                "\n",
                "Badges Proxy Address: ",
                badgesProxyAddress,
                "\n",
                "Badges Constructor Args: ",
                badgesConstructorArgs
            )
        );

        console.log("Deployed moduleProxy to address", moduleProxy);
        console.log("Deployed badgesProxy to address", badgesProxy);
        console.logString(
            string.concat(
                "\n",
                "SuperChainGuard deployed at: ",
                vm.toString(guard),
                "\n",
                "SuperChainResolver deployed at: ",
                vm.toString(resolver),
                "\n",
                "EAS Address: ",
                vm.toString(easAddress)
            )
        );
    }
}
