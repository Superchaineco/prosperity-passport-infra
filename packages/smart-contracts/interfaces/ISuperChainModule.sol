// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


struct NounMetadata {
    uint48 background;
    uint48 body;
    uint48 accessory;
    uint48 head;
    uint48 glasses;
}



interface ISuperChainModule {
    error MaxLvlReached();

    event SuperChainSmartAccountCreated(
        address indexed safe,
        address indexed initialOwner,
        string superChainId,
        NounMetadata noun
    );

    event OwnerPopulationRemoved(
        address indexed safe,
        address indexed owner,
        string superChainId
    );

    event OwnerPopulated(
        address indexed safe,
        address indexed newOwner,
        string superChainId
    );
    event OwnerAdded(
        address indexed safe,
        address indexed newOwner,
        string superChainId
    );
    event PointsIncremented(address indexed recipient, uint256 points, bool levelUp);
    event TierTresholdAdded(uint256 treshold);
    event TierTresholdUpdated(uint256 index, uint256 newThreshold);
    event NounUpdated(address indexed safe, NounMetadata noun);
    // Functions
    function addOwnerWithThreshold(address _safe, address _newOwner) external;

    function removePopulateRequest(address _safe, address user) external;

    function setInitialOwner(
        address _safe,
        address _owner,
        NounMetadata calldata _noun,
        string calldata superChainID
    ) external;

    function populateAddOwner(address _safe, address _newOwner) external;

    function incrementSuperChainPoints(uint256 _points, address recipient) external returns (bool levelUp);

    function simulateIncrementSuperChainPoints(uint256 _points, address recipient) external view returns (bool levelUp);

    function addTiersTreshold(uint256[] memory tresholds) external;

    function _changeResolver(address resolver) external;


    function getNextLevelPoints(address _safe) external view returns (uint256);

    function getSuperChainAccount(address _safe) external view returns (Account memory);

    function getUserSuperChainAccount(address _owner) external view returns (Account memory);


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
}

