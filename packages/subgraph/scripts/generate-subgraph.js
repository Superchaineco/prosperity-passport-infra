const yaml = require('js-yaml');
const Handlebars = require('handlebars');
const fs = require('fs-extra');
const path = require('path');

const generateManifests = async () => {
  try {
    const networksFilePath = path.resolve(__dirname, '../networks.yaml');
    const networks = yaml.load(await fs.readFile(networksFilePath, { encoding: 'utf-8' }));
    const network = process.env.NETWORK;
    if (!network || !networks[network]) {
      throw new Error('NETWORK variable is not set or network configuration not found');
    }

    const config = networks[network];
    const template = fs.readFileSync('subgraph.template.yaml').toString();

    const outputPath = path.resolve(__dirname, '../subgraph.yaml');
    fs.writeFileSync(outputPath, Handlebars.compile(template)(config));
    console.log('🎉 subgraph successfully generated\n');
  } catch (error) {
    console.error('Error generating subgraph manifests:', error);
  }
};

generateManifests();
