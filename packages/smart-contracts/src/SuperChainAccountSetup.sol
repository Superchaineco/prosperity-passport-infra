// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.23;

import "../interfaces/ISafe.sol";
import "./SuperChainModuleUpgradeable.sol";

/**
 * @title SuperChainAccountSetup - A utility contract for setting up a Safe with modules and guards.
 * @dev The SuperChainAccountSetup `setup` function accepts `to` and `data` parameters for a delegate call during initialization. This
 *      contract can be specified as the `to` with `data` ABI encoding the `enableModules` call so that a Safe is
 *      created with the specified modules. In particular, this allows a ERC-4337 compatible Safe to be created as part
 *      of a ERC-4337 user operation with the `Safe4337Module` enabled right away.
 */
contract SuperChainAccountSetup {
    /**
     * @notice Enable the specified Safe modules.
     * @dev This call will only work if used from a Safe via delegatecall. It is intended to be used as part of the
     *      Safe `setup`, allowing Safes to be created with an initial set of enabled modules.
     * @param modules The modules to enable.
     * @param superChainModule The SuperChainModule to enable.
     * @param guard The guard to set.
     * @param owner The owner to set.
     * @param seed The seed to set.
     * @param superChainID The superChainID to set.
     */
    function setupSuperChainAccount(
        address[] calldata modules,
        address superChainModule,
        address guard,
        address owner,
        NounMetadata memory seed,
        string calldata superChainID
    ) external {
        for (uint256 i = 0; i < modules.length; i++) {
            ISafe(address(this)).enableModule(modules[i]);
        }
        ISafe(address(this)).enableModule(superChainModule);
        ISafe(address(this)).setGuard(guard);
        SuperChainModuleUpgradeable(superChainModule).setInitialOwner(
            address(this),
            owner,
            seed,
            superChainID
        );
    }
}
