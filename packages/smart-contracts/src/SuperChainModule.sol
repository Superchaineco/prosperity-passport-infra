// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ISafe} from "../interfaces/ISafe.sol";
import {Enum} from "../libraries/Enum.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ISuperChainModule.sol";

contract SuperChainModule is ISuperChainModule, EIP712, Ownable {
  

    mapping(address => mapping(address => bool))
        private _isPopulatedAddOwnerWithThreshold;
    mapping(address => address[]) public populatedAddOwnersWithTreshold;
    mapping(address => Account) public superChainAccount;
    mapping(address => address) public userSuperChainAccount;
    mapping(address => bool) public hasFirstOwnerYet;
    mapping(string => bool) public SuperChainIDRegistered;

    address private _resolver;
    uint256[] private _tierTreshold;


    constructor(
        address resolver
    ) EIP712("SuperChainAccountModule", "1") Ownable(msg.sender) {
        _resolver = resolver;
    }

    function addOwnerWithThreshold(
        address _safe,
        address _newOwner
    ) public firstOwnerSet(_safe) {
        require(msg.sender == _newOwner, "Caller is not the new owner");
        require(
            userSuperChainAccount[_newOwner] == address(0),
            "Owner already has a SuperChainAccount"
        );
        require(
            _isPopulatedAddOwnerWithThreshold[_newOwner][_safe],
            "Owner not populated"
        );
        for (
            uint i = 0;
            i < populatedAddOwnersWithTreshold[_safe].length;
            i++
        ) {
            if (populatedAddOwnersWithTreshold[_safe][i] == _newOwner) {
                populatedAddOwnersWithTreshold[_safe][
                    i
                ] = populatedAddOwnersWithTreshold[_safe][
                    populatedAddOwnersWithTreshold[_safe].length - 1
                ];
                populatedAddOwnersWithTreshold[_safe].pop();
                break;
            }
        }
        bytes memory data = abi.encodeWithSignature(
            "addOwnerWithThreshold(address,uint256)",
            _newOwner,
            1
        );
        bool success = ISafe(_safe).execTransactionFromModule(
            _safe,
            0,
            data,
            Enum.Operation.Call
        );

        require(success, "Failed to add owner");
        userSuperChainAccount[_newOwner] = _safe;
        emit OwnerAdded(
            _safe,
            _newOwner,
            superChainAccount[_safe].superChainID
        );
    }

    function removePopulateRequest(address _safe, address user) public {
        require(
            _isPopulatedAddOwnerWithThreshold[user][_safe],
            "Owner not populated"
        );
        require(ISafe(_safe).isOwner(msg.sender) || _isPopulatedAddOwnerWithThreshold[msg.sender][_safe] || msg.sender == _safe  , "The address is not an owner or the populated user");
        for (
            uint i = 0;
            i < populatedAddOwnersWithTreshold[_safe].length;
            i++
        ) {
            if (populatedAddOwnersWithTreshold[_safe][i] == user) {
                Account memory _account = superChainAccount[_safe];
                populatedAddOwnersWithTreshold[_safe][
                    i
                ] = populatedAddOwnersWithTreshold[_safe][
                    populatedAddOwnersWithTreshold[_safe].length - 1
                ];
                populatedAddOwnersWithTreshold[_safe].pop();
                _isPopulatedAddOwnerWithThreshold[user][_safe] = false;
                emit OwnerPopulationRemoved(_safe, user, _account.superChainID);
                break;
            }
        }
    }

    function setInitialOwner(
        address _safe,
        address _owner,
        NounMetadata calldata _noun,
        string calldata superChainID
    ) public {
        require(
            userSuperChainAccount[_owner] == address(0),
            "Owner already has a SuperChainSmartAccount"
        );
        require(ISafe(_safe).isOwner(_owner), "The address is not an owner");
        require(
            msg.sender == _safe,
            "Caller is not the SuperChainSmartAccount"
        );
        require(
            !hasFirstOwnerYet[_safe],
            "SuperChainSmartAccount already has owners"
        );
        require(
            ISafe(_safe).getOwners().length == 1,
            "SuperChainSmartAccount already has owners"
        );
        require(
            !_isInvalidSuperChainId(superChainID),
            "The last 11 characters cannot be '.superchain'"
        );
        require(
            !SuperChainIDRegistered[superChainID],
            "The superchain ID was registered yet."
        );
        superChainAccount[_safe].smartAccount = _safe;
        userSuperChainAccount[_owner] = _safe;
        superChainAccount[_safe].superChainID = string.concat(
            superChainID,
            ".superchain"
        );
        SuperChainIDRegistered[superChainID] = true;
        hasFirstOwnerYet[_safe] = true;
        superChainAccount[_safe].noun = _noun;
        emit OwnerAdded(_safe, _owner, superChainAccount[_safe].superChainID);
        emit SuperChainSmartAccountCreated(
            _safe,
            _owner,
            superChainAccount[_safe].superChainID,
            _noun
        );
    }

    function populateAddOwner(
        address _safe,
        address _newOwner
    ) public firstOwnerSet(_safe) {
        require(
            msg.sender == _safe,
            "Caller is not the SuperChainSmartAccount"
        );
        require(!ISafe(_safe).isOwner(_newOwner), "Owner already exists");
        require(
            !_isPopulatedAddOwnerWithThreshold[_newOwner][_safe],
            "Owner already populated"
        );
        require(
            userSuperChainAccount[_newOwner] == address(0),
            "Owner already has a SuperChainSmartAccount"
        );
        require(
            populatedAddOwnersWithTreshold[_safe].length <= 2,
            "Max owners populated"
        );
        populatedAddOwnersWithTreshold[_safe].push(_newOwner);
        _isPopulatedAddOwnerWithThreshold[_newOwner][_safe] = true;
        string memory _superChainId = superChainAccount[_safe].superChainID;
        emit OwnerPopulated(_safe, _newOwner, _superChainId);
    }

    function incrementSuperChainPoints(
        uint256 _points,
        address recipent
    ) public returns (bool levelUp) {
        Account storage _account = superChainAccount[recipent];
        require(
            msg.sender == _resolver,
            "Only the resolver can increment the points"
        );
        require(_account.smartAccount != address(0), "Account not found");
        _account.points += _points;
        for (uint16 i = uint16(_tierTreshold.length); i > 0; i--) {
            uint16 index = i - 1;
            if (_tierTreshold[index] <= _account.points) {
                if (_account.level == index + 1) {
                    break;
                }
                _account.level = index + 1;
                levelUp = true;
                break;
            }
        }
        emit PointsIncremented(recipent, _points, levelUp);
        return levelUp;
    }

    function simulateIncrementSuperChainPoints(
        uint256 _points,
        address recipent
    ) public view returns (bool levelUp) {
        Account memory _account = superChainAccount[recipent];
        require(_account.smartAccount != address(0), "Account not found");
        _account.points += _points;
        for (uint16 i = uint16(_tierTreshold.length); i > 0; i--) {
            uint16 index = i - 1;
            if (_tierTreshold[index] <= _account.points) {
                if (_account.level == index + 1) {
                    break;
                }
                _account.level = index + 1;
                levelUp = true;
                break;
            }
        }
        return levelUp;
    }

    function _changeResolver(address resolver) public onlyOwner {
        _resolver = resolver;
    }
    function _addTierTreshold(uint256 _treshold) public onlyOwner {
        if (_tierTreshold.length > 0) {
            require(
                _tierTreshold[_tierTreshold.length - 1] < _treshold,
                "The treshold must be higher than the last one"
            );
        }
        _tierTreshold.push(_treshold);
        emit TierTresholdAdded(_treshold);
    }

    function getNextLevelPoints(address _safe) public view returns (uint256) {
        if (superChainAccount[_safe].level == _tierTreshold.length) {
            revert MaxLvlReached();
        }
        return _tierTreshold[superChainAccount[_safe].level];
    }

    function _isInvalidSuperChainId(
        string memory str
    ) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory suffixBytes = bytes(".superchain");

        if (strBytes.length < suffixBytes.length) {
            return false;
        }

        for (uint i = 0; i < suffixBytes.length; i++) {
            if (
                strBytes[strBytes.length - suffixBytes.length + i] !=
                suffixBytes[i]
            ) {
                return false;
            }
        }

        return true;
    }

    function getSuperChainAccount(
        address _safe
    ) public view returns (Account memory) {
        return superChainAccount[_safe];
    }

    function getUserSuperChainAccount(
        address _owner
    ) public view returns (Account memory) {
        return superChainAccount[userSuperChainAccount[_owner]];
    }
    modifier firstOwnerSet(address _safe) {
        require(hasFirstOwnerYet[_safe], "Initial owner not set yet");
        _;
    }
}
