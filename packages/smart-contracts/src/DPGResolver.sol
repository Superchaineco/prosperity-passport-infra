// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SchemaResolver} from "eas-contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "eas-contracts/IEAS.sol";
import {DPGModule} from "./DPGModule.sol";

contract DPGResolver is SchemaResolver {
    DPGModule public dpgModule;
    address private immutable _attestator;

    constructor(IEAS eas, address attestator) SchemaResolver(eas) {
        _attestator = attestator;
    }

    // This might be onlyOwner
    function updateSuperChainAccountsManager(
        DPGModule _DPGModule
    ) public {
        dpgModule = _DPGModule;
    }

    function onAttest(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
        if (attestation.attester != _attestator) {
            return false;
        }
        uint256 points = abi.decode(attestation.data, (uint256));
        dpgModule
            .incrementDPGPoints(
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
