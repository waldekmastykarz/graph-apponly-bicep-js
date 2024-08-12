import fs from 'fs';
import path from 'path';

const __dirname = new URL('.', import.meta.url).pathname;

const configFilename = path.join(__dirname, '..', 'local.settings.json');
const args = process.argv.slice(2);

const setting = args[0];
const value = args[1];

console.log(`Updating ${setting} to ${value}`);

const config = JSON.parse(fs.readFileSync(configFilename, 'utf8'));
config.Values[setting] = value;
fs.writeFileSync(configFilename, JSON.stringify(config, null, 2));

console.log('Done');