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
        address resolver = vm.envAddress("RESOLVER_ADDRESS");
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
                (resolver, address(upgradeApprovalProcess.via))
            ),
            opts
        );
        string memory proxyAddress = vm.toString(proxy);
        string memory constructorArgs = vm.toString(
            abi.encodeCall(
                SuperChainModuleUpgradeable.initialize,
                (resolver, address(upgradeApprovalProcess.via))
            )
        );

        string memory filePath = "deploy_data_upgradeable.txt";
        vm.writeFile(
            filePath,
            string.concat("Proxy Address: ", proxyAddress, "\n", "Constructor Args: ", constructorArgs)
        );
        console.log(
            "Constructor args: ",
            vm.toString(
                abi.encodeCall(
                    SuperChainModuleUpgradeable.initialize,
                (address(resolver), address(upgradeApprovalProcess.via))
            ))
        );
        // vm.envSet("PROXY_ADDRESS", proxy);

        console.log("Deployed proxy to address", proxy);
    }
}
