// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ERC1155Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

struct BadgeUpdate {
    uint256 badgeId;
    uint256 tier;
}

struct BadgeMetadata {
    uint256 badgeId;
    string generalURI;
}
struct BadgeTierMetadata {
    uint256 badgeId;
    uint256 tier;
    string newURI;
    uint256 points;
}
contract SuperChainBadges is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 constant LEVEL_MASK = uint256(type(uint128).max);
    uint256 constant LEVEL_SHIFT = 128;
    /// @custom:storage-location erc7201:openzeppelin.storage.superchain_badges
    struct BadgesStorage {
        address resolver;
        mapping(uint256 => Badge) _badges;
        mapping(address => mapping(uint256 => uint256)) _userBadgeTiers;
    }

    struct BadgeTier {
        string uri;
        uint256 points;
    }

    struct Badge {
        string generalURI;
        mapping(uint256 => BadgeTier) tiers;
        uint256 highestTier;
    }

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
    event BadgeMetadataSettled(uint256 indexed badgeId, string generalURI);
    event BadgeTierMetadataUpdated(
        uint256 indexed badgeId,
        uint256 tier,
        string newURI
    );
    event BadgeTierUpdated(
        address indexed user,
        uint256 indexed badgeId,
        uint256 tier,
        uint256 points,
        string uri
    );

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.superchain_badges")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant SUPERCHAIN_BADGES_STORAGE_LOCATION =
        0xb2b7b32472936fec942d11d364b3fb7baeea6584fbe4aa7e3432289df3426200;

    function badgesStorage() private pure returns (BadgesStorage storage $) {
        assembly {
            $.slot := SUPERCHAIN_BADGES_STORAGE_LOCATION
        }
    }

    function initialize(address owner) public initializer {
        __ERC1155_init("");
        __Ownable_init(owner);
        __UUPSUpgradeable_init();
    }

    function setBadgesAndTiers(
        BadgeMetadata[] memory badges,
        BadgeTierMetadata[] memory badgeTiers
    ) public onlyOwner {
        for (uint256 i = 0; i < badges.length; i++) {
            setBadgeMetadata(badges[i].badgeId, badges[i].generalURI);
        }
        for (uint256 i = 0; i < badgeTiers.length; i++) {
            setBadgeTier(
                badgeTiers[i].badgeId,
                badgeTiers[i].tier,
                badgeTiers[i].newURI,
                badgeTiers[i].points
            );
        }
    }

    function setBadgeMetadata(
        uint256 badgeId,
        string memory generalURI
    ) public onlyOwner {
        BadgesStorage storage s = badgesStorage();
        s._badges[badgeId].generalURI = generalURI;
        emit BadgeMetadataSettled(badgeId, generalURI);
    }

    function updateBadgeTierMetadata(
        uint256 badgeId,
        uint256 tier,
        string memory newURI
    ) public onlyOwner {
        BadgesStorage storage s = badgesStorage();
        require(
            bytes(s._badges[badgeId].generalURI).length != 0,
            "Badge does not exist"
        );
        require(
            bytes(s._badges[badgeId].tiers[tier].uri).length != 0,
            "URI for initial tier not set"
        );
        s._badges[badgeId].tiers[tier].uri = newURI;
        emit BadgeTierMetadataUpdated(badgeId, tier, newURI);
    }

    function setBadgeTier(
        uint256 badgeId,
        uint256 tier,
        string memory newURI,
        uint256 points
    ) public onlyOwner {
        BadgesStorage storage s = badgesStorage();
        require(
            bytes(s._badges[badgeId].generalURI).length != 0,
            "Badge does not exist"
        );
        require(tier > 0, "Tier must be greater than 0");
        require(
            tier == s._badges[badgeId].highestTier + 1,
            "Tiers must be added sequentially"
        );
        if (tier > 1) {
            require(
                points > s._badges[badgeId].tiers[tier - 1].points,
                "Points must be greater than the previous tier"
            );
        }
        s._badges[badgeId].tiers[tier] = BadgeTier(newURI, points);
        s._badges[badgeId].highestTier = tier;
        emit BadgeTierSet(badgeId, tier, newURI, points);
    }

    function mintBadge(
        address to,
        uint256 badgeId,
        uint256 initialTier
    ) internal returns (uint256 totalPoints) {
        BadgesStorage storage s = badgesStorage();
        require(
            bytes(s._badges[badgeId].tiers[initialTier].uri).length != 0,
            "URI for initial tier not set"
        );
        uint256 tokenId = _encodeTokenId(badgeId, initialTier);
        require(balanceOf(to, tokenId) == 0, "Badge already minted");
        _mint(to, tokenId, 1, "");
        s._userBadgeTiers[to][badgeId] = initialTier;
        for (uint256 tier = 1; tier <= initialTier; tier++) {
            totalPoints += s._badges[badgeId].tiers[tier].points;
        }
        emit BadgeMinted(
            to,
            badgeId,
            initialTier,
            totalPoints,
            s._badges[badgeId].tiers[initialTier].uri
        );
    }

    function updateBadgeTier(
        address user,
        uint256 badgeId,
        uint256 newTier
    ) internal returns (uint256 totalPoints) {
        BadgesStorage storage s = badgesStorage();
        require(
            bytes(s._badges[badgeId].tiers[newTier].uri).length != 0,
            "URI for new tier not set"
        );
        uint256 oldTier = s._userBadgeTiers[user][badgeId];
        uint256 oldTokenId = _encodeTokenId(badgeId, oldTier);
        uint256 newTokenId = _encodeTokenId(badgeId, newTier);
        require(balanceOf(user, newTokenId) == 0, "Badge already minted");

        _burn(user, oldTokenId, 1);
        _mint(user, newTokenId, 1, "");

        s._userBadgeTiers[user][badgeId] = newTier;
        for (uint256 tier = oldTier + 1; tier <= newTier; tier++) {
            totalPoints += s._badges[badgeId].tiers[tier].points;
        }
        emit BadgeTierUpdated(
            user,
            badgeId,
            newTier,
            totalPoints,
            s._badges[badgeId].tiers[newTier].uri
        );
    }

    function getBadgeURIForUser(
        address user,
        uint256 badgeId
    ) public view returns (string memory generalURI, string memory tierUri) {
        BadgesStorage storage s = badgesStorage();
        uint256 userTier = s._userBadgeTiers[user][badgeId];
        generalURI = s._badges[badgeId].generalURI;
        tierUri = s._badges[badgeId].tiers[userTier].uri;
    }

    function getGeneralBadgeURI(
        uint256 badgeId
    ) public view returns (string memory) {
        BadgesStorage storage s = badgesStorage();
        return s._badges[badgeId].generalURI;
    }

    function getUserBadgeTier(
        address user,
        uint256 badgeId
    ) public view returns (uint256) {
        BadgesStorage storage s = badgesStorage();
        return s._userBadgeTiers[user][badgeId];
    }

    function updateOrMintBadges(
        address user,
        BadgeUpdate[] memory updates
    ) public returns (uint256 points) {
        BadgesStorage storage s = badgesStorage();
        require(
            msg.sender == s.resolver,
            "Only resolver can call this function"
        );
        for (uint256 i = 0; i < updates.length; i++) {
            uint256 badgeId = updates[i].badgeId;
            uint256 tier = updates[i].tier;

            if (s._userBadgeTiers[user][badgeId] > 0) {
                points += updateBadgeTier(user, badgeId, tier);
            } else {
                points += mintBadge(user, badgeId, tier);
            }
        }
    }

    function setResolver(address _resolver) public onlyOwner {
        BadgesStorage storage s = badgesStorage();
        s.resolver = _resolver;
    }

    function getHighestBadgeTier(
        uint256 badgeId
    ) public view returns (uint256) {
        BadgesStorage storage s = badgesStorage();
        return s._badges[badgeId].highestTier;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        BadgesStorage storage s = badgesStorage();
        (uint256 badgeId, uint256 tier) = _decodeTokenId(tokenId);
        string memory baseURI = s._badges[badgeId].generalURI;
        string memory tierURI = s._badges[badgeId].tiers[tier].uri;
        return
            string(
                abi.encodePacked(
                    "{",
                    '"generalURI": "',
                    baseURI,
                    '",',
                    '"tierURI": "',
                    tierURI,
                    '"',
                    "}"
                )
            );
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
    function resolver() public view returns (address) {
        BadgesStorage storage s = badgesStorage();
        return s.resolver;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
