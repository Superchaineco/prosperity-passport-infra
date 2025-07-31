# DPG-Accounts
DPG Accounts is an open-source solution by Kolektivo Labs built on Safe{Core} Protocol that creates native accounts for EVM-compatable Blockchain ecosystems and dApps to engage active users and reward meaningful participation. 

Updating badges metadata
1. In utils/badges-metadata  modify the badges.json and run 'npm run pin-file' (Need to param in .env the pinata api key)
2. Copy de hash to utils/badges-metadata/src/generateMetadata.js
3. npm run generate-metadata
4. Then go to packages/smart-contracts run 'forge compile'
5. Copy the badges-with-uris.json to smart-contracts folder and/or change the badges.json depending the use (badges.sjon for some badges update or add and the other for full update)
6. Use the AddBadges (for all badges) or UpdateBadges (for new badges or single badge updating)

Account is the keystore file
SA prod
BADGES_ADDRESS=0xd47C56513E640E394024FaCBBe5032cf604Bb699 forge script script/AddBadges.s.sol --rpc-url celo --account pp-pk --broadcast
BADGES_ADDRESS=0xd47C56513E640E394024FaCBBe5032cf604Bb699 forge script script/UpdateBadges.s.sol --rpc-url celo --account pp-pk --broadcast