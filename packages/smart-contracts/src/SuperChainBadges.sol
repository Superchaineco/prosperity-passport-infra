// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct BadgeUpdate {
    uint256 badgeId;
    uint256 level;
}

contract SuperChainBadges is ERC1155, Ownable {
    uint256 constant LEVEL_MASK = uint256(type(uint128).max);
    uint256 constant LEVEL_SHIFT = 128;

    struct BadgeLevel {
        string uri;
        uint256 points;
    }

    struct Badge {
        mapping(uint256 => BadgeLevel) levels;
        uint256 highestLevel;
    }

    mapping(uint256 => Badge) private _badges;
    mapping(address => mapping(uint256 => uint256)) private _userBadgeLevels;

    event BadgeLevelSet(
        uint256 indexed badgeId,
        uint256 level,
        string uri,
        uint256 points
    );
    event BadgeMinted(
        address indexed user,
        uint256 indexed badgeId,
        uint256 initialLevel,
        uint256 points,
        string uri
    );
    event BadgeLevelUpdated(
        address indexed user,
        uint256 indexed badgeId,
        uint256 level,
        uint256 points,
        string uri
    );

    constructor() ERC1155("") {}

    function setBadgeLevel(
        uint256 badgeId,
        uint256 level,
        string memory uri,
        uint256 points
    ) public onlyOwner {
        require(level > 0, "Level must be greater than 0");
        require(
            level == _badges[badgeId].highestLevel + 1,
            "Levels must be added sequentially"
        );
        if (level > 1) {
            require(
                points > _badges[badgeId].levels[level - 1].points,
                "Points must be greater than the previous level"
            );
        }
        _badges[badgeId].levels[level] = BadgeLevel(uri, points);
        _badges[badgeId].highestLevel = level;
        emit BadgeLevelSet(badgeId, level, uri, points);
    }

    function mintBadge(
        address to,
        uint256 badgeId,
        uint256 initialLevel
    ) internal returns (uint256 totalPoints) {
        require(
            bytes(_badges[badgeId].levels[initialLevel].uri).length != 0,
            "URI for initial level not set"
        );
        uint256 tokenId = _encodeTokenId(badgeId, initialLevel);
        _mint(to, tokenId, 1, "");
        _userBadgeLevels[to][badgeId] = initialLevel;
        for (uint256 level = 1; level <= initialLevel; level++) {
            totalPoints += _badges[badgeId].levels[level].points;
        }
        emit BadgeMinted(to, badgeId, initialLevel, totalPoints, _badges[badgeId].levels[initialLevel].uri);
    }

    function updateBadgeLevel(
        address user,
        uint256 badgeId,
        uint256 newLevel
    ) internal returns (uint256 totalPoints) {
        require(
            bytes(_badges[badgeId].levels[newLevel].uri).length != 0,
            "URI for new level not set"
        );
        uint256 oldLevel = _userBadgeLevels[user][badgeId];
        uint256 oldTokenId = _encodeTokenId(badgeId, oldLevel);
        uint256 newTokenId = _encodeTokenId(badgeId, newLevel);

        _burn(user, oldTokenId, 1);
        _mint(user, newTokenId, 1);

        _userBadgeLevels[user][badgeId] = newLevel;
        for (uint256 level = oldLevel + 1; level <= newLevel; level++) {
            totalPoints += _badges[badgeId].levels[level].points;
        }
        emit BadgeLevelUpdated(user, badgeId, newLevel, totalPoints, _badges[badgeId].levels[newLevel].uri);
    }

    function getBadgeURIForUser(
        address user,
        uint256 badgeId
    ) public view returns (string memory) {
        uint256 userLevel = _userBadgeLevels[user][badgeId];
        return _badges[badgeId].levels[userLevel].uri;
    }

    function getUserBadgeLevel(
        address user,
        uint256 badgeId
    ) public view returns (uint256) {
        return _userBadgeLevels[user][badgeId];
    }

    function updateOrMintBadges(
        address user,
        BadgeUpdate[] memory updates
    ) public returns (uint256 points) {
        for (uint256 i = 0; i < updates.length; i++) {
            uint256 badgeId = updates[i].badgeId;
            uint256 level = updates[i].level;

            if (_userBadgeLevels[user][badgeId] > 0) {
                points += updateBadgeLevel(user, badgeId, level);
            } else {
                points += mintBadge(user, badgeId, level);
            }
        }
    }

    function getHighestBadgeLevel(
        uint256 badgeId
    ) public view returns (uint256) {
        return _badges[badgeId].highestLevel;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        (uint256 badgeId, uint256 level) = _decodeTokenId(tokenId);
        return _badges[badgeId].levels[level].uri;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        revert("BadgeNFT: Transfers are disabled");
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        revert("BadgeNFT: Transfers are disabled");
    }

    function _encodeTokenId(
        uint256 badgeId,
        uint256 level
    ) internal pure returns (uint256) {
        return (badgeId << LEVEL_SHIFT) | (level & LEVEL_MASK);
    }

    function _decodeTokenId(
        uint256 tokenId
    ) internal pure returns (uint256 badgeId, uint256 level) {
        badgeId = tokenId >> LEVEL_SHIFT;
        level = tokenId & LEVEL_MASK;
    }
}
