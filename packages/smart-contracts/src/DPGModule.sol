// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ISafe} from "../interfaces/ISafe.sol";
import {Enum} from "../libraries/Enum.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DPGModule is EIP712, Ownable {
    using ECDSA for bytes32;

    event OwnerPopulated(
        address indexed safe,
        address indexed newOwner,
        string indexed dpgId
    );
    event OwnerAdded(
        address indexed safe,
        address indexed newOwner,
        string indexed dpgId
    );
    event PointsIncremented(address indexed recipient, uint256 points);

    mapping(address => mapping(address => bool))
        private _isPopulatedAddOwnerWithThreshold;
    mapping(address => Account) public dpgAccount;
    mapping(address => bool) public hasFirstOwnerYet;

    address private _resolver;
    uint256[] private _tierTreshold = [0];

    struct AddOwnerRequest {
        address dpgAccount;
        address newOwner;
    }

    struct Account {
        address smartAccount;
        string dpgID;
        uint256 points;
        uint16 level;
        address[] eoas;
    }

    constructor(
        address resolver
    ) EIP712("DPGAccountModule", "1") Ownable(msg.sender) {
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
            dpgAccount[_newOwner].smartAccount == address(0),
            "Owner already has a DPGAccount"
        );
        require(
            _isPopulatedAddOwnerWithThreshold[_newOwner][_safe],
            "Owner not populated"
        );
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
        dpgAccount[_newOwner].smartAccount = _safe;
        emit OwnerAdded(_safe, _newOwner, dpgAccount[_newOwner].dpgID);
    }

    function setInitialOwner(
        address _safe,
        address _owner,
        string calldata dpgId
    ) public {
        require(
            dpgAccount[_owner].smartAccount == address(0),
            "Owner already has a SuperChainSmartAccount"
        );
        require(ISafe(_safe).isOwner(_owner), "The address is not an owner");
        require(msg.sender == _safe, "Caller is not the DPGAccount");
        require(!hasFirstOwnerYet[_safe], "DPGAccount already has owners");
        require(
            ISafe(_safe).getOwners().length == 1,
            "DPGAccount already has owners"
        );
        require(
            !_isInvalidDPGId(dpgId),
            "The last 4 characters cannot be '.dpg'"
        );
        dpgAccount[_owner].smartAccount = _safe;
        dpgAccount[_owner].dpgID = string.concat(dpgId, ".dpg");
        hasFirstOwnerYet[_safe] = true;
        emit OwnerAdded(_safe, _owner, dpgAccount[_owner].dpgID);
    }

    function populateAddOwner(
        address _safe,
        address _newOwner
    ) public firstOwnerSet(_safe) {
        require(msg.sender == _safe, "Caller is not the DPGAccount");
        require(!ISafe(_safe).isOwner(_newOwner), "Owner already exists");
        require(
            !_isPopulatedAddOwnerWithThreshold[_newOwner][_safe],
            "Owner already populated"
        );
        require(
            dpgAccount[_newOwner].smartAccount == address(0),
            "Owner already has a DPGAccount"
        );
        _isPopulatedAddOwnerWithThreshold[_newOwner][_safe] = true;
        emit OwnerPopulated(_safe, _newOwner, dpgAccount[_newOwner].dpgID);
    }

    function getDPGAccount(
        address _owner
    ) public view returns (Account memory) {
        require(
            dpgAccount[_owner].smartAccount != address(0),
            "Account not found"
        );
        return dpgAccount[_owner];
    }

    function incrementDPGPoints(uint256 _points, address recipent) public {
        Account storage _account = dpgAccount[recipent];
        require(
            msg.sender == _resolver,
            "Only the resolver can increment the points"
        );
        require(_account.smartAccount != address(0), "Account not found");
        _account.points += _points;
        if (_account.points >= _tierTreshold[_account.level]) {
            _account.level++;
        }
        emit PointsIncremented(recipent, _points);
    }

    function _changeResolver(address resolver) public onlyOwner {
        _resolver = resolver;
    }
    function _addTierTreshold(uint256 _treshold) public onlyOwner {
        require(
            _tierTreshold[_tierTreshold.length - 1] < _treshold,
            "The treshold must be higher than the last one"
        );
        _tierTreshold.push(_treshold);
    }

    function _isInvalidDPGId(string memory str) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory suffixBytes = bytes(".dpg");

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
            dpgAccount: _safe,
            newOwner: _newOwner
        });

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "AddOwnerRequest(address dpgAccount,address newOwner)"
                ),
                request.dpgAccount,
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

    modifier firstOwnerSet(address _safe) {
        require(hasFirstOwnerYet[_safe], "Initial owner not set yet");
        _;
    }
}
