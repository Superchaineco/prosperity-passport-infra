// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IGuard} from "../interfaces/IGuard.sol";
import {Enum} from "../libraries/Enum.sol";

contract DPGGuard is IGuard {
    bytes4 private ADD_OWNER_WITH_THRESHOLD_SELECTOR = 0x0d582f13;
    error UnableToAddOwnersToDPGAccount();

    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {
        return interfaceId == type(IGuard).interfaceId;
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external override {
        if (data.length >= 4) {
            bytes4 selector;
            assembly {
                selector := mload(add(data, 0x20))
            }
            if (selector == ADD_OWNER_WITH_THRESHOLD_SELECTOR) {
                revert UnableToAddOwnersToDPGAccount();
            }
        }
    }

    function checkModuleTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        address module
    ) external override returns (bytes32 moduleTxHash) {}

    function checkAfterExecution(
        bytes32 hash,
        bool success
    ) external override {}
}
