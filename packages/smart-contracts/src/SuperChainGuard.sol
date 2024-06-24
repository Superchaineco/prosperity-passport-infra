// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IGuard} from "../interfaces/IGuard.sol";
import {Enum} from "../libraries/Enum.sol";
import {BaseGuard} from "../utils/BaseGuard.sol";

contract SuperChainGuard is BaseGuard {
    bytes4 private immutable ADD_OWNER_WITH_THRESHOLD_SELECTOR = 0x0d582f13;
    bytes4 private immutable REMOVE_OWNER_SELECTOR = 0xf8dc5dd9;
    bytes4 private immutable SWAP_OWNER_SELECTOR = 0xe318b52b;
    bytes4 private immutable CHANGE_THRESHOLD_SELECTOR = 0x694e80c3;

    error UnableToAddOwnersToDPGAccount();
    error UnableToRemoveOwnersFromDPGAccount();
    error UnableToSwapOwnersInDPGAccount();
    error UnableToChangeThresholdInDPGAccount();

    fallback() external {
        // We don't revert on fallback to avoid issues in case of a Safe upgrade
        // E.g. The expected check method might change and then the Safe would be locked.
    }


    /**
     * @notice Called by the Safe contract before a transaction is executed.
     * @dev Reverts if the transaction is related to update treshold owner.
     */
    function checkTransaction(
        address,
        uint256,
        bytes memory data,
        Enum.Operation,
        uint256,
        uint256,
        uint256,
        address,
        // solhint-disable-next-line no-unused-vars
        address payable,
        bytes memory,
        address 
    ) external override {
        if (data.length >= 4) {
            bytes4 selector;
            assembly {
                selector := mload(add(data, 0x20))
            }
            if (selector == ADD_OWNER_WITH_THRESHOLD_SELECTOR) {
                revert UnableToAddOwnersToDPGAccount();
            }
            if (selector == REMOVE_OWNER_SELECTOR) {
                revert UnableToAddOwnersToDPGAccount();
            }
            if (selector == SWAP_OWNER_SELECTOR) {
                revert UnableToAddOwnersToDPGAccount();
            }
            if (selector == CHANGE_THRESHOLD_SELECTOR) {
                revert UnableToAddOwnersToDPGAccount();
            }
        }
    }

    function checkModuleTransaction(
        address,
        uint256,
        bytes memory,
        Enum.Operation,
        address
    ) external override returns (bytes32 moduleTxHash) {}

    /**
     * @notice Called by the Safe contract after a module transaction is executed.
     * @dev No-op.
     */
    function checkAfterModuleExecution(bytes32, bool) external override {}

    /**
     * @notice Called by the Safe contract after a transaction is executed.
     * @dev No-op.
     */
    function checkAfterExecution(bytes32, bool) external view override {}
}
