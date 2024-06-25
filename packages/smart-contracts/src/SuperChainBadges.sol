// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct BadgeUpdate {
    uint256 badgeId;
    uint256 tier;
}

contract SuperChainBadges is ERC1155, Ownable {
    uint256 constant LEVEL_MASK = uint256(type(uint128).max);
    uint256 constant LEVEL_SHIFT = 128;

    struct BadgeTier {
        string uri;
        uint256 points;
    }

    struct Badge {
        string uri;
        mapping(uint256 => BadgeTier) tiers;
        uint256 highestTier;
    }

    mapping(uint256 => Badge) private _badges;
    mapping(address => mapping(uint256 => uint256)) private _userBadgeTiers;

    event BadgeTierSet(
        uint256 indexed badgeId,
        uint256 tier,
        string uri,
        uint256 points
    );
    event BadgeMinted(
        address indexed user,
        uint256 indexed badgeId,
        uint256 initialTier,
        uint256 points,
        string uri
    );
    event BadgeMetadataSettled(
        uint256 indexed badgeId,
        string generalUri
    );
    event BadgeTierUpdated(
        address indexed user,
        uint256 indexed badgeId,
        uint256 tier,
        uint256 points,
        string uri
    );

    constructor() ERC1155("") Ownable(msg.sender) {}

    function setBadgeMetadata(
        uint256 badgeId,
        string memory generalUri
    ) public onlyOwner {
        _badges[badgeId].generalUri = generalUri;
        emit BadgeMetadataSettled(badgeId, generalUri);
    }

    function setBadgeTier(
        uint256 badgeId,
        uint256 tier,
        string memory newURI,
        uint256 points
    ) public onlyOwner {
        require(
            bytes(_badges[badgeId].uri).length != 0,
            "Badge does not exist"
        );
        require(tier > 0, "Tier must be greater than 0");
        require(
            tier == _badges[badgeId].highestTier + 1,
            "Tiers must be added sequentially"
        );
        if (tier > 1) {
            require(
                points > _badges[badgeId].tiers[tier - 1].points,
                "Points must be greater than the previous tier"
            );
        }
        _badges[badgeId].tiers[tier] = BadgeTier(newURI, points);
        _badges[badgeId].highestTier = tier;
        emit BadgeTierSet(badgeId, tier, newURI, points);
    }

    function mintBadge(
        address to,
        uint256 badgeId,
        uint256 initialTier
    ) internal returns (uint256 totalPoints) {
        require(
            bytes(_badges[badgeId].tiers[initialTier].uri).length != 0,
            "URI for initial tier not set"
        );
        uint256 tokenId = _encodeTokenId(badgeId, initialTier);
        _mint(to, tokenId, 1, "");
        _userBadgeTiers[to][badgeId] = initialTier;
        for (uint256 tier = 1; tier <= initialTier; tier++) {
            totalPoints += _badges[badgeId].tiers[tier].points;
        }
        emit BadgeMinted(
            to,
            badgeId,
            initialTier,
            totalPoints,
            _badges[badgeId].tiers[initialTier].uri
        );
    }

    function updateBadgeTier(
        address user,
        uint256 badgeId,
        uint256 newTier
    ) internal returns (uint256 totalPoints) {
        require(
            bytes(_badges[badgeId].tiers[newTier].uri).length != 0,
            "URI for new tier not set"
        );
        uint256 oldTier = _userBadgeTiers[user][badgeId];
        uint256 oldTokenId = _encodeTokenId(badgeId, oldTier);
        uint256 newTokenId = _encodeTokenId(badgeId, newTier);

        _burn(user, oldTokenId, 1);
        _mint(user, newTokenId, 1, "");

        _userBadgeTiers[user][badgeId] = newTier;
        for (uint256 tier = oldTier + 1; tier <= newTier; tier++) {
            totalPoints += _badges[badgeId].tiers[tier].points;
        }
        emit BadgeTierUpdated(
            user,
            badgeId,
            newTier,
            totalPoints,
            _badges[badgeId].tiers[newTier].uri
        );
    }

  function getBadgeURIForUser(
        address user,
        uint256 badgeId
    ) public view returns (string memory generalUri, string memory tierUri) {
        uint256 userTier = _userBadgeTiers[user][badgeId];
        generalUri = _badges[badgeId].uri;
        tierUri = _badges[badgeId].tiers[userTier].uri;
    }

    function getGeneralBadgeURI(
        uint256 badgeId
    ) public view returns (string memory) {
        return _badges[badgeId].generalUri;
    }

    function getUserBadgeTier(
        address user,
        uint256 badgeId
    ) public view returns (uint256) {
        return _userBadgeTiers[user][badgeId];
    }

    function updateOrMintBadges(
        address user,
        BadgeUpdate[] memory updates
    ) public returns (uint256 points) {
        for (uint256 i = 0; i < updates.length; i++) {
            uint256 badgeId = updates[i].badgeId;
            uint256 tier = updates[i].tier;

            if (_userBadgeTiers[user][badgeId] > 0) {
                points += updateBadgeTier(user, badgeId, tier);
            } else {
                points += mintBadge(user, badgeId, tier);
            }
        }
    }

    function getHighestBadgeTier(
        uint256 badgeId
    ) public view returns (uint256) {
        return _badges[badgeId].highestTier;
    }

    function uri(uint256 tokenId) public view override returns (string memory baseURI, string memory tierURI) {
        (uint256 badgeId, uint256 tier) = _decodeTokenId(tokenId);
        baseURI = _badges[badgeId].generalUri;
        tierURI = _badges[badgeId].tiers[tier].uri;
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override {
        revert("BadgeNFT: Transfers are disabled");
    }

    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override {
        revert("BadgeNFT: Transfers are disabled");
    }

    function _encodeTokenId(
        uint256 badgeId,
        uint256 tier
    ) internal pure returns (uint256) {
        return (badgeId << LEVEL_SHIFT) | (tier & LEVEL_MASK);
    }

    function _decodeTokenId(
        uint256 tokenId
    ) internal pure returns (uint256 badgeId, uint256 tier) {
        badgeId = tokenId >> LEVEL_SHIFT;
        tier = tokenId & LEVEL_MASK;
    }
}
