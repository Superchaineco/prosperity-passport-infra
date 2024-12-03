import fs from 'fs';
import path from 'path';

const BADGES_FILE_PATH = './badges.json';
const OUTPUT_FOLDER = './data';

const generateUri = (ipfsBaseHash, badgeId, tierId) => {
  const badgeIdHex = badgeId.toString().padStart(64, '0');
  const tierIdHex = tierId.toString().padStart(64, '0');
  return `ipfs/${ipfsBaseHash}/${badgeIdHex}${tierIdHex}.json`;
};

function generateMetadataJSON() {
  const ipfsHash = process.argv[2];
  if (!ipfsHash) {
    console.error('Please provide an IPFS hash as an argument');
    process.exit(1);
  }
  const badgesData = JSON.parse(fs.readFileSync(BADGES_FILE_PATH, 'utf-8'));

  badgesData.badges.forEach((badge, badgeIndex) => {
    const badgeId = badgeIndex + 1;

    // Generate general badge metadata URI
    badge.URI = generateUri(ipfsHash, badgeId, 0);

    // Add URI for each level (tier)
    badge.levels.forEach((level, levelIndex) => {
      const tierId = levelIndex + 1;
      level.URI = generateUri(ipfsHash, badgeId, tierId);
    });
  });

  // Save updated badge data to the output folder
  if (!fs.existsSync(OUTPUT_FOLDER)) {
    fs.mkdirSync(OUTPUT_FOLDER, { recursive: true });
  }

  const outputPath = path.join(OUTPUT_FOLDER, 'updated-badges.json');
  fs.writeFileSync(outputPath, JSON.stringify(badgesData, null, 2), 'utf-8');
}

generateMetadataJSON();
