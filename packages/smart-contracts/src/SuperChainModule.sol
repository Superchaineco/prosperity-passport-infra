// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ISafe} from "../interfaces/ISafe.sol";
import {Enum} from "../libraries/Enum.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

struct NounMetadata {
    uint48 background;
    uint48 body;
    uint48 accessory;
    uint48 head;
    uint48 glasses;
}

contract SuperChainModule is EIP712, Ownable {
    using ECDSA for bytes32;

    event OwnerPopulated(
        address indexed safe,
        address indexed newOwner,
        string indexed superChainId
    );
    event OwnerAdded(
        address indexed safe,
        address indexed newOwner,
        string indexed superChainId
    );
    event PointsIncremented(address indexed recipient, uint256 points);

    mapping(address => mapping(address => bool))
        private _isPopulatedAddOwnerWithThreshold;
    mapping(address => address[]) public populatedAddOwnersWithTreshold;
    mapping(address => Account) public superChainAccount;
    mapping(address => bool) public hasFirstOwnerYet;
    mapping(string => bool) public SuperChainIDRegistered;

    address private _resolver;
    uint256[] private _tierTreshold;

    struct AddOwnerRequest {
        address superChainAccount;
        address newOwner;
    }

    struct Account {
        address smartAccount;
        string superChainID;
        uint256 points;
        uint16 level;
        NounMetadata noun;
    }

    constructor(
        address resolver
    ) EIP712("SuperChainAccountModule", "1") Ownable(msg.sender) {
        _resolver = resolver;
    }

    function addOwnerWithThreshold(
        address _safe,
        address _newOwner,
        bytes calldata signature
    ) public firstOwnerSet(_safe) {
        require(
            _verifySignature(_safe, _newOwner, signature),
            "Signature verification failed"
        );
        require(
            superChainAccount[_newOwner].smartAccount == address(0),
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
        superChainAccount[_newOwner].smartAccount = _safe;
        emit OwnerAdded(
            _safe,
            _newOwner,
            superChainAccount[_newOwner].superChainID
        );
    }

    function removePopulateRequest(address _safe) public {
        require(
            _isPopulatedAddOwnerWithThreshold[msg.sender][_safe],
            "Owner not populated"
        );
        for (
            uint i = 0;
            i < populatedAddOwnersWithTreshold[msg.sender].length;
            i++
        ) {
            if (populatedAddOwnersWithTreshold[msg.sender][i] == msg.sender) {
                populatedAddOwnersWithTreshold[msg.sender][
                    i
                ] = populatedAddOwnersWithTreshold[msg.sender][
                    populatedAddOwnersWithTreshold[msg.sender].length - 1
                ];
                populatedAddOwnersWithTreshold[msg.sender].pop();
                _isPopulatedAddOwnerWithThreshold[msg.sender][_safe] = false;
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
            superChainAccount[_owner].smartAccount == address(0),
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
        superChainAccount[_owner].smartAccount = _safe;
        superChainAccount[_owner].superChainID = string.concat(
            superChainID,
            ".superchain"
        );
        SuperChainIDRegistered[superChainID] = true;
        hasFirstOwnerYet[_safe] = true;
        superChainAccount[_owner].noun = _noun;
        emit OwnerAdded(_safe, _owner, superChainAccount[_owner].superChainID);
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
            superChainAccount[_newOwner].smartAccount == address(0),
            "Owner already has a SuperChainSmartAccount"
        );
        require(
            populatedAddOwnersWithTreshold[_safe].length <= 2,
            "Max owners populated"
        );
        populatedAddOwnersWithTreshold[_safe].push(_newOwner);
        _isPopulatedAddOwnerWithThreshold[_newOwner][_safe] = true;
        emit OwnerPopulated(
            _safe,
            _newOwner,
            superChainAccount[_newOwner].superChainID
        );
    }

    function incrementSuperChainPoints(
        uint256 _points,
        address recipent
    ) public returns (bool levelUp) {
        address _owner = _getSuperChainAccountOwner(recipent);
        Account storage _account = superChainAccount[_owner];
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
        emit PointsIncremented(recipent, _points);
        return levelUp;
    }

    function simulateIncrementSuperChainPoints(
        uint256 _points,
        address recipent
    ) public view returns (bool levelUp) {
        address _owner = _getSuperChainAccountOwner(recipent);
        Account memory _account = superChainAccount[_owner];
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

    function _verifySignature(
        address _safe,
        address _newOwner,
        bytes calldata signature
    ) internal view returns (bool) {
        AddOwnerRequest memory request = AddOwnerRequest({
            superChainAccount: _safe,
            newOwner: _newOwner
        });

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "AddOwnerRequest(address superChainAccount,address newOwner)"
                ),
                request.superChainAccount,
                request.newOwner
            )
        );

        bytes32 digest = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(digest, signature);

        if (signer == _newOwner) {
            return true;
        } else {
            return false;
        }
    }

    function getSuperChainAccount(
        address _safe
    ) external view returns (Account memory) {
        address[] memory owners = ISafe(_safe).getOwners();
        require(owners.length > 0, "No owners found");
        return superChainAccount[owners[0]];
    }

    function _getSuperChainAccountOwner(
        address _safe
    ) private view returns (address) {
        address[] memory owners = ISafe(_safe).getOwners();
        require(owners.length > 0, "No owners found");
        return owners[0];
    }

    modifier firstOwnerSet(address _safe) {
        require(hasFirstOwnerYet[_safe], "Initial owner not set yet");
        _;
    }
}
