// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SchemaResolver} from "eas-contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "eas-contracts/IEAS.sol";
import {SuperChainModule} from "./SuperChainModule.sol";
import "./SuperChainBadges.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SuperChainResolver is SchemaResolver, Ownable {
    SuperChainModule public superChainModule;
    SuperChainBadges public superChainBadges;
    address private immutable _attestator;

    constructor(
        IEAS eas,
        address attestator,
        SuperChainBadges _superChainBadges
    ) Ownable(msg.sender) SchemaResolver(eas) {
        _attestator = attestator;
        superChainBadges = _superChainBadges;
    }

    // This might be onlyOwner
    function updateSuperChainAccountsManager(
        SuperChainModule _SuperChainModule
    ) public onlyOwner {
        superChainModule = _SuperChainModule;
    }

    function onAttest(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
        if (attestation.attester != _attestator) {
            return false;
        }
        BadgeUpdate[] memory badgeUpdates = abi.decode(
            attestation.data,
            (BadgeUpdate[])
        );
        uint256[] memory badgeIds = [];
        uint256[] memory levels = [];
        uint256 points = superChainBadges.updateOrMintBadges(
            attestation.recipient,
            badgeUpdates
        );

        superChainModule.incrementSuperChainPoints(
            points,
            attestation.recipient
        );
        return true;
    }

    function onRevoke(
        Attestation calldata,
        /*attestation*/ uint256 /*value*/
    ) internal pure override returns (bool) {
        return true;
    }
}
